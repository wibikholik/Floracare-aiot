<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class SampelSensor extends Model
{
    protected $table = 'sampel_sensor';

    protected $fillable = ['zona_id', 'tanaman_id', 'nomor', 'nama'];

    public function zona(): BelongsTo
    {
        return $this->belongsTo(Zona::class, 'zona_id');
    }

    public function tanaman(): BelongsTo
    {
        return $this->belongsTo(Tanaman::class, 'tanaman_id');
    }

    public function data(): HasMany
    {
        return $this->hasMany(DataSensorSampel::class, 'sampel_sensor_id');
    }
}
