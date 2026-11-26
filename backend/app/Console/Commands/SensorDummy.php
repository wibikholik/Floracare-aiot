<?php

namespace App\Console\Commands;

use App\Models\DataSensor;
use App\Models\PerintahPenyiraman;
use App\Models\Zona;
use Illuminate\Console\Command;

// SEMENTARA: pengganti alat asli. Nonaktifkan saat ESP32 sudah mengirim data.
class SensorDummy extends Command
{
    protected $signature = 'sensor:dummy';
    protected $description = 'Buat data sensor dummy dan simulasikan alat menyelesaikan perintah siram';

    public function handle(): int
    {
        foreach (Zona::all() as $zona) {
            // 1. Simulasi alat: ambil perintah pending lalu langsung selesai
            $perintah = PerintahPenyiraman::where('zona_id', $zona->id)
                ->where('status', PerintahPenyiraman::PENDING)
                ->oldest('id')
                ->first();

            $perintah?->update([
                'status'       => PerintahPenyiraman::DIKIRIM,
                'dikirim_pada' => now()->subSeconds(5),
            ]);

            // 2. Kelembapan tanah: turun pelan, naik setelah disiram
            $terakhir = DataSensor::where('zona_id', $zona->id)->latest('id')->first();
            $tanah = $terakhir?->kelembapan_tanah ?? 60;
            $tanah = $perintah ? $tanah + 20 : $tanah - mt_rand(0, 15) / 10;
            $tanah = max(10, min(95, $tanah));

            DataSensor::create([
                'zona_id'          => $zona->id,
                'suhu'             => round(28 + mt_rand(-20, 20) / 10, 1),
                'kelembapan_udara' => mt_rand(55, 80),
                'kelembapan_tanah' => round($tanah, 1),
                'ph_tanah'         => round(6.5 + mt_rand(-3, 3) / 10, 1),
            ]);

            $perintah?->selesaikan(true, 'Simulasi dummy');
        }

        return self::SUCCESS;
    }
}