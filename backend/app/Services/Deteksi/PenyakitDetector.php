<?php

namespace App\Services\Deteksi;

interface PenyakitDetector
{
    /**
     * @param string|null $namaTanaman nama tanaman jika sudah diketahui; null = AI mengenali sendiri
     */
    public function analisis(string $isiFoto, string $mime, ?string $namaTanaman = null): HasilDeteksi;

    public function nama(): string;
}