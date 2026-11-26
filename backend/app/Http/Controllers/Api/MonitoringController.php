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
        $data = Zona::with(['pengaturanOtomasi', 'tanaman.kategori', 'sampelSensor'])
            ->orderBy('nama_zona')
            ->get()
            ->map(fn (Zona $z) => $this->bentuk($z));

        return response()->json([
            'status' => 200,
            'message' => 'Monitoring semua zona',
            'data' => $data,
        ], 200);
    }

    // GET /api/zona/{zona}/monitoring : kondisi terbaru satu zona
    public function terbaru(Zona $zona)
    {
        $zona->load(['pengaturanOtomasi', 'tanaman.kategori', 'sampelSensor']);

        return response()->json([
            'status' => 200,
            'message' => 'Monitoring zona',
            'data' => $this->bentuk($zona),
        ], 200);
    }

    // GET /api/zona/{zona}/monitoring/riwayat?jam=24 : grafik rata-rata kelembapan
    public function riwayat(Request $request, Zona $zona)
    {
        $jam = min(max((int) $request->query('jam', 24), 1), 72);

        $data = DataSensor::where('zona_id', $zona->id)
            ->where('created_at', '>=', now()->subHours($jam))
            ->orderBy('created_at')
            ->get(['kelembapan_tanah', 'suhu', 'kelembapan_udara', 'ph_tanah', 'created_at']);

        if ($data->count() > 200) {
            $langkah = (int) ceil($data->count() / 200);
            $data = $data->values()->filter(fn ($_, $i) => $i % $langkah === 0)->values();
        }

        return response()->json([
            'status' => 200,
            'message' => 'Riwayat sensor',
            'data' => $data,
        ], 200);
    }

    private function bentuk(Zona $zona): array
    {
        $sensor = DataSensor::with('sampel.sampelSensor')
            ->where('zona_id', $zona->id)
            ->latest('id')
            ->first();

        $p = $zona->pengaturanOtomasi;
        $offline = !$sensor || !$sensor->created_at || $sensor->created_at->lt(now()->subMinutes(10));

        $sampelTerbaru = $sensor?->sampel ?? collect();
        $nilaiSampel = $sampelTerbaru->pluck('kelembapan_tanah')->filter(fn ($v) => $v !== null);
        $minimumSampel = $nilaiSampel->min();
        $rataSampel = $nilaiSampel->count() ? $nilaiSampel->avg() : $sensor?->kelembapan_tanah;

        $status = 'normal';
        if ($offline) {
            $status = 'offline';
        } elseif ($p && $minimumSampel !== null && $minimumSampel < $p->batas_kelembapan_min) {
            // Status ringkasan menandai zona kering jika salah satu sampel berada di bawah ambang
            $status = 'kering';
        } elseif ($p && $rataSampel !== null && $rataSampel > $p->batas_kelembapan_maks) {
            $status = 'basah';
        }

        $aktif = PerintahPenyiraman::where('zona_id', $zona->id)
            ->aktif()
            ->latest('id')
            ->first(['id', 'sumber', 'status', 'durasi_detik', 'campur_pupuk']);

        $tanaman = $zona->tanaman->map(fn ($t) => [
            'id' => $t->id,
            'nama' => $t->nama,
            'jenis' => $t->jenis,
            'kategori' => $t->kategori?->nama,
        ])->values();

        $samples = $sampelTerbaru->map(fn ($d) => [
            'sampel_sensor_id' => $d->sampel_sensor_id,
            'nomor' => $d->sampelSensor?->nomor,
            'nama' => $d->sampelSensor?->nama ?? ('Sample ' . ($d->sampelSensor?->nomor ?? '')),
            'kelembapan_tanah' => $d->kelembapan_tanah,
            'ph_tanah' => $d->ph_tanah,
        ])->values();

        return [
            'zona_id' => $zona->id,
            'nama_zona' => $zona->nama_zona,
            'tanaman' => $tanaman,
            'jumlah_tanaman' => $zona->tanaman->count(),
            'status' => $status,
            'sensor' => $sensor ? [
                'suhu' => $sensor->suhu,
                'kelembapan_udara' => $sensor->kelembapan_udara,
                // Nilai agregat hanya untuk ringkasan zona/grafik
                'kelembapan_tanah' => $sensor->kelembapan_tanah,
                'ph_tanah' => $sensor->ph_tanah,
                'waktu' => $sensor->created_at,
            ] : null,
            'sampel' => $samples,
            'otomatis_aktif' => (bool) $p?->otomatis_aktif,
            'batas_kelembapan_min' => $p?->batas_kelembapan_min,
            'batas_kelembapan_maks' => $p?->batas_kelembapan_maks,
            'durasi_detik' => $p?->durasi_detik,
            'jeda_menit' => $p?->jeda_menit,
            'perintah_aktif' => $aktif,
        ];
    }
}
