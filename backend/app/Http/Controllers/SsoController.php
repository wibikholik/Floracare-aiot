<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Str;

class SsoController extends Controller
{
    public function google(Request $request)
    {
        $request->validate([
            'id_token'     => 'required_without:access_token|nullable|string',
            'access_token' => 'required_without:id_token|nullable|string',
        ]);

        $clientId = config('services.google.client_id');

        // Verifikasi token ke Google, lalu pastikan token ini memang untuk Client ID kita.
        if ($request->filled('id_token')) {
            $res = Http::get('https://oauth2.googleapis.com/tokeninfo', [
                'id_token' => $request->id_token,
            ]);

            if ($res->failed()) {
                return $this->unauthorized('id_token tidak valid');
            }

            $p = $res->json();

            if (($p['aud'] ?? null) !== $clientId) {
                return $this->unauthorized('Client ID tidak cocok');
            }
        } else {
            $check = Http::get('https://oauth2.googleapis.com/tokeninfo', [
                'access_token' => $request->access_token,
            ]);

            if ($check->failed()) {
                return $this->unauthorized('access_token tidak valid');
            }

            $aud = $check->json('aud') ?? $check->json('azp');
            if ($aud !== $clientId) {
                return $this->unauthorized('Client ID tidak cocok');
            }

            $info = Http::withToken($request->access_token)
                ->get('https://www.googleapis.com/oauth2/v3/userinfo');

            if ($info->failed()) {
                return $this->unauthorized('Gagal mengambil profil Google');
            }

            $p = $info->json();
        }

        $verified = filter_var($p['email_verified'] ?? false, FILTER_VALIDATE_BOOLEAN);

        if (empty($p['email']) || !$verified) {
            return $this->unauthorized('Email Google belum terverifikasi');
        }

        $googleId = $p['sub'];
        $email    = $p['email'];
        $name     = $p['name'] ?? Str::before($email, '@');
        $avatar   = $p['picture'] ?? null;

        $user = User::where('google_id', $googleId)->orWhere('email', $email)->first();

        if ($user) {
            $user->forceFill([
                'google_id'         => $user->google_id ?: $googleId,
                'avatar'            => $avatar ?: $user->avatar,
                'provider'          => $user->provider ?: 'google',
                'email_verified_at' => $user->email_verified_at ?: now(),
            ])->save();
        } else {
            $user = User::create([
                'name'              => $name,
                'email'             => $email,
                'password'          => Str::random(32), // di-hash otomatis oleh cast 'hashed'
                'google_id'         => $googleId,
                'avatar'            => $avatar,
                'provider'          => 'google',
                'email_verified_at' => now(),
            ]);
        }

        $token = $user->createToken('google-sso')->plainTextToken;

        return response()->json([
            'status'  => 200,
            'message' => 'Login Google berhasil',
            'token'   => $token,
            'user'    => $user,
        ], 200);
    }

    private function unauthorized(string $message)
    {
        return response()->json([
            'status'  => 401,
            'message' => $message,
        ], 401);
    }
}