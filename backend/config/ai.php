<?php

// Konfigurasi LLM. Kunci API hanya di .env, tidak pernah di aplikasi Flutter.
return [

    /*
    |--------------------------------------------------------------------------
    | Interface bebas penyedia
    |--------------------------------------------------------------------------
    |
    | Implementasi memakai endpoint kompatibel OpenAI (chat/completions), jadi
    | cukup ganti AI_BASE_URL + AI_MODEL untuk pindah penyedia tanpa mengubah kode.
    |
    */

    'key' => env('AI_API_KEY'),

    'base_url' => env('AI_BASE_URL', 'https://api.openai.com/v1'),

    'model' => env('AI_MODEL', 'gpt-4o-mini'),

    // Batas waktu panggilan LLM dalam detik.
    'timeout' => (int) env('AI_TIMEOUT', 20),

    // Batas karakter teks ringkasan materi.
    'summarize_max_chars' => 20_000,
];
