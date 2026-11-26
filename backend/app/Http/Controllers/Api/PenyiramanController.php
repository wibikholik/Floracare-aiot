<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\PengaturanOtomasi;
use App\Models\PerintahPenyiraman;
use App\Models\RiwayatPenyiraman;
use App\Models\Zona;
use Illuminate\Http\Request;

class PenyiramanController extends Controller
{
    // POST /api/zona/{zona}/siram : penyiraman manual
    public function siram(Request $request, Zona $zona)
    {
        $data = $request->validate([
            'durasi_detik' => 'required|integer|min:5|max:' . PerintahPenyiraman::DURASI_MAKS,
            'campur_pupuk' => 'boolean',
        ], [
            'durasi_detik.required' => 'Durasi penyiraman wajib diisi',
            'durasi_detik.min'      => 'Durasi minimal 5 detik',
            'durasi_detik.max'      => 'Durasi maksimal ' . PerintahPenyiraman::DURASI_MAKS . ' detik',
        ]);

        if (PerintahPenyiraman::where('zona_id', $zona->id)->aktif()->exists()) {
            return response()->json([
                'status'  => 409,
                'message' => 'Penyiraman di zona ini sedang berjalan atau menunggu alat',
            ], 409);
        }

        $perintah = PerintahPenyiraman::create([
            'zona_id'      => $zona->id,
            'sumber'       => 'manual',
            'durasi_detik' => $data['durasi_detik'],
            'campur_pupuk' => $data['campur_pupuk'] ?? false,
            'status'       => PerintahPenyiraman::PENDING,
        ]);

        return response()->json([
            'status'  => 201,
            'message' => 'Perintah penyiraman dikirim',
            'data'    => $perintah,
        ], 201);
    }

    // POST /api/perintah/{perintah}/batal : batalkan perintah yang belum diambil alat
    public function batal(PerintahPenyiraman $perintah)
    {
        if ($perintah->status !== PerintahPenyiraman::PENDING) {
            return response()->json([
                'status'  => 409,
                'message' => 'Perintah sudah diproses alat dan tidak bisa dibatalkan',
            ], 409);
        }

        $perintah->update([
            'status'       => PerintahPenyiraman::GAGAL,
            'selesai_pada' => now(),
            'catatan'      => 'Dibatalkan pengguna',
        ]);

        return response()->json([
            'status'  => 200,
            'message' => 'Perintah dibatalkan',
        ], 200);
    }

    // GET /api/zona/{zona}/otomasi
    public function otomasi(Zona $zona)
    {
        $p = PengaturanOtomasi::firstOrCreate(['zona_id' => $zona->id])->fresh();

        return response()->json([
            'status'  => 200,
            'message' => 'Pengaturan otomasi',
            'data'    => $p,
        ], 200);
    }

    // PUT /api/zona/{zona}/otomasi
    public function ubahOtomasi(Request $request, Zona $zona)
    {
        $data = $request->validate([
            'otomatis_aktif'        => 'required|boolean',
            'batas_kelembapan_min'  => 'required|integer|between:0,100',
            'batas_kelembapan_maks' => 'required|integer|between:0,100|gt:batas_kelembapan_min',
            'durasi_detik'          => 'required|integer|min:5|max:' . PerintahPenyiraman::DURASI_MAKS,
            'campur_pupuk'          => 'required|boolean',
            'jeda_menit'            => 'required|integer|between:1,1440',
        ], [
            'batas_kelembapan_maks.gt' => 'Batas maksimal harus lebih besar dari batas minimal',
        ]);

        $p = PengaturanOtomasi::updateOrCreate(['zona_id' => $zona->id], $data);

        return response()->json([
            'status'  => 200,
            'message' => 'Pengaturan otomasi disimpan',
            'data'    => $p,
        ], 200);
    }

    // GET /api/zona/{zona}/riwayat-penyiraman (paginate: data.data)
    public function riwayat(Zona $zona)
    {
        $data = RiwayatPenyiraman::where('zona_id', $zona->id)
            ->latest('mulai')
            ->paginate(20);

        return response()->json([
            'status'  => 200,
            'message' => 'Riwayat penyiraman',
            'data'    => $data,
        ], 200);
    }
}