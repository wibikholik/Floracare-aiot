<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class DeteksiPenyakit extends Model
{
    protected $table = 'deteksi_penyakit';

    protected $fillable = [
        'user_id', 'tanaman_id', 'nama_tanaman_terdeteksi', 'foto',
        'hasil_klasifikasi', 'jenis_masalah', 'tingkat_keyakinan',
        'status_kondisi', 'saran_penanganan', 'sudah_ditangani',
        'catatan', 'provider',
    ];

    protected $casts = [
        'tingkat_keyakinan' => 'float',
        'sudah_ditangani'   => 'boolean',
    ];

    protected $appends = ['foto_url'];

    public function getFotoUrlAttribute(): string
    {
        return asset('storage/' . $this->foto);
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function tanaman(): BelongsTo
    {
        return $this->belongsTo(Tanaman::class);
    }
}