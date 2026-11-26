<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('sampel_sensor', function (Blueprint $table) {
            $table->id();
            $table->foreignId('zona_id')->constrained('zona')->cascadeOnDelete();
            $table->foreignId('tanaman_id')->nullable()->constrained('tanaman')->nullOnDelete();
            $table->unsignedTinyInteger('nomor');
            $table->string('nama')->nullable();
            $table->timestamps();

            $table->unique(['zona_id', 'nomor']);
        });

        Schema::create('data_sensor_sampel', function (Blueprint $table) {
            $table->id();
            $table->foreignId('data_sensor_id')->constrained('data_sensor')->cascadeOnDelete();
            $table->foreignId('sampel_sensor_id')->constrained('sampel_sensor')->cascadeOnDelete();
            $table->decimal('kelembapan_tanah', 5, 2);
            $table->decimal('ph_tanah', 4, 2)->nullable();

            $table->unique(['data_sensor_id', 'sampel_sensor_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('data_sensor_sampel');
        Schema::dropIfExists('sampel_sensor');
    }
};
