<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('tasks', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('course_id')->constrained()->cascadeOnDelete();
            $table->string('judul');
            $table->text('catatan')->nullable();
            $table->dateTime('tenggat');
            $table->unsignedInteger('estimasi_menit');
            $table->string('prioritas', 10); // tinggi | sedang | rendah
            $table->string('status', 10);    // belum | berjalan | selesai
            $table->timestamps();

            $table->index(['user_id', 'tenggat']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('tasks');
    }
};
