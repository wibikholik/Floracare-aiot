<?php

namespace App\Services\Deteksi;

use RuntimeException;

abstract class BasePenyakitDetector implements PenyakitDetector
{
    protected const JENIS_MASALAH = [
        'hama', 'jamur', 'bakteri', 'kekurangan_nutrisi', 'kelebihan_air',
        'kekurangan_air', 'stres_cahaya', 'lainnya', 'tidak_ada',
    ];

    protected function buatPrompt(?string $namaTanaman = null): string
{
    $konteksTanaman = $namaTanaman
        ? "Pengguna menginformasikan jenis tanaman ini adalah: {$namaTanaman}."
        : "Identifikasi juga nama/jenis tanaman yang terlihat pada foto.";

    return <<<PROMPT
Anda adalah pakar agronomi dan perlindungan tanaman hias/hortikultura di Indonesia.
Analisis foto tanaman berikut secara cermat. {$konteksTanaman}

Tugas Anda:
1. Tentukan nama tanaman yang terdeteksi (jika terlihat jelas).
2. Identifikasi kondisi tanaman: 'sehat', 'terindikasi_hama', 'sakit', atau 'tidak_yakin'.
3. Sebutkan nama hama/penyakit secara spesifik dalam Bahasa Indonesia (jika sehat, tulis "Tanaman Sehat").
4. Berikan tingkat keyakinan antara 0 sampai 100.
5. Susun 'saran_penanganan' yang sangat praktis, terstruktur, dan langsung bisa diterapkan oleh petani/pengelola tanaman di Indonesia dengan format poin-poin berikut:

- **Tindakan Fisik Awal:** (misal: pemangkasan daun terinfeksi, isolasi tanaman, pembersihan gulma/media).
- **Rekomendasi Obat / Perawatan:** (sebutkan jenis pestisida/fungisida/bakterisida/insektisida atau bahan organik beserta bahan aktif dan contoh merek dagang yang umum di Indonesia, misal: Fungisida berbahan aktif Mankozeb seperti Dithane M-45, atau Insektisida Abamektin seperti Agrimec). Jika tanaman sehat, berikan rekomendasi pupuk/vitamin perawatan rutin.
- **Takaran & Volume Dosis:** (sebutkan takaran pasti, contoh: "Larutkan 2 gram bubuk atau 1–2 ml cairan obat ke dalam 1 liter air bersih", serta perkiraan volume semprot per tanaman, misal: "Semprotkan 100–200 ml larutan hingga merata ke permukaan atas dan bawah daun").
- **Cara & Jadwal Aplikasi:** (waktu penyemprotan yang disarankan seperti pagi/sore hari, dan interval pengulangan misalnya setiap 5–7 hari sekali hingga gejala berhenti).

Gunakan bahasa Indonesia yang jelas, ringkas, dan mudah dipahami di layar HP.
PROMPT;
}
    /** Skema output (format JSON Schema ala Gemini; provider lain bisa menyesuaikan). */
    protected function skemaOutput(): array
    {
        return [
            'type' => 'OBJECT',
            'properties' => [
                'nama_tanaman'      => ['type' => 'STRING'],
                'kondisi'           => ['type' => 'STRING', 'enum' => ['sehat', 'sakit', 'tidak_yakin']],
                'jenis_masalah'     => ['type' => 'STRING', 'enum' => self::JENIS_MASALAH],
                'nama_masalah'      => ['type' => 'STRING'],
                'tingkat_keyakinan' => ['type' => 'INTEGER'],
                'saran_penanganan'  => ['type' => 'STRING'],
            ],
            'required' => ['kondisi', 'jenis_masalah', 'tingkat_keyakinan', 'saran_penanganan'],
        ];
    }

    protected function parseJson(?string $teks): array
    {
        $data = json_decode($teks ?? '', true);

        if (!is_array($data)) {
            throw new RuntimeException('Format respons AI tidak valid');
        }

        return $data;
    }

    /** Petakan output mentah AI ke kolom tabel deteksi_penyakit. */
    protected function petakanHasil(array $m): HasilDeteksi
    {
        $kondisi = $m['kondisi'] ?? null;

        if (!in_array($kondisi, ['sehat', 'sakit', 'tidak_yakin'], true)) {
            throw new RuntimeException('Format respons AI tidak valid');
        }

        $jenis = $m['jenis_masalah'] ?? 'tidak_ada';
        $jenis = ($kondisi === 'sehat' || $jenis === 'tidak_ada') ? null : $jenis;

        $status = match (true) {
            $kondisi === 'sehat'       => 'sehat',
            $kondisi === 'tidak_yakin' => 'tidak_yakin',
            $jenis === 'hama'          => 'terindikasi_hama',
            default                    => 'sakit',
        };

        $hasil = match ($kondisi) {
            'sehat'       => 'Tanaman sehat',
            'tidak_yakin' => 'Tidak dapat dipastikan',
            default       => trim($m['nama_masalah'] ?? '') ?: 'Masalah tidak teridentifikasi',
        };

        $namaTanaman = trim($m['nama_tanaman'] ?? '');

        return new HasilDeteksi(
            hasilKlasifikasi: $hasil,
            jenisMasalah: $jenis,
            tingkatKeyakinan: max(0, min(100, (float) ($m['tingkat_keyakinan'] ?? 0))),
            statusKondisi: $status,
            saranPenanganan: $m['saran_penanganan'] ?? '',
            namaTanaman: $namaTanaman !== '' ? $namaTanaman : null,
        );
    }
}