<?php

namespace Database\Seeders;

use App\Models\Zona;
use Illuminate\Database\Seeder;

class ZonaSeeder extends Seeder
{
    public function run(): void
    {
        // Prototipe memakai 2 zona
        $daftar = [
            ['nama_zona' => 'Zona 1', 'deskripsi' => 'Area penempatan tanaman zona 1'],
            ['nama_zona' => 'Zona 2', 'deskripsi' => 'Area penempatan tanaman zona 2'],
        ];

        foreach ($daftar as $item) {
            Zona::firstOrCreate(['nama_zona' => $item['nama_zona']], $item);
        }
    }
}