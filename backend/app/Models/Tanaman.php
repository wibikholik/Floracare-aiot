<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Tanaman extends Model
{
    // Nama tabel ditulis eksplisit supaya tidak berubah jadi "tanamen"
    protected $table = 'tanaman';

    protected $fillable = [
        'user_id',
        'kategori_id',
        'zona_id',
        'nama',
        'jenis',
        'lokasi',
        'status',
        'catatan',
    ];

    public function kategori(): BelongsTo
    {
        return $this->belongsTo(Kategori::class, 'kategori_id');
    }

    public function zona(): BelongsTo
    {
        return $this->belongsTo(Zona::class, 'zona_id');
    }
    public function deteksiPenyakit()
    {
        return $this->hasMany(DeteksiPenyakit::class);
    }

    public function sampelSensor(): HasMany
    {
        return $this->hasMany(SampelSensor::class, 'tanaman_id')->orderBy('nomor');
    }
}
