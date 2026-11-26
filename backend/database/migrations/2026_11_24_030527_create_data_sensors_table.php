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
    Schema::create('data_sensor', function (Blueprint $table) {
        $table->id();
        $table->foreignId('zona_id')->constrained('zona')->cascadeOnDelete();
        $table->decimal('suhu', 5, 2)->nullable();
        $table->decimal('kelembapan_udara', 5, 2)->nullable();
        $table->decimal('kelembapan_tanah', 5, 2)->nullable();
        $table->decimal('ph_tanah', 4, 2)->nullable();
        $table->timestamp('created_at')->useCurrent();

        $table->index(['zona_id', 'created_at']);
    });
}

public function down(): void
{
    Schema::dropIfExists('data_sensor');
}

};
