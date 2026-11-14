<?php

use App\Http\Controllers\Api\TanamanController;
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

    // CRUD tanaman:
    // GET    /api/tanaman          -> index   (daftar)
    // POST   /api/tanaman          -> store   (tambah)
    // GET    /api/tanaman/{id}     -> show    (detail)
    // PUT    /api/tanaman/{id}     -> update  (ubah)
    // DELETE /api/tanaman/{id}     -> destroy (hapus)
    Route::apiResource('tanaman', TanamanController::class);
});