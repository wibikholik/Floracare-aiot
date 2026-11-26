<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
{
    Schema::create('pengaturan_otomasi', function (Blueprint $table) {
        $table->id();
        $table->foreignId('zona_id')->unique()->constrained('zona')->cascadeOnDelete();
        $table->boolean('otomatis_aktif')->default(false);
        $table->unsignedTinyInteger('batas_kelembapan_min')->default(40);   // di bawah ini → siram
        $table->unsignedTinyInteger('batas_kelembapan_maks')->default(70);  // target setelah siram
        $table->unsignedSmallInteger('durasi_detik')->default(30);
        $table->boolean('campur_pupuk')->default(false);
        $table->unsignedSmallInteger('jeda_menit')->default(60);           // jeda minimal antar siraman
        $table->timestamps();
    });
}

public function down(): void
{
    Schema::dropIfExists('pengaturan_otomasi');
}
};
