<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\DeteksiPenyakit;
use App\Models\Tanaman;
use App\Services\Deteksi\PenyakitDetector;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Throwable;

class DeteksiPenyakitController extends Controller
{
    public function index(Request $request)
    {
        $data = DeteksiPenyakit::with('tanaman:id,nama')
            ->where('user_id', $request->user()->id)
            ->when($request->tanaman_id, fn ($q, $id) => $q->where('tanaman_id', $id))
            ->when($request->status_kondisi, fn ($q, $s) => $q->where('status_kondisi', $s))
            ->latest()
            ->paginate(10);

        return response()->json(['success' => true, 'data' => $data]);
    }

    public function show(Request $request, int $id)
    {
        $data = $this->cariMilikUser($request, $id);

        return response()->json(['success' => true, 'data' => $data->load('tanaman:id,nama')]);
    }

    public function store(Request $request, PenyakitDetector $detector)
    {
        $validated = $request->validate([
            'foto'       => ['required', 'image', 'mimes:jpg,jpeg,png', 'max:4096'],
            'tanaman_id' => ['nullable', 'integer', 'exists:tanaman,id'],
        ]);

        // tanaman_id opsional: kalau diisi, harus milik user yang login
        $tanaman = null;
        if (!empty($validated['tanaman_id'])) {
            $tanaman = Tanaman::where('user_id', $request->user()->id)
                ->findOrFail($validated['tanaman_id']);
        }

        $file = $request->file('foto');
        $path = $file->store('deteksi', 'public');

        try {
            $hasil = $detector->analisis(
                Storage::disk('public')->get($path),
                $file->getMimeType(),
                $tanaman?->nama
            );
        } catch (Throwable $e) {
            Storage::disk('public')->delete($path);
            report($e);

            $kuotaHabis = $e->getCode() === 429;

            return response()->json([
                'success' => false,
                'message' => $kuotaHabis
                    ? 'Layanan deteksi sedang sibuk, coba lagi nanti.'
                    : 'Deteksi gagal diproses, coba lagi beberapa saat.',
            ], $kuotaHabis ? 429 : 502);
        }

        $deteksi = DeteksiPenyakit::create([
            'user_id'                 => $request->user()->id,
            'tanaman_id'              => $tanaman?->id,
            'nama_tanaman_terdeteksi' => $tanaman?->nama ?? $hasil->namaTanaman,
            'foto'                    => $path,
            'hasil_klasifikasi'       => $hasil->hasilKlasifikasi,
            'jenis_masalah'           => $hasil->jenisMasalah,
            'tingkat_keyakinan'       => $hasil->tingkatKeyakinan,
            'status_kondisi'          => $hasil->statusKondisi,
            'saran_penanganan'        => $hasil->saranPenanganan,
            'provider'                => $detector->nama(),
        ]);

        return response()->json(['success' => true, 'data' => $deteksi], 201);
    }

    // Tandai sudah ditangani dan/atau isi catatan
    public function update(Request $request, int $id)
    {
        $deteksi = $this->cariMilikUser($request, $id);

        $validated = $request->validate([
            'sudah_ditangani' => ['sometimes', 'boolean'],
            'catatan'         => ['sometimes', 'nullable', 'string', 'max:1000'],
        ]);

        $deteksi->update($validated);

        return response()->json(['success' => true, 'data' => $deteksi]);
    }

    public function destroy(Request $request, int $id)
    {
        $deteksi = $this->cariMilikUser($request, $id);

        Storage::disk('public')->delete($deteksi->foto);
        $deteksi->delete();

        return response()->json(['success' => true, 'message' => 'Riwayat deteksi dihapus.']);
    }

    private function cariMilikUser(Request $request, int $id): DeteksiPenyakit
    {
        return DeteksiPenyakit::where('user_id', $request->user()->id)->findOrFail($id);
    }
}