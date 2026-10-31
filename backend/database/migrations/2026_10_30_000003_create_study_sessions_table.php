<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('study_sessions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('course_id')->constrained()->cascadeOnDelete();
            $table->foreignId('task_id')->nullable()->constrained()->cascadeOnDelete();
            $table->dateTime('mulai');
            $table->dateTime('selesai');
            $table->string('sumber', 10); // manual | ai
            $table->timestamps();

            $table->index(['user_id', 'mulai']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('study_sessions');
    }
};
