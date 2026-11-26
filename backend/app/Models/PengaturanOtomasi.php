<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PengaturanOtomasi extends Model
{
    protected $table = 'pengaturan_otomasi';

    protected $fillable = [
        'zona_id', 'otomatis_aktif', 'batas_kelembapan_min', 'batas_kelembapan_maks',
        'durasi_detik', 'campur_pupuk', 'jeda_menit',
    ];

    protected $casts = [
        'otomatis_aktif' => 'boolean',
        'campur_pupuk'   => 'boolean',
    ];

    public function zona(): BelongsTo
    {
        return $this->belongsTo(Zona::class);
    }
}