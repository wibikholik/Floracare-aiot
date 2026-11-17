<?php

namespace App\Providers;

use App\Services\Deteksi\GeminiDetector;
use App\Services\Deteksi\PenyakitDetector;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        $this->app->bind(PenyakitDetector::class, function () {
            return match (config('services.deteksi.provider')) {
                'gemini' => new GeminiDetector(
                    (string) config('services.gemini.key'),
                    (string) config('services.gemini.model'),
                ),
                // 'claude' => new ClaudeDetector(...),  // nanti tinggal tambah
                default => throw new \InvalidArgumentException('Provider deteksi tidak dikenal'),
            };
        });
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        //
    }
}