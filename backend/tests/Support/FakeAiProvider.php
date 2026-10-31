<?php

namespace Tests\Support;

use App\Contracts\AiProvider;
use App\Exceptions\AiException;

/** LLM palsu untuk pengujian: menjawab teks tetap atau melempar kesalahan. */
final class FakeAiProvider implements AiProvider
{
    private function __construct(
        private readonly ?string $jawaban,
        private readonly bool $lempar,
    ) {}

    public static function menjawab(string $teks): self
    {
        return new self($teks, false);
    }

    public static function gagal(): self
    {
        return new self(null, true);
    }

    public function selesaikan(string $sistem, string $pengguna, ?int $timeoutDetik = null): string
    {
        if ($this->lempar) {
            throw AiException::gagal('LLM palsu gagal.');
        }

        return (string) $this->jawaban;
    }
}
