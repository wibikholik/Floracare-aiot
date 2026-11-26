<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class DataSensorSampel extends Model
{
    protected $table = 'data_sensor_sampel';

    public $timestamps = false;

    protected $fillable = ['data_sensor_id', 'sampel_sensor_id', 'kelembapan_tanah', 'ph_tanah'];

    protected $casts = [
        'kelembapan_tanah' => 'float',
        'ph_tanah' => 'float',
    ];

    public function pembacaan(): BelongsTo
    {
        return $this->belongsTo(DataSensor::class, 'data_sensor_id');
    }

    public function sampelSensor(): BelongsTo
    {
        return $this->belongsTo(SampelSensor::class, 'sampel_sensor_id');
    }
}
