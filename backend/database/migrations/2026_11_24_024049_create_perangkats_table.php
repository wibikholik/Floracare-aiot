<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('perangkat', function (Blueprint $table) {
            $table->id();
            $table->foreignId('zona_id')->constrained('zona')->cascadeOnDelete();
            $table->string('kode')->unique();          // mis. ESP32-ZONA1
            $table->string('nama')->nullable();
            $table->string('token', 64)->unique();     // dipakai alat untuk autentikasi
            $table->timestamp('terakhir_online')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('perangkat');
    }
};