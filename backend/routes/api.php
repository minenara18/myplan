<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\AiPlanController;
use App\Http\Controllers\Api\AiSummarizeController;
use App\Http\Controllers\Api\CourseController;
use App\Http\Controllers\Api\FocusRecordController;
use App\Http\Controllers\Api\SettingsController;
use App\Http\Controllers\Api\StatsController;
use App\Http\Controllers\Api\StudySessionController;
use App\Http\Controllers\Api\TaskController;
use Illuminate\Support\Facades\Route;

Route::post('/auth/register', [AuthController::class, 'register'])
    ->name('auth.register');
Route::post('/auth/login', [AuthController::class, 'login'])->name('auth.login');

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/auth/logout', [AuthController::class, 'logout'])->name('auth.logout');
    Route::get('/me', [AuthController::class, 'me'])->name('auth.me');

    Route::get('/settings', [SettingsController::class, 'show']);
    Route::put('/settings', [SettingsController::class, 'update']);

    Route::get('/stats/weekly', [StatsController::class, 'weekly'])->name('stats.weekly');

    Route::apiResource('courses', CourseController::class);
    Route::apiResource('tasks', TaskController::class);
    // bulk di endereco sebelum apiResource agar tak tertangkap {session}.
    Route::post('sessions/bulk', [StudySessionController::class, 'storeBulk'])
        ->name('sessions.bulk');
    Route::apiResource('sessions', StudySessionController::class);

    Route::get('/focus-records', [FocusRecordController::class, 'index']);
    Route::post('/focus-records', [FocusRecordController::class, 'store']);
    Route::delete('/focus-records/{record}', [FocusRecordController::class, 'destroy']);

    // Enpoint AI: hemat kuota, dibatasi per pengguna per menit.
    Route::post('/ai/plan', [AiPlanController::class, 'store'])
        ->middleware('throttle:5,1')->name('ai.plan');
    Route::post('/ai/summarize', [AiSummarizeController::class, 'store'])
        ->middleware('throttle:10,1')->name('ai.summarize');
});
