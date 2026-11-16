<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Tanaman;
use Illuminate\Http\Request;

class TanamanController extends Controller
{
    // Relasi yang ikut dimuat supaya aplikasi langsung dapat nama kategori & zona
    private const RELASI = ['kategori:id,nama', 'zona:id,nama_zona'];

    // GET /api/tanaman : daftar tanaman milik pengguna yang login
    // Filter opsional: ?kategori_id=1 &zona_id=2
    public function index(Request $request)
    {
        $query = Tanaman::with(self::RELASI)
            ->where('user_id', $request->user()->id);

        if ($request->filled('kategori_id')) {
            $query->where('kategori_id', $request->query('kategori_id'));
        }

        if ($request->filled('zona_id')) {
            $query->where('zona_id', $request->query('zona_id'));
        }

        $tanaman = $query->latest()->get();

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
            'kategori_id' => 'nullable|integer|exists:kategori,id',
            'zona_id'     => 'nullable|integer|exists:zona,id',
            'nama'        => 'required|string|max:255',
            'jenis'       => 'nullable|string|max:255',
            'lokasi'      => 'nullable|string|max:255',
            'status'      => 'nullable|string|max:50',
            'catatan'     => 'nullable|string',
        ], [
            'nama.required'      => 'Nama tanaman wajib diisi',
            'kategori_id.exists' => 'Kategori tidak ditemukan',
            'zona_id.exists'     => 'Zona tidak ditemukan',
        ]);

        $data['status']  = $data['status'] ?? 'sehat';
        $data['user_id'] = $request->user()->id;

        $tanaman = Tanaman::create($data)->load(self::RELASI);

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
            'kategori_id' => 'nullable|integer|exists:kategori,id',
            'zona_id'     => 'nullable|integer|exists:zona,id',
            'nama'        => 'sometimes|required|string|max:255',
            'jenis'       => 'nullable|string|max:255',
            'lokasi'      => 'nullable|string|max:255',
            'status'      => 'nullable|string|max:50',
            'catatan'     => 'nullable|string',
        ], [
            'nama.required'      => 'Nama tanaman wajib diisi',
            'kategori_id.exists' => 'Kategori tidak ditemukan',
            'zona_id.exists'     => 'Zona tidak ditemukan',
        ]);

        $tanaman->update($data);

        return response()->json([
            'status'  => 200,
            'message' => 'Tanaman berhasil diperbarui',
            'data'    => $tanaman->load(self::RELASI),
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
        return Tanaman::with(self::RELASI)
            ->where('user_id', $request->user()->id)
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
