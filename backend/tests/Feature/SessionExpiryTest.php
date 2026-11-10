<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Tests\TestCase;

/**
 * Sesi 60 hari: token login berlaku 60 hari, tiap request terautentikasi
 * memperpanjang (throttle 60 menit), dan lewat batas tanpa dibuka token
 * gugur dengan code session_expired.
 */
final class SessionExpiryTest extends TestCase
{
    use RefreshDatabase;

    /** Registrasi dan kembalikan [plainToken, waktuRegistrasi]. */
    private function daftar(): array
    {
        $sebelum = Carbon::now();
        $response = $this->postJson('/api/auth/register', [
            'name' => 'Pengguna Demo',
            'email' => 'demo@example.com',
            'password' => 'password',
        ])->assertStatus(201);

        return [$response->json('data.token'), $sebelum];
    }

    public function test_token_lewat_61_hari_menghasilkan_session_expired(): void
    {
        [$token] = $this->daftar();

        $this->travelTo(now()->addDays(61));

        $this->getJson('/api/me', ['Authorization' => "Bearer $token"])
            ->assertStatus(401)
            ->assertJsonPath('code', 'session_expired')
            ->assertJsonStructure(['message', 'errors', 'code']);
    }

    public function test_token_pas_lewat_60_hari_masih_diterima_karena_renew(): void
    {
        [$token] = $this->daftar();

        // Menjelang batas 60 hari; renew middleware memperpanjang saat
        // request, jadi token masih diterima (dan terperpanjang).
        $this->travelTo(now()->addDays(59)->addMinutes(30));

        $this->getJson('/api/me', ['Authorization' => "Bearer $token"])
            ->assertStatus(200);
    }

    public function test_request_terautentikasi_memperpanjang_expires_at_ke_request_plus_60_hari(): void
    {
        [$token, $t0] = $this->daftar();

        $this->travelTo($t0->copy()->addDays(30));
        $this->getJson('/api/me', ['Authorization' => "Bearer $token"])
            ->assertStatus(200);

        $tokenDb = DB::table('personal_access_tokens')->first();

        // Diperpanjang ke saat request + 60 hari (t0 + 90 hari), bukan t0 + 60.
        $this->assertSame(
            $t0->copy()->addDays(90)->format('Y-m-d H:i'),
            Carbon::parse($tokenDb->expires_at)->format('Y-m-d H:i'),
        );
    }

    public function test_dua_request_dalam_satu_jam_hanya_menulis_expires_at_sekali(): void
    {
        [$token] = $this->daftar();

        DB::enableQueryLog();
        $this->getJson('/api/me', ['Authorization' => "Bearer $token"])
            ->assertStatus(200);

        // Request kedua kurang dari satu jam kemudian harus ter-throttle
        // sehingga expires_at hanya ditulis sekali.
        $this->getJson('/api/me', ['Authorization' => "Bearer $token"])
            ->assertStatus(200);

        $penulisan = collect(DB::getQueryLog())
            ->filter(
                fn ($query) => str_contains($query['query'], 'update "personal_access_tokens"'),
            )
            ->count();

        $this->assertSame(1, $penulisan, 'expires_at seharusnya cuma ditulis sekali');
    }

    public function test_token_uji_tidak_kenal_menghasilkan_401_biasa_bukan_session_expired(): void
    {
        $this->daftar();

        $this->getJson('/api/me', ['Authorization' => 'Bearer token-tidak-kenal'])
            ->assertStatus(401)
            ->assertJsonPath('code', 'TIDAK_TERAUTENTIKASI');
    }

    public function test_tanpa_token_menghasilkan_401_biasa(): void
    {
        $this->daftar();

        $this->getJson('/api/me')
            ->assertStatus(401)
            ->assertJsonPath('code', 'TIDAK_TERAUTENTIKASI');
    }
}
