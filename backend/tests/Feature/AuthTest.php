<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

final class AuthTest extends TestCase
{
    use RefreshDatabase;

    public function test_register_mengembalikan_token_dan_user(): void
    {
        $response = $this->postJson('/api/auth/register', [
            'name' => 'Pengguna Demo',
            'email' => 'demo@example.com',
            'password' => 'password',
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('data.user.email', 'demo@example.com');

        $this->assertIsString($response->json('data.token'));
        $this->assertDatabaseHas('users', ['email' => 'demo@example.com']);
    }

    public function test_register_gagal_validasi_tanpa_surel(): void
    {
        $response = $this->postJson('/api/auth/register', [
            'password' => 'password',
        ]);

        $response->assertStatus(422)
            ->assertJsonStructure(['message', 'errors', 'code'])
            ->assertJsonFragment(['code' => 'VALIDASI_GAGAL']);
    }

    public function test_login_sukses_memberikan_token(): void
    {
        $this->postJson('/api/auth/register', [
            'name' => 'Pengguna Demo',
            'email' => 'demo@example.com',
            'password' => 'password',
        ]);

        $response = $this->postJson('/api/auth/login', [
            'email' => 'demo@example.com',
            'password' => 'password',
        ]);

        $response->assertStatus(200)
            ->assertJsonPath('data.user.email', 'demo@example.com')
            ->assertJsonPath('data.user.name', 'Pengguna Demo');
        $this->assertIsString($response->json('data.token'));
    }

    public function test_login_password_salah(): void
    {
        $this->postJson('/api/auth/register', [
            'name' => 'Pengguna Demo',
            'email' => 'demo@example.com',
            'password' => 'password',
        ]);

        $response = $this->postJson('/api/auth/login', [
            'email' => 'demo@example.com',
            'password' => 'salah',
        ]);

        $response->assertStatus(422);
    }

    public function test_me_membutuhkan_token(): void
    {
        $this->getJson('/api/me')->assertStatus(401)
            ->assertJsonFragment(['code' => 'TIDAK_TERAUTENTIKASI']);
    }

    public function test_me_mengembalikan_user_setelah_login(): void
    {
        $token = $this->postJson('/api/auth/register', [
            'name' => 'Pengguna Demo',
            'email' => 'demo@example.com',
            'password' => 'password',
        ])->json('data.token');

        $response = $this->getJson('/api/me', [
            'Authorization' => "Bearer {$token}",
        ]);

        $response->assertStatus(200)
            ->assertJsonPath('data.email', 'demo@example.com');
    }

    public function test_logout_menghapus_validitas_token(): void
    {
        $token = $this->postJson('/api/auth/register', [
            'name' => 'Pengguna Demo',
            'email' => 'demo@example.com',
            'password' => 'password',
        ])->json('data.token');

        $this->postJson('/api/auth/logout', [], [
            'Authorization' => "Bearer {$token}",
        ])->assertStatus(200);

        $this->getJson('/api/me', [
            'Authorization' => "Bearer {$token}",
        ])->assertStatus(401);
    }
}
