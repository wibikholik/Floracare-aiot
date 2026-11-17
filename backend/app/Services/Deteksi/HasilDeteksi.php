<?php

namespace App\Services\Deteksi;

class HasilDeteksi
{
    public function __construct(
        public string $hasilKlasifikasi,
        public ?string $jenisMasalah,
        public float $tingkatKeyakinan,
        public string $statusKondisi,   // sehat | terindikasi_hama | sakit | tidak_yakin
        public string $saranPenanganan,
        public ?string $namaTanaman = null, // nama tanaman hasil kenali AI
    ) {}
}