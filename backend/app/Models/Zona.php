<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class Zona extends Model
{
    protected $table = 'zona';

    protected $fillable = ['nama_zona', 'deskripsi'];

    public function tanaman(): HasMany
    {
        return $this->hasMany(Tanaman::class, 'zona_id');
    }

    public function perangkat(): HasMany
    {
        return $this->hasMany(Perangkat::class);
    }

    public function sampelSensor(): HasMany
    {
        return $this->hasMany(SampelSensor::class, 'zona_id')->orderBy('nomor');
    }

    public function pengaturanOtomasi(): HasOne
    {
        return $this->hasOne(PengaturanOtomasi::class);
    }

    public function jadwalPenyiraman(): HasMany
    {
        return $this->hasMany(JadwalPenyiraman::class);
    }

    public function perintahPenyiraman(): HasMany
    {
        return $this->hasMany(PerintahPenyiraman::class);
    }
}
