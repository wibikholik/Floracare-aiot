<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // 1. Lepas foreign key lama (tanaman_id wajib + cascade)
        Schema::table('deteksi_penyakit', function (Blueprint $table) {
            $table->dropForeign(['tanaman_id']);
        });

        // 2. tanaman_id jadi opsional; tambah user_id (pemilik) dan nama tanaman hasil AI
        Schema::table('deteksi_penyakit', function (Blueprint $table) {
            $table->unsignedBigInteger('tanaman_id')->nullable()->change();
            $table->foreignId('user_id')->nullable()->after('id')
                ->constrained('users')->cascadeOnDelete();
            $table->string('nama_tanaman_terdeteksi')->nullable()->after('tanaman_id');
        });

        // 3. Pasang lagi foreign key tanaman; kalau tanaman dihapus, riwayat tetap ada
        Schema::table('deteksi_penyakit', function (Blueprint $table) {
            $table->foreign('tanaman_id')->references('id')->on('tanaman')->nullOnDelete();
        });

        // 4. Isi user_id riwayat lama dari pemilik tanamannya
        DB::statement(
            'UPDATE deteksi_penyakit d JOIN tanaman t ON t.id = d.tanaman_id SET d.user_id = t.user_id'
        );
    }

    public function down(): void
    {
        Schema::table('deteksi_penyakit', function (Blueprint $table) {
            $table->dropForeign(['user_id']);
            $table->dropColumn(['user_id', 'nama_tanaman_terdeteksi']);
        });
    }
};