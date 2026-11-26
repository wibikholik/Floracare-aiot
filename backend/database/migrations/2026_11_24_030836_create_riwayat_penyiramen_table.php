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
    Schema::create('riwayat_penyiraman', function (Blueprint $table) {
        $table->id();
        $table->foreignId('zona_id')->constrained('zona')->cascadeOnDelete();
        $table->foreignId('perintah_id')->nullable()->constrained('perintah_penyiraman')->nullOnDelete();
        $table->enum('sumber', ['manual', 'jadwal', 'otomatis']);
        $table->timestamp('mulai');
        $table->timestamp('selesai')->nullable();
        $table->unsignedSmallInteger('durasi_detik');
        $table->boolean('campur_pupuk')->default(false);
        $table->decimal('kelembapan_sebelum', 5, 2)->nullable();
        $table->decimal('kelembapan_sesudah', 5, 2)->nullable();
        $table->timestamps();

        $table->index(['zona_id', 'mulai']);
    });
}

public function down(): void
{
    Schema::dropIfExists('riwayat_penyiraman');
}
};
