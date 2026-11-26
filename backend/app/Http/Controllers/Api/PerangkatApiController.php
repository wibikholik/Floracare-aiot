<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\DataSensor;
use App\Models\PerintahPenyiraman;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

// Endpoint yang dipanggil ALAT (ESP32), bukan aplikasi petani
class PerangkatApiController extends Controller
{
    // POST /api/perangkat/data-sensor
    public function kirimData(Request $request)
    {
        $perangkat = $request->attributes->get('perangkat');

        $data = $request->validate([
            'suhu'             => 'nullable|numeric|between:-20,80',
            'kelembapan_udara' => 'nullable|numeric|between:0,100',
            'kelembapan_tanah' => 'nullable|numeric|between:0,100',
            'ph_tanah'         => 'nullable|numeric|between:0,14',
        ]);

        DataSensor::create($data + ['zona_id' => $perangkat->zona_id]);

        return response()->json(['status' => 201, 'message' => 'ok'], 201);
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
                'status'       => PerintahPenyiraman::DIKIRIM,
                'dikirim_pada' => now(),
            ]);

            return $p;
        });

        return response()->json([
            'status'  => 200,
            'message' => $perintah ? 'Ada perintah' : 'Tidak ada perintah',
            'data'    => $perintah ? [
                'id'           => $perintah->id,
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
                'status'  => 409,
                'message' => 'Perintah tidak dalam status dikirim',
            ], 409);
        }

        $data = $request->validate([
            'berhasil' => 'required|boolean',
            'catatan'  => 'nullable|string|max:255',
        ]);

        $perintah->selesaikan($data['berhasil'], $data['catatan'] ?? null);

        return response()->json(['status' => 200, 'message' => 'Perintah diselesaikan'], 200);
    }
}