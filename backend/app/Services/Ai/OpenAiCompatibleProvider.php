<?php

namespace App\Services\Ai;

use App\Contracts\AiProvider;
use App\Exceptions\AiException;
use Illuminate\Http\Client\ConnectionException;
use Illuminate\Support\Facades\Http;

/**
 * Driver LLM kompatibel OpenAI (POST {base_url}/chat/completions).
 * Kunci API diambil dari .env; tidak pernah dibundel ke aplikasi mobile.
 */
final class OpenAiCompatibleProvider implements AiProvider
{
    public function selesaikan(string $sistem, string $pengguna, ?int $timeoutDetik = null): string
    {
        $url = rtrim((string) config('ai.base_url'), '/').'/chat/completions';
        $key = (string) config('ai.key');
        $timeout = $timeoutDetik ?? (int) config('ai.timeout', 20);

        if ($key === '') {
            throw AiException::gagal('Kunci API LLM belum diatur.');
        }

        try {
            $respons = Http::withToken($key)
                ->acceptJson()
                ->timeout($timeout)
                ->throw()
                ->post($url, [
                    'model' => (string) config('ai.model'),
                    'messages' => [
                        ['role' => 'system', 'content' => $sistem],
                        ['role' => 'user', 'content' => $pengguna],
                    ],
                    'temperature' => 0.2,
                ]);
        } catch (ConnectionException $e) {
            throw AiException::gagal('Koneksi ke LLM gagal: '.$e->getMessage(), $e);
        } catch (\Throwable $e) {
            throw AiException::gagal('Panggilan LLM gagal: '.$e->getMessage(), $e);
        }

        $teks = $respons->json('choices.0.message.content');

        if (! is_string($teks) || trim($teks) === '') {
            throw AiException::gagal('Respons LLM tidak berisi teks jawaban.');
        }

        return $teks;
    }
}
