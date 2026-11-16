<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Zona;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class ZonaController extends Controller
{
    // GET /api/zona : daftar zona (beserta jumlah tanaman)
    public function index()
    {
        $zona = Zona::withCount('tanaman')
            ->orderBy('nama_zona')
            ->get();

        return response()->json([
            'status'  => 200,
            'message' => 'Daftar zona',
            'data'    => $zona,
        ], 200);
    }

    // POST /api/zona : tambah zona
    public function store(Request $request)
    {
        $data = $request->validate([
            'nama_zona' => 'required|string|max:255|unique:zona,nama_zona',
            'deskripsi' => 'nullable|string',
        ], [
            'nama_zona.required' => 'Nama zona wajib diisi',
            'nama_zona.unique'   => 'Nama zona sudah dipakai',
        ]);

        $zona = Zona::create($data);

        return response()->json([
            'status'  => 201,
            'message' => 'Zona berhasil ditambahkan',
            'data'    => $zona,
        ], 201);
    }

    // GET /api/zona/{id} : detail satu zona
    public function show(string $id)
    {
        $zona = Zona::withCount('tanaman')->find($id);

        if (!$zona) {
            return $this->tidakDitemukan();
        }

        return response()->json([
            'status'  => 200,
            'message' => 'Detail zona',
            'data'    => $zona,
        ], 200);
    }

    // PUT/PATCH /api/zona/{id} : ubah zona
    public function update(Request $request, string $id)
    {
        $zona = Zona::find($id);

        if (!$zona) {
            return $this->tidakDitemukan();
        }

        $data = $request->validate([
            'nama_zona' => [
                'sometimes', 'required', 'string', 'max:255',
                Rule::unique('zona', 'nama_zona')->ignore($zona->id),
            ],
            'deskripsi' => 'nullable|string',
        ], [
            'nama_zona.required' => 'Nama zona wajib diisi',
            'nama_zona.unique'   => 'Nama zona sudah dipakai',
        ]);

        $zona->update($data);

        return response()->json([
            'status'  => 200,
            'message' => 'Zona berhasil diperbarui',
            'data'    => $zona,
        ], 200);
    }

    // DELETE /api/zona/{id} : hapus zona
    // Tanaman di zona ini tidak ikut terhapus, zona_id-nya menjadi NULL.
    public function destroy(string $id)
    {
        $zona = Zona::find($id);

        if (!$zona) {
            return $this->tidakDitemukan();
        }

        $zona->delete();

        return response()->json([
            'status'  => 200,
            'message' => 'Zona berhasil dihapus',
        ], 200);
    }

    private function tidakDitemukan()
    {
        return response()->json([
            'status'  => 404,
            'message' => 'Zona tidak ditemukan',
        ], 404);
    }
}
