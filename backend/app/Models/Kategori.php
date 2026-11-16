<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Kategori extends Model
{
    // Nama tabel ditulis eksplisit supaya tidak berubah jadi "kategoris"
    protected $table = 'kategori';

    protected $fillable = [
        'nama',
        'deskripsi',
    ];

    // Satu kategori bisa dipakai oleh banyak tanaman
    public function tanaman(): HasMany
    {
        return $this->hasMany(Tanaman::class, 'kategori_id');
    }
}
