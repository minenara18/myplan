<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

/**
 * Reset cache user pada guard auth di awal setiap request API.
 * Wajib untuk lingkungan pengujian, karena instance guard ter-cache
 * antar-request di dalam satu uji fitur; membuat guard tetap
 * menyelesaikan user dari token pada request berjalan.
 */
final class ResetCachedUser
{
    /** @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next */
    public function handle(Request $request, Closure $next)
    {
        foreach (config('auth.guards') as $nama => $definisi) {
            if (is_array($definisi)) {
                auth()->guard($nama)->forgetUser();
            }
        }

        return $next($request);
    }
}
