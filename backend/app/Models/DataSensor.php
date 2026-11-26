<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class DataSensor extends Model
{
    protected $table = 'data_sensor';

    // Hanya created_at (diisi database), tidak ada updated_at
    public $timestamps = false;

    protected $fillable = ['zona_id', 'suhu', 'kelembapan_udara', 'kelembapan_tanah', 'ph_tanah'];

    protected $casts = [
        'suhu'             => 'float',
        'kelembapan_udara' => 'float',
        'kelembapan_tanah' => 'float',
        'ph_tanah'         => 'float',
        'created_at'       => 'datetime',
    ];

    public function zona(): BelongsTo
    {
        return $this->belongsTo(Zona::class);
    }
}