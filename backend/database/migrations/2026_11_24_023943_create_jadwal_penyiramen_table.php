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
    Schema::create('jadwal_penyiraman', function (Blueprint $table) {
        $table->id();
        $table->foreignId('zona_id')->constrained('zona')->cascadeOnDelete();
        $table->json('hari');                       // [1,3,5] → 1=Senin ... 7=Minggu (ISO)
        $table->time('jam');                        // 07:00:00
        $table->unsignedSmallInteger('durasi_detik')->default(30);
        $table->boolean('campur_pupuk')->default(false);
        $table->boolean('aktif')->default(true);
        $table->timestamps();
    });
}

public function down(): void
{
    Schema::dropIfExists('jadwal_penyiraman');
}
};
