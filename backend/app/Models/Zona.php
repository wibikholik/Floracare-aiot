<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Zona extends Model
{
    // Nama tabel ditulis eksplisit supaya tidak berubah jadi "zonas"
    protected $table = 'zona';

    protected $fillable = [
        'nama_zona',
        'deskripsi',
    ];

    // Satu zona bisa menampung banyak tanaman
    public function tanaman(): HasMany
    {
        return $this->hasMany(Tanaman::class, 'zona_id');
    }
}
