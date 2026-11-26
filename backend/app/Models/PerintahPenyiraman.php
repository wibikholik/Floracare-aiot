<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Facades\DB;

class PerintahPenyiraman extends Model
{
    public const PENDING = 'pending';
    public const DIKIRIM = 'dikirim';
    public const SELESAI = 'selesai';
    public const GAGAL   = 'gagal';

    public const DURASI_MAKS = 300; // detik, batas pengaman di backend

    protected $table = 'perintah_penyiraman';

    protected $fillable = [
        'zona_id', 'jadwal_id', 'sumber', 'durasi_detik', 'campur_pupuk',
        'status', 'dikirim_pada', 'selesai_pada', 'catatan',
    ];

    protected $casts = [
        'campur_pupuk' => 'boolean',
        'dikirim_pada' => 'datetime',
        'selesai_pada' => 'datetime',
    ];

    // Batasi durasi setiap kali disimpan
    protected static function booted(): void
    {
        static::saving(function (self $p) {
            $p->durasi_detik = min($p->durasi_detik, self::DURASI_MAKS);
        });
    }

    public function scopeAktif(Builder $q): Builder
    {
        return $q->whereIn('status', [self::PENDING, self::DIKIRIM]);
    }

    public function zona(): BelongsTo
    {
        return $this->belongsTo(Zona::class);
    }

    public function jadwal(): BelongsTo
    {
        return $this->belongsTo(JadwalPenyiraman::class, 'jadwal_id');
    }
        // Tandai perintah selesai; jika berhasil, catat ke riwayat_penyiraman
    public function selesaikan(bool $berhasil = true, ?string $catatan = null): void
    {
        DB::transaction(function () use ($berhasil, $catatan) {
            $this->update([
                'status'       => $berhasil ? self::SELESAI : self::GAGAL,
                'selesai_pada' => now(),
                'catatan'      => $catatan,
            ]);

            if (!$berhasil) {
                return;
            }

            $mulai = $this->dikirim_pada ?? now();

            $sebelum = DataSensor::where('zona_id', $this->zona_id)
                ->where('created_at', '<=', $mulai)
                ->latest('id')->value('kelembapan_tanah');

            $sesudah = DataSensor::where('zona_id', $this->zona_id)
                ->latest('id')->value('kelembapan_tanah');

            RiwayatPenyiraman::create([
                'zona_id'            => $this->zona_id,
                'perintah_id'        => $this->id,
                'sumber'             => $this->sumber,
                'mulai'              => $mulai,
                'selesai'            => now(),
                'durasi_detik'       => $this->durasi_detik,
                'campur_pupuk'       => $this->campur_pupuk,
                'kelembapan_sebelum' => $sebelum,
                'kelembapan_sesudah' => $sesudah,
            ]);
        });
    }
}