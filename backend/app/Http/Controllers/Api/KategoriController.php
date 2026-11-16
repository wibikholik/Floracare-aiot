<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Kategori;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class KategoriController extends Controller
{
    // GET /api/kategori : daftar kategori (beserta jumlah tanaman)
    public function index()
    {
        $kategori = Kategori::withCount('tanaman')
            ->orderBy('nama')
            ->get();

        return response()->json([
            'status'  => 200,
            'message' => 'Daftar kategori',
            'data'    => $kategori,
        ], 200);
    }

    // POST /api/kategori : tambah kategori
    public function store(Request $request)
    {
        $data = $request->validate([
            'nama'      => 'required|string|max:255|unique:kategori,nama',
            'deskripsi' => 'nullable|string',
        ], [
            'nama.required' => 'Nama kategori wajib diisi',
            'nama.unique'   => 'Nama kategori sudah dipakai',
        ]);

        $kategori = Kategori::create($data);

        return response()->json([
            'status'  => 201,
            'message' => 'Kategori berhasil ditambahkan',
            'data'    => $kategori,
        ], 201);
    }

    // GET /api/kategori/{id} : detail satu kategori
    public function show(string $id)
    {
        $kategori = Kategori::withCount('tanaman')->find($id);

        if (!$kategori) {
            return $this->tidakDitemukan();
        }

        return response()->json([
            'status'  => 200,
            'message' => 'Detail kategori',
            'data'    => $kategori,
        ], 200);
    }

    // PUT/PATCH /api/kategori/{id} : ubah kategori
    public function update(Request $request, string $id)
    {
        $kategori = Kategori::find($id);

        if (!$kategori) {
            return $this->tidakDitemukan();
        }

        $data = $request->validate([
            'nama'      => [
                'sometimes', 'required', 'string', 'max:255',
                Rule::unique('kategori', 'nama')->ignore($kategori->id),
            ],
            'deskripsi' => 'nullable|string',
        ], [
            'nama.required' => 'Nama kategori wajib diisi',
            'nama.unique'   => 'Nama kategori sudah dipakai',
        ]);

        $kategori->update($data);

        return response()->json([
            'status'  => 200,
            'message' => 'Kategori berhasil diperbarui',
            'data'    => $kategori,
        ], 200);
    }

    // DELETE /api/kategori/{id} : hapus kategori
    // Tanaman yang memakai kategori ini tidak ikut terhapus,
    // kolom kategori_id-nya otomatis menjadi NULL (nullOnDelete).
    public function destroy(string $id)
    {
        $kategori = Kategori::find($id);

        if (!$kategori) {
            return $this->tidakDitemukan();
        }

        $kategori->delete();

        return response()->json([
            'status'  => 200,
            'message' => 'Kategori berhasil dihapus',
        ], 200);
    }

    private function tidakDitemukan()
    {
        return response()->json([
            'status'  => 404,
            'message' => 'Kategori tidak ditemukan',
        ], 404);
    }
}
