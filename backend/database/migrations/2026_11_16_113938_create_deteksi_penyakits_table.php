<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('deteksi_penyakit', function (Blueprint $table) {
            $table->id();
            $table->foreignId('tanaman_id')
                ->constrained('tanaman')
                ->onDelete('cascade');
            $table->string('foto');
            $table->string('hasil_klasifikasi');
            $table->string('jenis_masalah')->nullable(); // hama | jamur | bakteri | kekurangan_nutrisi | dll
            $table->decimal('tingkat_keyakinan', 5, 2)->default(0);
            $table->string('status_kondisi')->default('sehat'); // sehat | terindikasi_hama | sakit | tidak_yakin
            $table->text('saran_penanganan')->nullable();
            $table->boolean('sudah_ditangani')->default(false);
            $table->text('catatan')->nullable();
            $table->string('provider', 60)->nullable(); // mis. gemini:gemini-2.5-flash
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('deteksi_penyakit');
    }
};