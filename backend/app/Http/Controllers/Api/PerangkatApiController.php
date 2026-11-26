<?php

namespace App\\Http\\Controllers\\Api;

use App\\Http\\Controllers\\Controller;
use App\\Models\\DataSensor;
use App\\Models\\SampelSensor;
use App\\Models\\PerintahPenyiraman;
use Illuminate\\Http\\Request;
use Illuminate\\Support\\Facades\\DB;

// Endpoint yang dipanggil ALAT (ESP32), bukan aplikasi petani
class PerangkatApiController extends Controller
{
    // POST /api/perangkat/data-sensor
    // Mendukung format lama (satu sensor tanah) dan format baru (array sampel)
    public function kirimData(Request $request)
    {
        $perangkat = $request->attributes->get('perangkat');

        $data = $request->validate([
            'suhu' => 'nullable|numeric|between:-20,80',
            'kelembapan_udara' => 'nullable|numeric|between:0,100',
            // Format lama tetap diterima untuk kompatibilitas
            'kelembapan_tanah' => 'nullable|numeric|between:0,100',
            'ph_tanah' => 'nullable|numeric|between:0,14',
            // Format multi-sampel baru
            'samples' => 'nullable|array|min:1|max:8',
            'samples.*.nomor' => 'required_with:samples|integer|between:1,8|distinct',
            'samples.*.kelembapan_tanah' => 'required_with:samples|numeric|between:0,100',
            'samples.*.ph_tanah' => 'nullable|numeric|between:0,14',
        ]);

        DB::transaction(function () use ($data, $perangkat) {
            $samples = $data['samples'] ?? [];

            $kelembapan = isset($data['kelembapan_tanah'])
                ? (float) $data['kelembapan_tanah']
                : null;
            $ph = isset($data['ph_tanah']) ? (float) $data['ph_tanah'] : null;

            if (!empty($samples)) {
                $kelembapan = array_sum(array_map(
                    fn ($sample) => (float) $sample['kelembapan_tanah'],
                    $samples
                )) / count($samples);

                $nilaiPh = array_filter(array_map(
                    fn ($sample) => isset($sample['ph_tanah']) ? (float) $sample['ph_tanah'] : null,
                    $samples
                ), fn ($value) => $value !== null);

                $ph = count($nilaiPh) ? array_sum($nilaiPh) / count($nilaiPh) : null;
            }

            $sensor = DataSensor::create([
                'zona_id' => $perangkat->zona_id,
                'suhu' => $data['suhu'] ?? null,
                'kelembapan_udara' => $data['kelembapan_udara'] ?? null,
                'kelembapan_tanah' => $kelembapan,
                'ph_tanah' => $ph,
            ]);

            foreach ($samples as $sample) {
                $sampelSensor = SampelSensor::firstOrCreate(
                    [
                        'zona_id' => $perangkat->zona_id,
                        'nomor' => $sample['nomor'],
                    ],
                    [
                        'nama' => 'Sample ' . $sample['nomor'],
                    ]
                );

                $sensor->sampel()->create([
                    'sampel_sensor_id' => $sampelSensor->id,
                    'kelembapan_tanah' => $sample['kelembapan_tanah'],
                    'ph_tanah' => $sample['ph_tanah'] ?? null,
                ]);
            }
        });

        return response()->json([
            'status' => 201,
            'message' => 'Data sensor berhasil disimpan',
        ], 201);
    }

    // GET /api/perangkat/perintah : ambil 1 perintah pending (data = null jika kosong)
    public function ambilPerintah(Request $request)
    {
        $perangkat = $request->attributes->get('perangkat');

        $perintah = DB::transaction(function () use ($perangkat) {
            $p = PerintahPenyiraman::where('zona_id', $perangkat->zona_id)
                ->where('status', PerintahPenyiraman::PENDING)
                ->oldest('id')
                ->lockForUpdate()
                ->first();

            $p?->update([
                'status' => PerintahPenyiraman::DIKIRIM,
                'dikirim_pada' => now(),
            ]);

            return $p;
        });

        return response()->json([
            'status' => 200,
            'message' => $perintah ? 'Ada perintah' : 'Tidak ada perintah',
            'data' => $perintah ? [
                'id' => $perintah->id,
                'durasi_detik' => $perintah->durasi_detik,
                'campur_pupuk' => $perintah->campur_pupuk,
            ] : null,
        ], 200);
    }

    // POST /api/perangkat/perintah/{perintah}/selesai
    public function selesai(Request $request, PerintahPenyiraman $perintah)
    {
        $perangkat = $request->attributes->get('perangkat');
        abort_unless((int) $perintah->zona_id === (int) $perangkat->zona_id, 403);

        if ($perintah->status !== PerintahPenyiraman::DIKIRIM) {
            return response()->json([
                'status' => 409,
                'message' => 'Perintah tidak dalam status dikirim',
            ], 409);
        }

        $data = $request->validate([
            'berhasil' => 'required|boolean',
            'catatan' => 'nullable|string|max:255',
        ]);

        $perintah->selesaikan($data['berhasil'], $data['catatan'] ?? null);

        return response()->json(['status' => 200, 'message' => 'Perintah diselesaikan'], 200);
    }
}
