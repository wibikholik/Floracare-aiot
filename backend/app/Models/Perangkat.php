<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Str;

class Perangkat extends Model
{
    protected $table = 'perangkat';

    protected $fillable = ['zona_id', 'kode', 'nama', 'token', 'terakhir_online'];

    protected $hidden = ['token'];

    protected $casts = ['terakhir_online' => 'datetime'];

    public static function buatToken(): string
    {
        return Str::random(64);
    }

    public function zona(): BelongsTo
    {
        return $this->belongsTo(Zona::class);
    }

    // Dianggap online jika mengirim data dalam 5 menit terakhir
    public function getOnlineAttribute(): bool
    {
        return $this->terakhir_online && $this->terakhir_online->diffInMinutes() < 5;
    }
}