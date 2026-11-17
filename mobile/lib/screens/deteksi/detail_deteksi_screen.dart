import 'package:flutter/material.dart';
import '../../models/deteksi_penyakit.dart';
import '../../services/deteksi_penyakit_service.dart';

class DetailDeteksiScreen extends StatefulWidget {
  final DeteksiPenyakit deteksi;

  const DetailDeteksiScreen({super.key, required this.deteksi});

  @override
  State<DetailDeteksiScreen> createState() => _DetailDeteksiScreenState();
}

class _DetailDeteksiScreenState extends State<DetailDeteksiScreen> {
  final _service = DeteksiPenyakitService();
  late DeteksiPenyakit _data;
  bool _sedangMenyimpan = false;
  bool _adaPerubahan = false;

  static const _labelStatus = {
    'sehat': 'Sehat',
    'terindikasi_hama': 'Terindikasi hama',
    'sakit': 'Sakit',
    'tidak_yakin': 'Tidak yakin',
  };

  @override
  void initState() {
    super.initState();
    _data = widget.deteksi;
  }

  Color _warnaStatus(String status) {
    switch (status) {
      case 'sehat':
        return Colors.green[700]!;
      case 'terindikasi_hama':
        return Colors.orange[800]!;
      case 'sakit':
        return Colors.red[700]!;
      default:
        return Colors.grey[700]!;
    }
  }

  String _formatTanggal(DateTime? dt) {
    if (dt == null) return '-';
    final lokal = dt.toLocal();
    final tgl = lokal.day.toString().padLeft(2, '0');
    final bln = lokal.month.toString().padLeft(2, '0');
    final thn = lokal.year;
    final jam = lokal.hour.toString().padLeft(2, '0');
    final mnt = lokal.minute.toString().padLeft(2, '0');
    return '$tgl/$bln/$thn • $jam:$mnt';
  }

  Future<void> _ubahStatusPenanganan(bool nilaiBaru) async {
    final catatanCtrl = TextEditingController(text: _data.catatan ?? '');

    final simpan = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          nilaiBaru ? 'Tandai Sudah Ditangani' : 'Batalkan Status Ditangani',
        ),
        content: TextField(
          controller: catatanCtrl,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Catatan tindakan (opsional)',
            hintText: 'Misal: Daun sakit sudah dipangkas & disemprot fungisida',
            border: OutlineInputBorder(),
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
    );

    if (simpan != true) return;

    setState(() => _sedangMenyimpan = true);

    try {
      final catatanBaru = catatanCtrl.text.trim();
      await _service.ubahStatus(
        _data.id,
        sudahDitangani: nilaiBaru,
        catatan: catatanBaru,
      );

      if (!mounted) return;
      setState(() {
        _data = DeteksiPenyakit(
          id: _data.id,
          tanamanId: _data.tanamanId,
          namaTanamanTerdeteksi: _data.namaTanamanTerdeteksi,
          fotoUrl: _data.fotoUrl,
          hasilKlasifikasi: _data.hasilKlasifikasi,
          jenisMasalah: _data.jenisMasalah,
          tingkatKeyakinan: _data.tingkatKeyakinan,
          statusKondisi: _data.statusKondisi,
          saranPenanganan: _data.saranPenanganan,
          sudahDitangani: nilaiBaru,
          catatan: catatanBaru,
          provider: _data.provider,
          createdAt: _data.createdAt,
        );
        _adaPerubahan = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status penanganan diperbarui')),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat terhubung ke server.')),
      );
    } finally {
      if (mounted) setState(() => _sedangMenyimpan = false);
    }
  }

  Future<void> _hapusRiwayat() async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Riwayat Deteksi'),
        content: const Text('Riwayat analisis ini akan dihapus permanen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (yakin != true) return;

    setState(() => _sedangMenyimpan = true);
    try {
      await _service.hapus(_data.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Riwayat deteksi dihapus')),
      );
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _sedangMenyimpan = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      setState(() => _sedangMenyimpan = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat terhubung ke server.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final warna = _warnaStatus(_data.statusKondisi);
    final labelKondisi =
        _labelStatus[_data.statusKondisi] ?? _data.statusKondisi;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        Navigator.pop(context, _adaPerubahan);
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.green[700],
          foregroundColor: Colors.white,
          title: const Text('Detail Analisis AI'),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Hapus Riwayat',
              onPressed: _sedangMenyimpan ? null : _hapusRiwayat,
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: _data.fotoUrl.isNotEmpty
                    ? Image.network(
                        _data.fotoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.broken_image,
                                size: 48, color: Colors.grey),
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.image_not_supported,
                              size: 48, color: Colors.grey),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: warna.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: warna.withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          labelKondisi,
                          style: TextStyle(
                            color: warna,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Text(
                        _formatTanggal(_data.createdAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _data.hasilKlasifikasi,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  if (_data.namaTanamanTerdeteksi != null &&
                      _data.namaTanamanTerdeteksi!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.eco, size: 16, color: Colors.green[700]),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Tanaman: ${_data.namaTanamanTerdeteksi!}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.green[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (_data.jenisMasalah != null &&
                      _data.jenisMasalah!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Kategori Masalah: ${_data.jenisMasalah}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tingkat Keyakinan AI',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${_data.tingkatKeyakinan.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: warna,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (_data.tingkatKeyakinan / 100).clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor: Colors.grey[200],
                      color: warna,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.medical_services_outlined,
                          color: Colors.green[700], size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Saran Penanganan & Dosis Obat',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Text(
                    (_data.saranPenanganan != null &&
                            _data.saranPenanganan!.trim().isNotEmpty)
                        ? _data.saranPenanganan!
                        : 'Tidak ada saran penanganan khusus.',
                    style: const TextStyle(
                        fontSize: 14, height: 1.5, color: Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeThumbColor: Colors.green[700],
                    title: const Text(
                      'Sudah Ditangani',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    subtitle: Text(
                      _data.sudahDitangani
                          ? 'Tanaman sudah diberi tindakan perawatan'
                          : 'Tandai jika perawatan sudah dilakukan',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    value: _data.sudahDitangani,
                    onChanged: _sedangMenyimpan ? null : _ubahStatusPenanganan,
                  ),
                  if (_data.catatan != null && _data.catatan!.isNotEmpty) ...[
                    const Divider(height: 16),
                    Text(
                      'Catatan Tindakan:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _data.catatan!,
                      style: const TextStyle(
                          fontSize: 13, fontStyle: FontStyle.italic),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Catatan: Hasil analisis dihasilkan oleh AI (${_data.provider ?? "Gemini"}) sebagai referensi awal penanganan tanaman.',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}