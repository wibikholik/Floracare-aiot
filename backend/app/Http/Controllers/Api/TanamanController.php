<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Tanaman;
use Illuminate\Http\Request;

class TanamanController extends Controller
{
    // GET /api/tanaman : daftar tanaman milik pengguna yang login
    public function index(Request $request)
    {
        $tanaman = Tanaman::where('user_id', $request->user()->id)
            ->latest()
            ->get();

        return response()->json([
            'status'  => 200,
            'message' => 'Daftar tanaman',
            'data'    => $tanaman,
        ], 200);
    }

    // POST /api/tanaman : tambah tanaman
    public function store(Request $request)
    {
        $data = $request->validate([
            'nama'    => 'required|string|max:255',
            'jenis'   => 'nullable|string|max:255',
            'lokasi'  => 'nullable|string|max:255',
            'status'  => 'nullable|string|max:50',
            'catatan' => 'nullable|string',
        ], [
            'nama.required' => 'Nama tanaman wajib diisi',
        ]);

        $data['status']  = $data['status'] ?? 'sehat';
        $data['user_id'] = $request->user()->id;

        $tanaman = Tanaman::create($data);

        return response()->json([
            'status'  => 201,
            'message' => 'Tanaman berhasil ditambahkan',
            'data'    => $tanaman,
        ], 201);
    }

    // GET /api/tanaman/{id} : detail satu tanaman
    public function show(Request $request, string $id)
    {
        $tanaman = $this->cari($request, $id);

        if (!$tanaman) {
            return $this->tidakDitemukan();
        }

        return response()->json([
            'status'  => 200,
            'message' => 'Detail tanaman',
            'data'    => $tanaman,
        ], 200);
    }

    // PUT/PATCH /api/tanaman/{id} : ubah tanaman
    public function update(Request $request, string $id)
    {
        $tanaman = $this->cari($request, $id);

        if (!$tanaman) {
            return $this->tidakDitemukan();
        }

        $data = $request->validate([
            'nama'    => 'sometimes|required|string|max:255',
            'jenis'   => 'nullable|string|max:255',
            'lokasi'  => 'nullable|string|max:255',
            'status'  => 'nullable|string|max:50',
            'catatan' => 'nullable|string',
        ], [
            'nama.required' => 'Nama tanaman wajib diisi',
        ]);

        $tanaman->update($data);

        return response()->json([
            'status'  => 200,
            'message' => 'Tanaman berhasil diperbarui',
            'data'    => $tanaman,
        ], 200);
    }

    // DELETE /api/tanaman/{id} : hapus tanaman
    public function destroy(Request $request, string $id)
    {
        $tanaman = $this->cari($request, $id);

        if (!$tanaman) {
            return $this->tidakDitemukan();
        }

        $tanaman->delete();

        return response()->json([
            'status'  => 200,
            'message' => 'Tanaman berhasil dihapus',
        ], 200);
    }

    // Hanya mencari tanaman milik pengguna yang sedang login
    private function cari(Request $request, string $id): ?Tanaman
    {
        return Tanaman::where('user_id', $request->user()->id)
            ->where('id', $id)
            ->first();
    }

    private function tidakDitemukan()
    {
        return response()->json([
            'status'  => 404,
            'message' => 'Tanaman tidak ditemukan',
        ], 404);
    }
}