<?php

namespace App\Exceptions;

use RuntimeException;
use Throwable;

/** Kesalahan panggilan LLM (jaringan, waktu habis, respons tidak rapi). */
final class AiException extends RuntimeException
{
    public static function gagal(string $pesan, ?Throwable $sebelumnya = null): self
    {
        return new self($pesan, 0, $sebelumnya);
    }
}
