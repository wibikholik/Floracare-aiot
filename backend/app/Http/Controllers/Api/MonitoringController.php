<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\DataSensor;
use App\Models\PerintahPenyiraman;
use App\Models\Zona;
use Illuminate\Http\Request;

class MonitoringController extends Controller
{
    // GET /api/monitoring : ringkasan semua zona (untuk layar monitoring)
    public function ringkasan()
    {
        $data = Zona::with('pengaturanOtomasi')
            ->orderBy('nama_zona')
            ->get()
            ->map(fn (Zona $z) => $this->bentuk($z));

        return response()->json([
            'status'  => 200,
            'message' => 'Monitoring semua zona',
            'data'    => $data,
        ], 200);
    }

    // GET /api/zona/{zona}/monitoring : kondisi terbaru satu zona
    public function terbaru(Zona $zona)
    {
        $zona->load('pengaturanOtomasi');

        return response()->json([
            'status'  => 200,
            'message' => 'Monitoring zona',
            'data'    => $this->bentuk($zona),
        ], 200);
    }

    // GET /api/zona/{zona}/monitoring/riwayat?jam=24 : data untuk grafik
    public function riwayat(Request $request, Zona $zona)
    {
        $jam = min(max((int) $request->query('jam', 24), 1), 72);

        $data = DataSensor::where('zona_id', $zona->id)
            ->where('created_at', '>=', now()->subHours($jam))
            ->orderBy('created_at')
            ->get(['kelembapan_tanah', 'suhu', 'kelembapan_udara', 'ph_tanah', 'created_at']);

        // Batasi sekitar 200 titik supaya ringan di HP
        if ($data->count() > 200) {
            $langkah = (int) ceil($data->count() / 200);
            $data = $data->values()->filter(fn ($_, $i) => $i % $langkah === 0)->values();
        }

        return response()->json([
            'status'  => 200,
            'message' => 'Riwayat sensor',
            'data'    => $data,
        ], 200);
    }

    private function bentuk(Zona $zona): array
    {
        $sensor = DataSensor::where('zona_id', $zona->id)->latest('id')->first();
        $p = $zona->pengaturanOtomasi;

        // Tidak ada data, atau data terakhir lebih dari 10 menit lalu → offline
        $offline = !$sensor || $sensor->created_at->lt(now()->subMinutes(10));

        $status = 'normal';
        if ($offline) {
            $status = 'offline';
        } elseif ($p && $sensor->kelembapan_tanah !== null && $sensor->kelembapan_tanah < $p->batas_kelembapan_min) {
            $status = 'kering';
        } elseif ($p && $sensor->kelembapan_tanah !== null && $sensor->kelembapan_tanah > $p->batas_kelembapan_maks) {
            $status = 'basah';
        }

        $aktif = PerintahPenyiraman::where('zona_id', $zona->id)
            ->aktif()
            ->latest('id')
            ->first(['id', 'sumber', 'status', 'durasi_detik', 'campur_pupuk']);

        return [
            'zona_id'        => $zona->id,
            'nama_zona'      => $zona->nama_zona,
            'status'         => $status,
            'sensor'         => $sensor ? [
                'suhu'             => $sensor->suhu,
                'kelembapan_udara' => $sensor->kelembapan_udara,
                'kelembapan_tanah' => $sensor->kelembapan_tanah,
                'ph_tanah'         => $sensor->ph_tanah,
                'waktu'            => $sensor->created_at,
            ] : null,
            'otomatis_aktif' => (bool) $p?->otomatis_aktif,
            'perintah_aktif' => $aktif,
        ];
    }
}