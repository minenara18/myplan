<?php

use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Auth\AuthenticationException;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Validation\ValidationException;
use App\Exceptions\AiException;
use Laravel\Sanctum\PersonalAccessToken;
use Symfony\Component\HttpKernel\Exception\HttpException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware) {
        // Guard auth ter-cache antar-request saat pengujian; pastikan setiap
        // request API menyelesaikan user dari token masing-masing.
        $middleware->group('api', [\App\Http\Middleware\ResetCachedUser::class]);
    })
    ->withExceptions(function (Exceptions $exceptions) {
        //
        // Format error seragam untuk API: {message, errors, code}
        $exceptions->shouldRenderJsonWhen(fn ($request, Throwable $e) => $request->is('api/*'));

        $exceptions->render(function (ValidationException $exception, $request) {
            if (! $request->is('api/*')) {
                return null;
            }

            return response()->json([
                'message' => $exception->getMessage(),
                'errors' => $exception->errors(),
                'code' => 'VALIDASI_GAGAL',
            ], 422);
        });

        $exceptions->render(function (AuthenticationException $exception, $request) {
            if (! $request->is('api/*')) {
                return null;
            }

            // Bedakan sesi kedaluwarsa dari belum masuk: bila bearer token
            // dikenali di DB tapi expires_at sudah lewat, hasilnya
            // session_expired agar aplikasi menampilkan banner berbeda dan
            // bisa mengisi surel dari sesi terakhir.
            $bearer = $request->bearerToken();
            $token = $bearer === null ? null : PersonalAccessToken::findToken($bearer);

            if ($token && $token->expires_at && $token->expires_at->isPast()) {
                return response()->json([
                    'message' => 'Sesi kamu sudah berakhir. Silakan masuk lagi.',
                    'errors' => [],
                    'code' => 'session_expired',
                ], 401);
            }

            return response()->json([
                'message' => 'Tidak terautentikasi.',
                'errors' => [],
                'code' => 'TIDAK_TERAUTENTIKASI',
            ], 401);
        });

        $exceptions->render(function (AuthorizationException $exception, $request) {
            if (! $request->is('api/*')) {
                return null;
            }

            return response()->json([
                'message' => $exception->getMessage() ?: 'Anda tidak berhak mengakses data ini.',
                'errors' => [],
                'code' => 'OTORISASI_GAGAL',
            ], 403);
        });

        $exceptions->render(function (ModelNotFoundException|NotFoundHttpException $exception, $request) {
            if (! $request->is('api/*')) {
                return null;
            }

            return response()->json([
                'message' => 'Data tidak ditemukan.',
                'errors' => [],
                'code' => 'TIDAK_ADA',
            ], 404);
        });

        $exceptions->render(function (HttpException $exception, $request) {
            if (! $request->is('api/*')) {
                return null;
            }

            return response()->json([
                'message' => $exception->getMessage() ?: 'Terjadi kesalahan.',
                'errors' => [],
                'code' => 'KESALAHAN_HTTP_'.$exception->getStatusCode(),
            ], $exception->getStatusCode());
        });

        $exceptions->render(function (AiException $exception, $request) {
            if (! $request->is('api/*')) {
                return null;
            }

            return response()->json([
                'message' => 'Layanan AI sedang tidak tersedia.',
                'errors' => [],
                'code' => 'AI_GAGAL',
            ], 502);
        });

        $exceptions->render(function (Throwable $exception, $request) {
            if (! $request->is('api/*')) {
                return null;
            }

            return response()->json([
                'message' => 'Terjadi kesalahan pada server.',
                'errors' => [],
                'code' => 'KESALAHAN_SERVER',
            ], 500);
        });
    })->create();
