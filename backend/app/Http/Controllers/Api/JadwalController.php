<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\JadwalPenyiraman;
use App\Models\Zona;
use Illuminate\Http\Request;

class JadwalController extends Controller
{
    // GET /api/zona/{zona}/jadwal
    public function index(Zona $zona)
    {
        $data = JadwalPenyiraman::where('zona_id', $zona->id)->orderBy('jam')->get();

        return response()->json([
            'status'  => 200,
            'message' => 'Daftar jadwal penyiraman',
            'data'    => $data,
        ], 200);
    }

    // POST /api/zona/{zona}/jadwal
    public function store(Request $request, Zona $zona)
    {
        $jadwal = $zona->jadwalPenyiraman()->create($this->validasi($request));

        return response()->json([
            'status'  => 201,
            'message' => 'Jadwal ditambahkan',
            'data'    => $jadwal,
        ], 201);
    }

    // PUT /api/zona/{zona}/jadwal/{jadwal}
    public function update(Request $request, Zona $zona, JadwalPenyiraman $jadwal)
    {
        abort_unless((int) $jadwal->zona_id === (int) $zona->id, 404);

        $jadwal->update($this->validasi($request));

        return response()->json([
            'status'  => 200,
            'message' => 'Jadwal diperbarui',
            'data'    => $jadwal,
        ], 200);
    }

    // DELETE /api/zona/{zona}/jadwal/{jadwal}
    public function destroy(Zona $zona, JadwalPenyiraman $jadwal)
    {
        abort_unless((int) $jadwal->zona_id === (int) $zona->id, 404);

        $jadwal->delete();

        return response()->json([
            'status'  => 200,
            'message' => 'Jadwal dihapus',
        ], 200);
    }

    private function validasi(Request $request): array
    {
        $data = $request->validate([
            'hari'         => 'required|array|min:1',
            'hari.*'       => 'integer|between:1,7|distinct',
            'jam'          => 'required|date_format:H:i',
            'durasi_detik' => 'required|integer|min:5|max:300',
            'campur_pupuk' => 'boolean',
            'aktif'        => 'boolean',
        ], [
            'hari.required'    => 'Pilih minimal satu hari',
            'jam.date_format'  => 'Format jam harus HH:MM',
            'durasi_detik.min' => 'Durasi minimal 5 detik',
        ]);

        sort($data['hari']);
        $data['hari'] = array_values($data['hari']);

        return $data;
    }
}