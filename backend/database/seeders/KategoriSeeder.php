<?php

namespace Database\Seeders;

use App\Models\Kategori;
use Illuminate\Database\Seeder;

class KategoriSeeder extends Seeder
{
    public function run(): void
    {
        $daftar = [
            ['nama' => 'Tanaman Hias Daun',   'deskripsi' => 'Tanaman yang dinikmati dari keindahan daunnya'],
            ['nama' => 'Tanaman Berbunga',    'deskripsi' => 'Tanaman yang dinikmati dari bunganya'],
            ['nama' => 'Kaktus & Sukulen',    'deskripsi' => 'Tanaman tahan kering dengan penyiraman sedikit'],
            ['nama' => 'Tanaman Gantung',     'deskripsi' => 'Tanaman yang ditata dengan cara digantung'],
        ];

        // firstOrCreate: aman dijalankan berulang, tidak membuat data ganda
        foreach ($daftar as $item) {
            Kategori::firstOrCreate(['nama' => $item['nama']], $item);
        }
    }
}