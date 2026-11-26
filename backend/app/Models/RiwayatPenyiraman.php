<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class RiwayatPenyiraman extends Model
{
    protected $table = 'riwayat_penyiraman';

    protected $fillable = [
        'zona_id', 'perintah_id', 'sumber', 'mulai', 'selesai', 'durasi_detik',
        'campur_pupuk', 'kelembapan_sebelum', 'kelembapan_sesudah',
    ];

    protected $casts = [
        'mulai'              => 'datetime',
        'selesai'            => 'datetime',
        'campur_pupuk'       => 'boolean',
        'kelembapan_sebelum' => 'float',
        'kelembapan_sesudah' => 'float',
    ];

    public function zona(): BelongsTo
    {
        return $this->belongsTo(Zona::class);
    }

    public function perintah(): BelongsTo
    {
        return $this->belongsTo(PerintahPenyiraman::class, 'perintah_id');
    }
}