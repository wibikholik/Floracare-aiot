<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class JadwalPenyiraman extends Model
{
    protected $table = 'jadwal_penyiraman';

    protected $fillable = ['zona_id', 'hari', 'jam', 'durasi_detik', 'campur_pupuk', 'aktif'];

    protected $casts = [
        'hari'         => 'array',
        'campur_pupuk' => 'boolean',
        'aktif'        => 'boolean',
    ];

    public function zona(): BelongsTo
    {
        return $this->belongsTo(Zona::class);
    }

    // Kolom `time` terbaca "07:00:00"; ambil "07:00" untuk dibandingkan dengan now()->format('H:i')
    public function getJamPendekAttribute(): string
    {
        return substr($this->jam, 0, 5);
    }
}