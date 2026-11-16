<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('tanaman', function (Blueprint $table) {
            // Boleh kosong supaya data tanaman lama tidak error.
            // Jika kategori/zona dihapus, kolomnya otomatis menjadi NULL.
            $table->foreignId('kategori_id')
                ->nullable()
                ->after('user_id')
                ->constrained('kategori')
                ->nullOnDelete();

            $table->foreignId('zona_id')
                ->nullable()
                ->after('kategori_id')
                ->constrained('zona')
                ->nullOnDelete();
        });
    }

    public function down(): void
    {
        Schema::table('tanaman', function (Blueprint $table) {
            $table->dropConstrainedForeignId('zona_id');
            $table->dropConstrainedForeignId('kategori_id');
        });
    }
};