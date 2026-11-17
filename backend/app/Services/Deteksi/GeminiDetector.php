<?php

namespace App\Services\Deteksi;

use Illuminate\Support\Facades\Http;
use RuntimeException;

class GeminiDetector extends BasePenyakitDetector
{
    private string $model;

    public function __construct(
        private string $apiKey,
        string $model,
    ) {
        $this->apiKey = trim($apiKey);
        $this->model  = preg_replace('#^models/#', '', trim($model)) ?: 'gemini-2.5-flash';

        if ($this->apiKey === '') {
            throw new RuntimeException('GEMINI_API_KEY belum diisi di .env');
        }
    }

    public function nama(): string
    {
        return 'gemini:' . $this->model;
    }

    public function analisis(string $isiFoto, string $mime, ?string $namaTanaman = null): HasilDeteksi
    {
        $url = "https://generativelanguage.googleapis.com/v1beta/models/{$this->model}:generateContent";

        $response = Http::acceptJson()
            ->withHeaders(['x-goog-api-key' => $this->apiKey])
            ->timeout(60)
            ->post($url, [
                'contents' => [[
                    'parts' => [
                        ['text' => $this->buatPrompt($namaTanaman)],
                        ['inline_data' => ['mime_type' => $mime, 'data' => base64_encode($isiFoto)]],
                    ],
                ]],
                'generationConfig' => [
                    'temperature'      => 0.2,
                    'responseMimeType' => 'application/json',
                    'responseSchema'   => $this->skemaOutput(),
                ],
            ]);

        if ($response->status() === 429) {
            throw new RuntimeException('Kuota layanan AI habis', 429);
        }

        if ($response->failed()) {
            $detail = $response->json('error.message') ?? $response->body();
            throw new RuntimeException("Layanan AI gagal: HTTP {$response->status()} ({$this->model}) - {$detail}");
        }

        $mentah = $this->parseJson($response->json('candidates.0.content.parts.0.text'));

        return $this->petakanHasil($mentah);
    }
}