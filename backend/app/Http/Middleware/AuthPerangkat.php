<?php

namespace App\Http\Middleware;

use App\Models\Perangkat;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class AuthPerangkat
{
    public function handle(Request $request, Closure $next): Response
    {
        $token = $request->header('X-Device-Token');
        $perangkat = $token ? Perangkat::where('token', $token)->first() : null;

        if (!$perangkat) {
            return response()->json([
                'status'  => 401,
                'message' => 'Token perangkat tidak valid',
            ], 401);
        }

        $perangkat->forceFill(['terakhir_online' => now()])->save();
        $request->attributes->set('perangkat', $perangkat);

        return $next($request);
    }
}