<?php

use App\Http\Controllers\Api\DeteksiPenyakitController;
use App\Http\Controllers\Api\KategoriController;
use App\Http\Controllers\Api\TanamanController;
use App\Http\Controllers\Api\ZonaController;
use App\Http\Controllers\AuthController;
use Illuminate\Http\Request;
use App\Http\Controllers\Api\MonitoringController;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\JadwalController;
use App\Http\Controllers\Api\PenyiramanController;
use App\Http\Controllers\Api\PerangkatApiController;
use App\Http\Middleware\AuthPerangkat;

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
    Route::apiResource('tanaman', TanamanController::class);\n    Route::apiResource('sampel-sensor', SampelSensorController::class);

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

        // Monitoring lingkungan
        // Monitoring & kontrol penyiraman
    Route::get('monitoring', [MonitoringController::class, 'ringkasan']);

    Route::prefix('zona/{zona}')->group(function () {
        Route::get('monitoring', [MonitoringController::class, 'terbaru']);
        Route::get('monitoring/riwayat', [MonitoringController::class, 'riwayat']);

        Route::post('siram', [PenyiramanController::class, 'siram']);
        Route::get('otomasi', [PenyiramanController::class, 'otomasi']);
        Route::put('otomasi', [PenyiramanController::class, 'ubahOtomasi']);
        Route::get('riwayat-penyiraman', [PenyiramanController::class, 'riwayat']);

        Route::apiResource('jadwal', JadwalController::class)->except('show');
    });

    Route::post('perintah/{perintah}/batal', [PenyiramanController::class, 'batal']);
    // Rute untuk alat (ESP32), autentikasi lewat header X-Device-Token
Route::middleware([AuthPerangkat::class, 'throttle:120,1'])
    ->prefix('perangkat')
    ->group(function () {
        Route::post('data-sensor', [PerangkatApiController::class, 'kirimData']);
        Route::get('perintah', [PerangkatApiController::class, 'ambilPerintah']);
        Route::post('perintah/{perintah}/selesai', [PerangkatApiController::class, 'selesai']);
    });
});