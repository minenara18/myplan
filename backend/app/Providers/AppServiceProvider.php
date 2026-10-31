<?php

namespace App\Providers;

use App\Contracts\AiProvider;
use App\Services\Ai\OpenAiCompatibleProvider;
use Illuminate\Support\ServiceProvider;

final class AppServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        // Driver AI tidak terikat penyedia; unit test bisa mengganti dengan fake.
        $this->app->bind(AiProvider::class, OpenAiCompatibleProvider::class);
    }

    public function boot(): void
    {
        //
    }
}
