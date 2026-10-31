<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('focus_records', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('task_id')->nullable()->constrained()->cascadeOnDelete();
            $table->dateTime('mulai');
            $table->unsignedInteger('durasi_menit');
            $table->timestamps();

            $table->index(['user_id', 'mulai']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('focus_records');
    }
};
