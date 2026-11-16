<?php

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

    // CRUD kategori:
    // GET    /api/kategori          -> index   (daftar)
    // POST   /api/kategori          -> store   (tambah)
    // GET    /api/kategori/{id}     -> show    (detail)
    // PUT    /api/kategori/{id}     -> update  (ubah)
    // DELETE /api/kategori/{id}     -> destroy (hapus)
    Route::apiResource('kategori', KategoriController::class);

    // CRUD zona:
    // GET    /api/zona              -> index   (daftar)
    // POST   /api/zona              -> store   (tambah)
    // GET    /api/zona/{id}         -> show    (detail)
    // PUT    /api/zona/{id}         -> update  (ubah)
    // DELETE /api/zona/{id}         -> destroy (hapus)
    Route::apiResource('zona', ZonaController::class);

    // CRUD tanaman:
    // GET    /api/tanaman           -> index   (daftar)
    // POST   /api/tanaman           -> store   (tambah)
    // GET    /api/tanaman/{id}      -> show    (detail)
    // PUT    /api/tanaman/{id}      -> update  (ubah)
    // DELETE /api/tanaman/{id}      -> destroy (hapus)
    Route::apiResource('tanaman', TanamanController::class);
});