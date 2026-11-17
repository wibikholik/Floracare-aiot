<?php

use App\Http\Controllers\Api\DeteksiPenyakitController;
use App\Http\Controllers\Api\KategoriController;
use App\Http\Controllers\Api\TanamanController;
use App\Http\Controllers\Api\ZonaController;
use App\Http\Controllers\AuthController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

// Rute publik (tanpa token)
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// Rute yang wajib memakai token (Bearer Token Sanctum)
Route::middleware('auth:sanctum')->group(function () {

    // Cek sesi aktif & logout
    Route::get('/user', function (Request $request) {
        return response()->json([
            'status' => 200,
            'user'   => $request->user(),
        ], 200);
    });
    Route::post('/logout', [AuthController::class, 'logout']);

    // CRUD kategori, zona, tanaman:
    // GET /api/{resource} (index), POST (store), GET /{id} (show),
    // PUT /{id} (update), DELETE /{id} (destroy)
    Route::apiResource('kategori', KategoriController::class);
    Route::apiResource('zona', ZonaController::class);
    Route::apiResource('tanaman', TanamanController::class);

    // Deteksi penyakit/hama:
    // POST   /api/deteksi-penyakit        -> store   (kirim foto, maks 10x/menit per user)
    // GET    /api/deteksi-penyakit        -> index   (riwayat, bisa ?tanaman_id= & ?status_kondisi=)
    // GET    /api/deteksi-penyakit/{id}   -> show    (detail)
    // PUT    /api/deteksi-penyakit/{id}   -> update  (sudah_ditangani, catatan)
    // DELETE /api/deteksi-penyakit/{id}   -> destroy (hapus)
    Route::post('deteksi-penyakit', [DeteksiPenyakitController::class, 'store'])
        ->middleware('throttle:10,1');
    Route::apiResource('deteksi-penyakit', DeteksiPenyakitController::class)
        ->except(['store']);
});