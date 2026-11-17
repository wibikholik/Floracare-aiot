import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/deteksi_penyakit.dart';
import '../../services/deteksi_penyakit_service.dart';
import 'riwayat_deteksi_screen.dart';

class ScanDeteksiScreen extends StatefulWidget {
  /// Opsional. Kosong = foto bebas (AI mengenali sendiri jenis tanamannya).
  final int? tanamanId;
  final String? namaTanaman;

  const ScanDeteksiScreen({
    super.key,
    this.tanamanId,
    this.namaTanaman,
  });

  @override
  State<ScanDeteksiScreen> createState() => _ScanDeteksiScreenState();
}

class _ScanDeteksiScreenState extends State<ScanDeteksiScreen> {
  final _picker = ImagePicker();
  final _service = DeteksiPenyakitService();

  File? _foto;
  DeteksiPenyakit? _hasil;
  bool _loading = false;
  String? _error;

  Future<void> _ambilFoto(ImageSource sumber) async {
    final x = await _picker.pickImage(
      source: sumber,
      imageQuality: 80,
      maxWidth: 1280,
    );
    if (x == null) return;
    setState(() {
      _foto = File(x.path);
      _hasil = null;
      _error = null;
    });
  }

  Future<void> _analisis() async {
    if (_foto == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final hasil = await _service.analisis(
        tanamanId: widget.tanamanId,
        foto: _foto!,
      );
      if (!mounted) return;
      setState(() => _hasil = hasil);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Tidak dapat terhubung ke server.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final judul = widget.namaTanaman != null
        ? 'Deteksi: ${widget.namaTanaman}'
        : 'Deteksi Hama & Penyakit';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        title: Text(judul),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: widget.tanamanId != null
                ? 'Riwayat Tanaman Ini'
                : 'Riwayat Deteksi',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      RiwayatDeteksiScreen(tanamanId: widget.tanamanId),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              clipBehavior: Clip.antiAlias,
              child: _foto == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.local_florist,
                            size: 48, color: Colors.grey.shade500),
                        const SizedBox(height: 8),
                        const Text('Foto tanaman apa saja, dekat dan fokus'),
                      ],
                    )
                  : Image.file(_foto!, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed:
                      _loading ? null : () => _ambilFoto(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Kamera'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed:
                      _loading ? null : () => _ambilFoto(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galeri'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: (_foto == null || _loading) ? null : _analisis,
              icon: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.biotech),
              label: Text(_loading ? 'Menganalisis AI...' : 'Analisis Tanaman'),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Text(_error!, style: TextStyle(color: Colors.red.shade800)),
            ),
          ],
          if (_hasil != null) ...[
            const SizedBox(height: 16),
            _KartuHasil(hasil: _hasil!),
          ],
        ],
      ),
    );
  }
}

class _KartuHasil extends StatelessWidget {
  final DeteksiPenyakit hasil;
  const _KartuHasil({required this.hasil});

  static const _labelStatus = {
    'sehat': 'Sehat',
    'terindikasi_hama': 'Terindikasi Hama',
    'sakit': 'Sakit / Penyakit',
    'tidak_yakin': 'Foto Kurang Jelas',
  };

  Color _warna() {
    switch (hasil.statusKondisi) {
      case 'sehat':
        return Colors.green;
      case 'terindikasi_hama':
        return Colors.orange;
      case 'sakit':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasil.namaTanamanTerdeteksi != null &&
                hasil.namaTanamanTerdeteksi!.isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.local_florist, size: 18, color: Colors.green[700]),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Tanaman: ${hasil.namaTanamanTerdeteksi}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            Wrap(
              spacing: 8,
              children: [
                Chip(
                  label: Text(
                    _labelStatus[hasil.statusKondisi] ?? hasil.statusKondisi,
                    style: TextStyle(
                        color: _warna(), fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: _warna().withValues(alpha: 0.12),
                  side: BorderSide(color: _warna()),
                ),
                if (hasil.jenisMasalah != null)
                  Chip(
                    label: Text(
                        hasil.jenisMasalah!.replaceAll('_', ' ').toUpperCase()),
                    backgroundColor: Colors.blueGrey.shade50,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              hasil.hasilKlasifikasi,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Tingkat keyakinan: ${hasil.tingkatKeyakinan.toStringAsFixed(0)}%',
              style: TextStyle(color: Colors.grey[700]),
            ),
            const Divider(height: 24),
            const Text('Saran Penanganan & Dosis Obat',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(
              hasil.saranPenanganan ?? '-',
              style: const TextStyle(height: 1.5),
            ),
            const SizedBox(height: 12),
            Text(
              'Hasil ini bantuan AI dan bukan diagnosis pasti. '
              'Konsultasikan ke pengelola toko jika kondisi parah.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey),
            ),
            if (hasil.provider != null) ...[
              const SizedBox(height: 8),
              Text(
                'Model: ${hasil.provider}',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }
}