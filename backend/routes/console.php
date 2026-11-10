<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

// Harian: buang token yang sudah kedaluwarsa lebih dari 24 jam agar
// tabel personal_access_tokens tidak menumpuk baris sesi lama.
// Perpanjangan sesi hidup di RenewSessionToken; ini pembersih sisanya.
Schedule::command('sanctum:prune-expired', ['--hours' => 24])->daily();
