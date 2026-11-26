import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/helper/json_helper.dart';
import 'package:flutter_application_1/models/monitoring_model.dart';
import 'package:flutter_application_1/services/monitoring_service.dart';

class MonitoringScreen extends StatefulWidget {
  const MonitoringScreen({super.key});

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> {
  final _service = MonitoringService();
  List<MonitoringZona> _zona = [];
  bool _memuat = true;
  String? _error;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _muat();
    _timer = Timer.periodic(
        const Duration(seconds: 15), (_) => _muat(senyap: true));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _muat({bool senyap = false}) async {
    if (!senyap) {
      setState(() {
        _memuat = true;
        _error = null;
      });
    }
    try {
      final data = await _service.semuaZona();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        title: const Text('Monitoring Lingkungan'),
      ),
      body: _isi(),
    );
  }

  Widget _isi() {
    if (_memuat && _zona.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _zona.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _muat, child: const Text('Coba lagi')),
            ],
          ),
        ),
      );
    }
    if (_zona.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Belum ada zona. Tambahkan zona lewat menu Data Tanaman.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _muat,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: _zona.length,
        itemBuilder: (_, i) => _kartuZona(_zona[i]),
      ),
    );
  }

  Widget _kartuZona(MonitoringZona z) {
    final s = z.sensor;
    final tanamanUtama = z.tanaman.isNotEmpty ? z.tanaman.first : null;
    final namaTanaman = tanamanUtama?.nama ?? 'Tanaman belum ditentukan';
    final kategori = tanamanUtama?.kategori;
    final infoTanaman = [
      if (kategori != null && kategori.isNotEmpty) kategori,
      namaTanaman,
    ].join(' • ');

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(z.namaZona,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold))),
            _chipStatus(z.status),
          ]),
          const SizedBox(height: 6),
          Text(infoTanaman, style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.w600)),
          Text('${z.jumlahTanaman} tanaman terdaftar • ${z.sampel.length} titik sampel',
              style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const Divider(height: 22),
          if (s == null)
            Text('Belum ada data dari alat', style: TextStyle(color: Colors.grey[600]))
          else ...[
            Row(children: [
              Expanded(child: _metrik(Icons.thermostat, 'Suhu udara', s.suhu, '°C')),
              Expanded(child: _metrik(Icons.cloud, 'Kelembapan udara', s.kelembapanUdara, '%')),
            ]),
            const SizedBox(height: 12),
            _metrik(Icons.water_drop, 'Kelembapan tanah rata-rata', s.kelembapanTanah, '%'),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                minHeight: 8,
                value: ((s.kelembapanTanah ?? 0) / 100).clamp(0.0, 1.0),
                backgroundColor: Colors.grey[200],
                color: _warnaStatus(z.status),
              ),
            ),
            const SizedBox(height: 12),
            Text('Grafik kelembapan tanah 24 jam terakhir (rata-rata zona)',
                style: TextStyle(fontSize: 11, color: Colors.grey[600])),
            const SizedBox(height: 4),
            SizedBox(height: 70, child: _GrafikTanah(
              key: ValueKey('${z.zonaId}-${s.waktu}'),
              zonaId: z.zonaId, warna: _warnaStatus(z.status))),
            const SizedBox(height: 6),
            Text('Data terakhir: ${formatWaktu(s.waktu)}',
                style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          ],
          const SizedBox(height: 14),
          _judulBagian('Detail sampel sensor'),
          if (z.sampel.isEmpty)
            Text('Belum ada data sampel sensor', style: TextStyle(fontSize: 12, color: Colors.grey[600]))
          else
            ...z.sampel.map((sample) => _kartuSampel(sample, z)),
          const SizedBox(height: 12),
          _judulBagian('Informasi otomasi'),
          _informasiOtomasi(z),
          const SizedBox(height: 10),
          Wrap(spacing: 6, runSpacing: 6, children: [
            _label(z.otomatisAktif ? 'Otomatis aktif' : 'Otomatis nonaktif',
                z.otomatisAktif ? Colors.green : Colors.grey),
            if (z.perintahAktif != null)
              _label(z.perintahAktif!.menunggu ? 'Menunggu alat' : 'Sedang menyiram', Colors.blue),
          ]),
        ]),
      ),
    );
  }

  Widget _judulBagian(String teks) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(teks, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      );

  Widget _kartuSampel(SampelSensorData sample, MonitoringZona z) {
    final nilai = sample.kelembapanTanah;
    var status = 'Data kosong';
    var warna = Colors.grey;
    if (nilai != null) {
      if (z.batasKelembapanMin != null && nilai < z.batasKelembapanMin!) {
        status = 'Kering';
        warna = Colors.orange;
      } else if (z.batasKelembapanMaks != null && nilai > z.batasKelembapanMaks!) {
        status = 'Basah';
        warna = Colors.blue;
      } else {
        status = 'Normal';
        warna = Colors.green;
      }
    }
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey.shade50,
      ),
      child: Column(children: [
        Row(children: [
          Expanded(child: Text(sample.nama, style: const TextStyle(fontWeight: FontWeight.w600))),
          _label(status, warna),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _metrik(Icons.water_drop, 'Kelembapan tanah', nilai, '%')),
          Expanded(child: _metrik(Icons.science, 'pH tanah', sample.phTanah, '')),
        ]),
      ]),
    );
  }

  Widget _informasiOtomasi(MonitoringZona z) {
    final info = <String, String>{
      'Ambang penyiraman': z.batasKelembapanMin == null ? '-' : '${z.batasKelembapanMin!.toStringAsFixed(0)}%',
      'Batas maksimum': z.batasKelembapanMaks == null ? '-' : '${z.batasKelembapanMaks!.toStringAsFixed(0)}%',
      'Durasi': z.durasiDetik == null ? '-' : '${z.durasiDetik} detik',
      'Jeda': z.jedaMenit == null ? '-' : '${z.jedaMenit} menit',
      'Metode': 'Sprinkler dari atas',
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(10)),
      child: Column(children: info.entries.map((e) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(children: [
          Expanded(child: Text(e.key, style: TextStyle(fontSize: 12, color: Colors.grey[700]))),
          Text(e.value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ]),
      )).toList()),
    );
  }

  Widget _metrik(IconData icon, String label, double? nilai, String satuan) {
    return Row(
      children: [
        Icon(icon, size: 22, color: Colors.teal[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              Text(
                nilai == null ? '-' : '${nilai.toStringAsFixed(1)} $satuan',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
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
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: warna.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(teks,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.bold, color: warna)),
    );
  }
}

// Grafik garis sederhana kelembapan tanah (skala 0-100%)
class _GrafikTanah extends StatefulWidget {
  final int zonaId;
  final Color warna;
  const _GrafikTanah({super.key, required this.zonaId, required this.warna});

  @override
  State<_GrafikTanah> createState() => _GrafikTanahState();
}

class _GrafikTanahState extends State<_GrafikTanah> {
  List<double> _nilai = [];

  @override
  void initState() {
    super.initState();
    _muat();
  }

  Future<void> _muat() async {
    try {
      final data = await MonitoringService().riwayatSensor(widget.zonaId);
      if (!mounted) return;
      setState(() => _nilai = data.map((e) => e.kelembapanTanah).toList());
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_nilai.length < 2) {
      return Center(
        child: Text('Data grafik belum cukup',
            style: TextStyle(fontSize: 11, color: Colors.grey[500])),
      );
    }
    return CustomPaint(
      size: Size.infinite,
      painter: _SparklinePainter(_nilai, widget.warna),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> nilai;
  final Color warna;
  _SparklinePainter(this.nilai, this.warna);

  @override
  void paint(Canvas canvas, Size size) {
    final garis = Paint()
      ..color = warna
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;
    final path = Path();
    for (var i = 0; i < nilai.length; i++) {
      final x = size.width * i / (nilai.length - 1);
      final y = size.height * (1 - nilai[i].clamp(0, 100) / 100);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, garis);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter old) => old.nilai != nilai;
}