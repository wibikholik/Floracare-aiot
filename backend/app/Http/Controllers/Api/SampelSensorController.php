<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\SampelSensor;
use App\Models\Tanaman;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class SampelSensorController extends Controller
{
    private const RELASI = ['tanaman:id,nama,kategori_id,zona_id', 'tanaman.kategori:id,nama', 'tanaman.zona:id,nama_zona', 'zona:id,nama_zona'];

    public function index(Request $request)
    {
        $query = SampelSensor::with(self::RELASI)
            ->whereHas('tanaman', fn ($q) => $q->where('user_id', $request->user()->id));

        if ($request->filled('tanaman_id')) {
            $query->where('tanaman_id', $request->query('tanaman_id'));
        }

        return response()->json([
            'status' => 200,
            'message' => 'Daftar sampel sensor',
            'data' => $query->orderBy('zona_id')->orderBy('nomor')->get(),
        ]);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'tanaman_id' => ['required', 'integer', 'exists:tanaman,id'],
            'nama' => ['nullable', 'string', 'max:255'],
        ]);

        $tanaman = Tanaman::where('user_id', $request->user()->id)
            ->findOrFail($data['tanaman_id']);

        $nomor = (SampelSensor::where('zona_id', $tanaman->zona_id)->max('nomor') ?? 0) + 1;
        if ($nomor > 255) {
            return response()->json(['status' => 422, 'message' => 'Jumlah sampel pada zona sudah mencapai batas'], 422);
        }

        $sampel = SampelSensor::create([
            'tanaman_id' => $tanaman->id,
            'zona_id' => $tanaman->zona_id,
            'nomor' => $nomor,
            'nama' => $data['nama'] ?? null,
        ])->load(self::RELASI);

        return response()->json(['status' => 201, 'message' => 'Sampel berhasil ditambahkan', 'data' => $sampel], 201);
    }

    public function show(Request $request, string $id)
    {
        $sampel = $this->cari($request, $id);
        if (!$sampel) return response()->json(['status' => 404, 'message' => 'Sampel tidak ditemukan'], 404);

        return response()->json(['status' => 200, 'message' => 'Detail sampel', 'data' => $sampel], 200);
    }

    public function update(Request $request, string $id)
    {
        $sampel = $this->cari($request, $id);
        if (!$sampel) return response()->json(['status' => 404, 'message' => 'Sampel tidak ditemukan'], 404);

        $data = $request->validate([
            'tanaman_id' => ['sometimes', 'required', 'integer', 'exists:tanaman,id'],
            'nama' => ['nullable', 'string', 'max:255'],
        ]);

        if (isset($data['tanaman_id'])) {
            $tanaman = Tanaman::where('user_id', $request->user()->id)->findOrFail($data['tanaman_id']);
            $sampel->tanaman_id = $tanaman->id;
            $sampel->zona_id = $tanaman->zona_id;
        }
        if (array_key_exists('nama', $data)) $sampel->nama = $data['nama'];
        $sampel->save();

        return response()->json(['status' => 200, 'message' => 'Sampel berhasil diperbarui', 'data' => $sampel->load(self::RELASI)], 200);
    }

    public function destroy(Request $request, string $id)
    {
        $sampel = $this->cari($request, $id);
        if (!$sampel) return response()->json(['status' => 404, 'message' => 'Sampel tidak ditemukan'], 404);

        $sampel->delete();
        return response()->json(['status' => 200, 'message' => 'Sampel berhasil dihapus'], 200);
    }

    private function cari(Request $request, string $id): ?SampelSensor
    {
        return SampelSensor::with(self::RELASI)
            ->whereHas('tanaman', fn ($q) => $q->where('user_id', $request->user()->id))
            ->find($id);
    }
}
