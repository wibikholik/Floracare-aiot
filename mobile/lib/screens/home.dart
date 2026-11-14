import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_1/methods/api.dart';
import 'package:flutter_application_1/screens/auth/login.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String namaPengguna = '';
  String emailPengguna = '';
  List<dynamic> daftarTanaman = [];
  bool isLoading = true;
  String? pesanError;

  // Pilihan status tanaman (dipakai saat ubah data)
  final List<String> _pilihanStatus = ['sehat', 'perlu disiram', 'terserang hama'];

  @override
  void initState() {
    super.initState();
    _muatPengguna();
    _ambilTanaman();
  }

  // Data sesi pengguna dari SharedPreferences
  Future<void> _muatPengguna() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      namaPengguna = preferences.getString('name') ?? 'Petani';
      emailPengguna = preferences.getString('email') ?? '';
    });
  }

  void _snack(String pesan) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(pesan)));
  }

  // READ: ambil daftar tanaman (GET /api/tanaman)
  Future<void> _ambilTanaman() async {
    setState(() {
      isLoading = true;
      pesanError = null;
    });

    try {
      final result = await API().getRequest(route: '/tanaman');
      final response = jsonDecode(result.body);

      if (!mounted) return;
      if (result.statusCode == 200 && response['status'] == 200) {
        setState(() {
          daftarTanaman = response['data'] ?? [];
        });
      } else {
        setState(() {
          pesanError = response['message'] ?? 'Gagal memuat data tanaman';
        });
      }
    } catch (e) {
      debugPrint("Gagal memuat tanaman: $e");
      if (!mounted) return;
      setState(() {
        pesanError = 'Tidak bisa terhubung ke server';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // CREATE (POST /api/tanaman) dan UPDATE (PUT /api/tanaman/{id})
  // Jika [tanaman] diisi berarti mode ubah, jika kosong berarti mode tambah.
  Future<void> _dialogForm({Map<String, dynamic>? tanaman}) async {
    final sedangUbah = tanaman != null;
    final nama = TextEditingController(text: tanaman?['nama']?.toString() ?? '');
    final jenis = TextEditingController(text: tanaman?['jenis']?.toString() ?? '');
    final lokasi = TextEditingController(text: tanaman?['lokasi']?.toString() ?? '');
    String status = tanaman?['status']?.toString() ?? 'sehat';
    final pilihan = {..._pilihanStatus, status}.toList();

    final simpan = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(sedangUbah ? 'Ubah Tanaman' : 'Tambah Tanaman'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nama,
                  decoration: const InputDecoration(labelText: 'Nama tanaman'),
                ),
                TextField(
                  controller: jenis,
                  decoration: const InputDecoration(labelText: 'Jenis'),
                ),
                TextField(
                  controller: lokasi,
                  decoration: const InputDecoration(labelText: 'Lokasi'),
                ),
                if (sedangUbah) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Status',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: status,
                    items: pilihan
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (nilai) {
                      if (nilai == null) return;
                      setDialogState(() {
                        status = nilai;
                      });
                    },
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );

    final namaText = nama.text.trim();
    final jenisText = jenis.text.trim();
    final lokasiText = lokasi.text.trim();
    nama.dispose();
    jenis.dispose();
    lokasi.dispose();

    if (simpan != true) return;

    if (namaText.isEmpty) {
      _snack('Nama tanaman wajib diisi');
      return;
    }

    final body = <String, dynamic>{
      "nama": namaText,
      "jenis": jenisText,
      "lokasi": lokasiText,
    };
    if (sedangUbah) {
      body["status"] = status;
    }

    try {
      final result = sedangUbah
          ? await API().putRequest(route: '/tanaman/${tanaman['id']}', data: body)
          : await API().postRequest(route: '/tanaman', data: body);
      final response = jsonDecode(result.body);

      if (result.statusCode == 200 || result.statusCode == 201) {
        _snack(response['message'] ?? 'Berhasil disimpan');
        _ambilTanaman();
      } else {
        _snack(response['message'] ?? 'Gagal menyimpan');
      }
    } catch (e) {
      debugPrint("Error simpan tanaman: $e");
      _snack('Tidak bisa terhubung ke server');
    }
  }

  // DELETE (DELETE /api/tanaman/{id})
  Future<void> _hapusTanaman(Map<String, dynamic> tanaman) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Tanaman'),
        content: Text('Hapus "${tanaman['nama']}"? Data tidak bisa dikembalikan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (yakin != true) return;

    try {
      final result = await API().deleteRequest(route: '/tanaman/${tanaman['id']}');
      final response = jsonDecode(result.body);

      if (result.statusCode == 200) {
        _snack(response['message'] ?? 'Tanaman dihapus');
        _ambilTanaman();
      } else {
        _snack(response['message'] ?? 'Gagal menghapus');
      }
    } catch (e) {
      debugPrint("Error hapus tanaman: $e");
      _snack('Tidak bisa terhubung ke server');
    }
  }

  // Logout: hapus token di server dan data sesi di HP
  Future<void> _logoutUser() async {
    try {
      await API().postRequest(route: '/logout', data: {});
    } catch (e) {
      debugPrint("Error logout server: $e");
    }

    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const Login()),
    );
  }

  void _konfirmasiLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar Akun'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              _logoutUser();
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.local_florist, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'FloraCare',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _ambilTanaman,
            tooltip: 'Perbarui Data',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _konfirmasiLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        onPressed: () => _dialogForm(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Tanaman'),
      ),
      body: RefreshIndicator(
        onRefresh: _ambilTanaman,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
          children: [
            _kartuPengguna(),
            const SizedBox(height: 16),
            const Text(
              'Tanaman Saya',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            ..._isiDaftar(),
          ],
        ),
      ),
    );
  }

  // Isi daftar: loading, error, kosong, atau daftar tanaman
  List<Widget> _isiDaftar() {
    if (isLoading) {
      return [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(child: CircularProgressIndicator(color: Colors.green)),
        ),
      ];
    }

    if (pesanError != null) {
      return [
        _pesanKosong(Icons.cloud_off, pesanError!, 'Tarik ke bawah untuk coba lagi'),
      ];
    }

    if (daftarTanaman.isEmpty) {
      return [
        _pesanKosong(
          Icons.eco_outlined,
          'Belum ada tanaman',
          'Tekan tombol "Tambah Tanaman" untuk mulai',
        ),
      ];
    }

    return daftarTanaman
        .map<Widget>((t) => _kartuTanaman(t as Map<String, dynamic>))
        .toList();
  }

  Widget _pesanKosong(IconData icon, String judul, String keterangan) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(icon, size: 56, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            judul,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            keterangan,
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _kartuPengguna() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.green[100],
            child: Text(
              namaPengguna.isNotEmpty ? namaPengguna[0].toUpperCase() : 'P',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat Datang,',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  namaPengguna,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (emailPengguna.isNotEmpty)
                  Text(
                    emailPengguna,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _kartuTanaman(Map<String, dynamic> t) {
    final nama = (t['nama'] ?? '-').toString();
    final jenis = (t['jenis'] ?? '').toString();
    final lokasi = (t['lokasi'] ?? '').toString();
    final status = (t['status'] ?? 'sehat').toString();
    final sehat = status.toLowerCase() == 'sehat';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 14, 4, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.eco, color: Colors.green[700], size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nama,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (jenis.isNotEmpty)
                  Text(
                    jenis,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                if (lokasi.isNotEmpty)
                  Text(
                    'Lokasi: $lokasi',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: sehat ? Colors.green[50] : Colors.orange[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: sehat ? Colors.green[700] : Colors.orange[800],
                    ),
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (aksi) {
              if (aksi == 'ubah') {
                _dialogForm(tanaman: t);
              } else if (aksi == 'hapus') {
                _hapusTanaman(t);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'ubah', child: Text('Ubah')),
              PopupMenuItem(value: 'hapus', child: Text('Hapus')),
            ],
          ),
        ],
      ),
    );
  }
}