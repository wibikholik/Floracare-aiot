import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_1/methods/api.dart';
import 'package:flutter_application_1/screens/auth/login.dart';
import 'package:flutter_application_1/screens/tanaman/tanaman_list_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String namaPengguna = '';
  String emailPengguna = '';

  @override
  void initState() {
    super.initState();
    _muatPengguna();
  }

  Future<void> _muatPengguna() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      namaPengguna = preferences.getString('name') ?? 'Petani';
      emailPengguna = preferences.getString('email') ?? '';
    });
  }

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

  void _infoSegeraHadir(String fitur) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Fitur $fitur akan segera ditambahkan')),
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
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _konfirmasiLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _kartuPengguna(),
          const SizedBox(height: 20),
          const Text(
            'Menu Utama',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _kartuMenu(
            icon: Icons.eco,
            warna: Colors.green[700]!,
            judul: 'Data Tanaman',
            deskripsi: 'Kelola daftar tanaman sampel per zona (Tambah, Ubah, Hapus)',
            aktif: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TanamanListPage()),
              );
            },
          ),
          _kartuMenu(
            icon: Icons.sensors,
            warna: Colors.teal[600]!,
            judul: 'Monitoring Zona & Lingkungan',
            deskripsi: 'Pantau suhu, kelembapan udara, dan kelembapan tanah',
            aktif: false,
            onTap: () => _infoSegeraHadir('Monitoring Zona'),
          ),
          _kartuMenu(
            icon: Icons.water_drop,
            warna: Colors.blue[600]!,
            judul: 'Kontrol Penyiraman',
            deskripsi: 'Atur jadwal dan penyiraman otomatis berdasarkan sampel',
            aktif: false,
            onTap: () => _infoSegeraHadir('Kontrol Penyiraman'),
          ),
          _kartuMenu(
            icon: Icons.camera_alt,
            warna: Colors.orange[700]!,
            judul: 'Deteksi Hama Tanaman',
            deskripsi: 'Foto daun tanaman untuk mendeteksi serangan hama',
            aktif: false,
            onTap: () => _infoSegeraHadir('Deteksi Hama'),
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

  Widget _kartuMenu({
    required IconData icon,
    required Color warna,
    required String judul,
    required String deskripsi,
    required bool aktif,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: warna.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: warna, size: 26),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                judul,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            if (!aktif)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Segera',
                  style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                ),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            deskripsi,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey[500]),
        onTap: onTap,
      ),
    );
  }
}