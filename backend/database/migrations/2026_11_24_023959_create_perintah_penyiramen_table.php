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
    Schema::create('perintah_penyiraman', function (Blueprint $table) {
        $table->id();
        $table->foreignId('zona_id')->constrained('zona')->cascadeOnDelete();
        $table->foreignId('jadwal_id')->nullable()->constrained('jadwal_penyiraman')->nullOnDelete();
        $table->enum('sumber', ['manual', 'jadwal', 'otomatis']);
        $table->unsignedSmallInteger('durasi_detik');
        $table->boolean('campur_pupuk')->default(false);
        $table->enum('status', ['pending', 'dikirim', 'selesai', 'gagal'])->default('pending');
        $table->timestamp('dikirim_pada')->nullable();
        $table->timestamp('selesai_pada')->nullable();
        $table->string('catatan')->nullable();      // alasan gagal, dll.
        $table->timestamps();

        $table->index(['zona_id', 'status']);
    });
}

public function down(): void
{
    Schema::dropIfExists('perintah_penyiraman');
}
};
