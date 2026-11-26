import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_1/helper/json_helper.dart';
import 'package:flutter_application_1/methods/api.dart';
import 'package:flutter_application_1/models/monitoring_model.dart';
import 'package:flutter_application_1/screens/auth/login.dart';
import 'package:flutter_application_1/screens/deteksi/riwayat_deteksi_screen.dart';
import 'package:flutter_application_1/screens/deteksi/scan_deteksi_screen.dart';
import 'package:flutter_application_1/screens/monitoring/monitoring_screen.dart';
import 'package:flutter_application_1/screens/tanaman/tanaman_list_page.dart';
import 'package:flutter_application_1/services/monitoring_service.dart';
import 'package:flutter_application_1/services/penyiraman_service.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _monitoring = MonitoringService();

  String namaPengguna = '';
  String emailPengguna = '';

  List<MonitoringZona> _zona = [];
  bool _memuat = true;
  String? _error;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _muatPengguna();
    _muatRingkasan();
    _timer = Timer.periodic(
        const Duration(seconds: 15), (_) => _muatRingkasan(senyap: true));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _muatPengguna() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      namaPengguna = preferences.getString('name') ?? 'Petani';
      emailPengguna = preferences.getString('email') ?? '';
    });
  }

  Future<void> _muatRingkasan({bool senyap = false}) async {
    if (!senyap) {
      setState(() {
        _memuat = true;
        _error = null;
      });
    }
    try {
      final data = await _monitoring.semuaZona();
      if (!mounted) return;
      setState(() {
        _zona = data;
        _error = null;
        _memuat = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        if (!senyap || _zona.isEmpty) _error = bersihkanError(e);
        _memuat = false;
      });
    }
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

  // Tutup drawer lalu buka halaman
  void _buka(Widget halaman) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => halaman));
  }

  Future<void> _bukaSiram(MonitoringZona z) async {
    final berhasil = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _SheetSiram(zona: z),
    );
    if (berhasil == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Perintah siram untuk ${z.namaZona} dikirim')),
      );
      _muatRingkasan(senyap: true);
    }
  }

  // ---------------------------------------------------------------- BUILD

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
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
      ),
      drawer: _drawer(),
      body: RefreshIndicator(
        onRefresh: _muatRingkasan,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Halo, $namaPengguna',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              'Ringkasan kondisi tanaman hari ini',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Ringkasan Lingkungan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MonitoringScreen()),
                  ),
                  child: const Text('Lihat detail'),
                ),
              ],
            ),
            if (_zona.isNotEmpty) _barisRingkasan(),
            const SizedBox(height: 8),
            ..._isiRingkasan(),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------- DRAWER

  Widget _drawer() {
    final inisial =
        namaPengguna.isNotEmpty ? namaPengguna[0].toUpperCase() : 'P';
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.green[700]),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                inisial,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
            ),
            accountName: Text(
              namaPengguna,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: emailPengguna.isEmpty ? null : Text(emailPengguna),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _itemDrawer(
                  Icons.home,
                  'Beranda',
                  () => Navigator.pop(context),
                  terpilih: true,
                ),
                const Divider(),
                _itemDrawer(Icons.eco, 'Data Tanaman',
                    () => _buka(const TanamanListPage())),
                _itemDrawer(Icons.camera_alt, 'Deteksi Hama & Penyakit',
                    () => _buka(const ScanDeteksiScreen())),
                _itemDrawer(Icons.history, 'Riwayat Deteksi Hama',
                    () => _buka(const RiwayatDeteksiScreen())),
                _itemDrawer(Icons.sensors, 'Monitoring Lingkungan',
                    () => _buka(const MonitoringScreen())),
                _itemDrawer(
                  Icons.water_drop,
                  'Kontrol Penyiraman',
                  () {
                    Navigator.pop(context);
                    _infoSegeraHadir('Kontrol Penyiraman');
                  },
                  segera: true,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Keluar', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _konfirmasiLogout();
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _itemDrawer(
    IconData icon,
    String judul,
    VoidCallback onTap, {
    bool terpilih = false,
    bool segera = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: terpilih ? Colors.green[700] : Colors.grey[700]),
      title: Text(
        judul,
        style: TextStyle(
          fontWeight: terpilih ? FontWeight.bold : FontWeight.normal,
          color: terpilih ? Colors.green[800] : Colors.black87,
        ),
      ),
      trailing: segera
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Segera',
                  style: TextStyle(fontSize: 10, color: Colors.grey[700])),
            )
          : null,
      selected: terpilih,
      selectedTileColor: Colors.green[50],
      onTap: onTap,
    );
  }

  // ------------------------------------------------------------- RINGKASAN

  Widget _barisRingkasan() {
    final normal = _zona.where((z) => z.status == 'normal' || z.status == 'basah').length;
    final kering = _zona.where((z) => z.status == 'kering').length;
    final offline = _zona.where((z) => z.status == 'offline').length;
    return Wrap(
      spacing: 6,
      children: [
        _label('${_zona.length} zona', Colors.blueGrey),
        _label('$normal normal', Colors.green),
        if (kering > 0) _label('$kering perlu disiram', Colors.orange),
        if (offline > 0) _label('$offline offline', Colors.grey),
      ],
    );
  }

  List<Widget> _isiRingkasan() {
    if (_memuat && _zona.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }
    if (_error != null && _zona.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _muatRingkasan,
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      ];
    }
    if (_zona.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Text(
            'Belum ada zona. Tambahkan zona lewat menu Data Tanaman.',
            textAlign: TextAlign.center,
          ),
        ),
      ];
    }
    return _zona.map(_kartuZona).toList();
  }

  Widget _kartuZona(MonitoringZona z) {
    final s = z.sensor;
    final aktif = z.perintahAktif;
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    z.namaZona,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
                _chipStatus(z.status),
              ],
            ),
            const SizedBox(height: 12),
            if (s == null)
              Text('Belum ada data dari alat',
                  style: TextStyle(color: Colors.grey[600]))
            else ...[
              Row(
                children: [
                  Expanded(child: _mini(Icons.thermostat, s.suhu, '°C', 'Suhu')),
                  Expanded(
                      child: _mini(Icons.cloud, s.kelembapanUdara, '%', 'Udara')),
                  Expanded(
                      child: _mini(
                          Icons.water_drop, s.kelembapanTanah, '%', 'Tanah')),
                  Expanded(child: _mini(Icons.science, s.phTanah, '', 'pH')),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value: ((s.kelembapanTanah ?? 0) / 100).clamp(0.0, 1.0),
                  backgroundColor: Colors.grey[200],
                  color: _warnaStatus(z.status),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Data terakhir: ${formatWaktu(s.waktu)}',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              children: [
                if (z.otomatisAktif) _label('Otomatis aktif', Colors.green),
                if (aktif != null)
                  _label(
                    aktif.menunggu ? 'Menunggu alat' : 'Sedang menyiram',
                    Colors.blue,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                ),
                onPressed: aktif == null ? () => _bukaSiram(z) : null,
                icon: const Icon(Icons.water_drop),
                label: Text(
                  aktif == null
                      ? 'Siram Manual'
                      : (aktif.menunggu ? 'Menunggu alat...' : 'Sedang menyiram...'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mini(IconData icon, double? nilai, String satuan, String label) {
    return Column(
      children: [
        Icon(icon, size: 22, color: Colors.teal[600]),
        const SizedBox(height: 4),
        Text(
          nilai == null ? '-' : '${nilai.toStringAsFixed(1)}$satuan',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }

  Color _warnaStatus(String status) {
    switch (status) {
      case 'kering':
        return Colors.orange;
      case 'basah':
        return Colors.blue;
      case 'offline':
        return Colors.grey;
      default:
        return Colors.green;
    }
  }

  Widget _chipStatus(String status) {
    const teks = {
      'normal': 'Normal',
      'kering': 'Tanah kering',
      'basah': 'Terlalu basah',
      'offline': 'Alat offline',
    };
    return _label(teks[status] ?? status, _warnaStatus(status));
  }

  Widget _label(String teks, Color warna) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: warna.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        teks,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: warna),
      ),
    );
  }
}

// Bottom sheet untuk penyiraman manual satu zona
class _SheetSiram extends StatefulWidget {
  final MonitoringZona zona;
  const _SheetSiram({required this.zona});

  @override
  State<_SheetSiram> createState() => _SheetSiramState();
}

class _SheetSiramState extends State<_SheetSiram> {
  double _durasi = 30;
  bool _pupuk = false;
  bool _mengirim = false;
  String? _error;

  Future<void> _kirim() async {
    setState(() {
      _mengirim = true;
      _error = null;
    });
    try {
      await PenyiramanService().siram(
        widget.zona.zonaId,
        durasi: _durasi.round(),
        campurPupuk: _pupuk,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _mengirim = false;
        _error = bersihkanError(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Siram ${widget.zona.namaZona}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (widget.zona.status == 'offline')
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Alat sedang offline. Perintah akan dijalankan saat alat kembali online.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            Text('Durasi: ${_durasi.round()} detik'),
            Slider(
              value: _durasi,
              min: 5,
              max: 300,
              divisions: 59,
              label: '${_durasi.round()} dtk',
              onChanged: (v) => setState(() => _durasi = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Campur pupuk'),
              value: _pupuk,
              onChanged: (v) => setState(() => _pupuk = v),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _mengirim ? null : _kirim,
                icon: const Icon(Icons.water_drop),
                label: Text(_mengirim ? 'Mengirim...' : 'Siram Sekarang'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}