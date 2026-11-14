<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Tanaman extends Model
{
    // Nama tabel ditulis eksplisit supaya tidak berubah jadi "tanamen"
    protected $table = 'tanaman';

    protected $fillable = [
        'user_id',
        'nama',
        'jenis',
        'lokasi',
        'status',
        'catatan',
    ];
}