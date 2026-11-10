<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Laravel\Sanctum\PersonalAccessToken;

/**
 * Memperpanjang masa berlaku sesi tiap kali aplikasi dipakai.
 *
 * Pada setiap request terautentikasi, perpanjang `expires_at` token Sanctum
 * yang dipakai menjadi `now() + 60 hari` — selama aplikasi masih dibuka
 * sekurangnya sekali dalam 60 hari, sesi tetap hidup. Penulisan DB
 * di-throttle lewat Cache (kunci `renew-session:{id}`, 60 menit).
 */
final class RenewSessionToken
{
    /** Masa berlaku token setelah diperpanjang. */
    public const HARI_MASA_BERLAKU = 60;

    /** Jeda minimum antar penulisan expires_at untuk satu token. */
    public const MENIT_THROTTLE = 60;

    /** @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next */
    public function handle(Request $request, Closure $next)
    {
        $accessToken = $request->user()?->currentAccessToken();

        if ($accessToken instanceof PersonalAccessToken) {
            $kunci = 'renew-session:'.$accessToken->getKey();

            if (Cache::has($kunci)) {
                return $next($request);
            }

            $accessToken->updateQuietly([
                'expires_at' => now()->addDays(self::HARI_MASA_BERLAKU),
            ]);
            Cache::put(
                $kunci,
                true,
                now()->addMinutes(self::MENIT_THROTTLE),
            );
        }

        return $next($request);
    }
}
