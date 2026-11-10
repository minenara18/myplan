<?php

namespace Tests\Feature;

use Illuminate\Console\Scheduling\Schedule;
use Tests\TestCase;

/**
 * Jadwal pembersihan token kedaluwarsa harus terdaftar harian, agar
 * tabel personal_access_tokens tidak menumpuk baris sesi lama.
 */
final class PruneExpiredScheduleTest extends TestCase
{
    public function test_jadwal_harian_sanctum_prune_expired_terdaftar(): void
    {
        $peristiwa = collect(app(Schedule::class)->events())
            ->filter(fn ($event) => str_contains(
                (string) $event->command,
                'sanctum:prune-expired',
            ));

        $this->assertSame(
            1,
            $peristiwa->count(),
            'Jadwal sanctum:prune-expired harus terdaftar tepat satu kali',
        );

        $event = $peristiwa->first();
        $this->assertStringContainsString('--hours=24', (string) $event->command);
        $this->assertSame('0 0 * * *', (string) $event->expression);
    }
}
