# FloraCare

Aplikasi monitoring dan perawatan tanaman hias untuk toko tanaman mitra (Soklat).
Project ini terdiri dari dua bagian dalam satu repo:

| Folder | Isi | Teknologi |
|---|---|---|
| `backend/` | API, database, login | Laravel + MySQL (Sanctum untuk token) |
| `mobile/` | Aplikasi yang dilihat pengguna | Flutter |

Alurnya: aplikasi Flutter memanggil API Laravel, Laravel menyimpan dan mengolah data di MySQL.

## Fitur saat ini

- Register dan login (email + password, token Sanctum)
- CRUD data tanaman (tambah, lihat, ubah, hapus), tiap pengguna hanya melihat tanamannya sendiri

## Yang perlu di-install dulu

1. **Laragon** (sudah membawa PHP dan MySQL), versi Full disarankan
2. **Composer** (bawaan Laragon biasanya sudah ada, cek dengan `composer -V`)
3. **Flutter SDK** (cek dengan `flutter doctor`)
4. **Git**
5. **Google Chrome** (untuk menjalankan aplikasi versi web) atau emulator/HP Android
6. **Postman** (opsional, untuk menguji API)

PHP yang dipakai minimal 8.2. Cek dengan `php -v`.

## 1. Ambil project

Disarankan di folder `www` milik Laragon:

```
cd C:\laragon\www
git clone https://github.com/wibikholik/Floracare-aiot.git
cd Floracare-aiot
```

## 2. Jalankan backend (Laravel)

1. Buka **Laragon**, klik **Start All** sampai Apache/Nginx dan MySQL menyala.
2. Masuk ke folder backend dan pasang dependency:
   ```
   cd backend
   composer install
   ```
3. Buat file `.env` dari contohnya:
   ```
   copy .env.example .env
   php artisan key:generate
   ```
4. Buka file `backend/.env`, lalu pastikan bagian database seperti ini (ganti kalau MySQL kamu punya password):
   ```
   DB_CONNECTION=mysql
   DB_HOST=127.0.0.1
   DB_PORT=3306
   DB_DATABASE=floracare_aiot
   DB_USERNAME=root
   DB_PASSWORD=
   ```
5. Buat tabel-tabelnya:
   ```
   php artisan migrate
   ```
   Kalau muncul pertanyaan "database does not exist, create it?", jawab `yes`.
6. Jalankan server:
   ```
   php artisan serve
   ```
   Buka `http://localhost:8000` di browser. Kalau muncul halaman Laravel, backend sudah hidup.

Biarkan terminal ini tetap terbuka selama aplikasi dipakai.

## 3. Jalankan aplikasi (Flutter)

Buka **terminal baru** (jangan tutup yang menjalankan backend).

1. Masuk ke folder mobile dan pasang paket (pertama kali bisa lama, tergantung internet):
   ```
   cd mobile
   flutter pub get
   ```
2. Atur alamat API di file `mobile/lib/helper/constant.dart`, pada variabel `apiurl`. Isinya harus diakhiri `/api` tanpa garis miring di belakang. Pilih sesuai tempat aplikasi dijalankan:

   | Dijalankan di | Isi `apiurl` |
   |---|---|
   | Chrome (web) | `http://localhost:8000/api` |
   | Emulator Android | `http://10.0.2.2:8000/api` |
   | HP asli | `http://IP-LAPTOP:8000/api` |

   Untuk HP asli: jalankan backend dengan `php artisan serve --host=0.0.0.0`, HP dan laptop harus di Wi-Fi yang sama, dan IP laptop dilihat lewat `ipconfig` (bagian IPv4 Address). Kalau tidak nyambung, izinkan PHP di Windows Firewall.

3. Jalankan aplikasinya:
   ```
   flutter run -d chrome
   ```
   atau jalankan `flutter run` lalu pilih device (emulator atau HP yang terhubung lewat USB dengan USB debugging menyala).

## 4. Coba aplikasinya

1. Di halaman login, tekan **Daftar Sekarang**, buat akun (password minimal 8 karakter).
2. Setelah masuk, tekan **Tambah Tanaman** untuk menambah data.
3. Tekan titik tiga di tiap kartu tanaman untuk **Ubah** atau **Hapus**.

## Daftar endpoint API

Semua alamat diawali `http://localhost:8000/api`.

| Method | Alamat | Fungsi | Perlu token |
|---|---|---|---|
| POST | `/register` | Daftar akun baru | Tidak |
| POST | `/login` | Login, mengembalikan token | Tidak |
| POST | `/logout` | Logout | Ya |
| GET | `/user` | Data pengguna yang sedang login | Ya |
| GET | `/tanaman` | Daftar tanaman milik pengguna | Ya |
| POST | `/tanaman` | Tambah tanaman | Ya |
| GET | `/tanaman/{id}` | Detail tanaman | Ya |
| PUT | `/tanaman/{id}` | Ubah tanaman | Ya |
| DELETE | `/tanaman/{id}` | Hapus tanaman | Ya |

Untuk endpoint yang butuh token, kirim header `Authorization: Bearer <token>` dan `Accept: application/json`.

## Masalah yang sering muncul

| Masalah | Penyebab dan solusi |
|---|---|
| `flutter pub get` lama | Normal untuk pertama kali, terutama kalau internet lambat. Tunggu sampai selesai. |
| Aplikasi tidak bisa terhubung ke server | Backend belum jalan, atau `apiurl` tidak cocok dengan device (lihat tabel di atas). |
| `Class "App\Models\Tanaman" not found` | Model belum ada atau salah tempat. Pastikan `backend/app/Models/Tanaman.php` ada. |
| Error `could not find driver` atau koneksi database gagal | MySQL belum menyala di Laragon, atau isi `.env` bagian `DB_` belum sesuai. |
| Setelah mengubah `.env` tidak berpengaruh | Jalankan `php artisan config:clear`, lalu ulangi. |
| Register gagal | Password kurang dari 8 karakter, atau email sudah terdaftar. |

## Catatan untuk tim

- Jangan pernah meng-commit file `backend/.env` (sudah diabaikan oleh `.gitignore`). Isinya key rahasia.
- Sebelum mulai bekerja: `git pull`. Setelah selesai: `git add .`, `git commit -m "pesan"`, lalu `git push`.