import 'package:flutter/material.dart';
import '../../models/deteksi_penyakit.dart';
import '../../services/deteksi_penyakit_service.dart';
import 'detail_deteksi_screen.dart';

class RiwayatDeteksiScreen extends StatefulWidget {
  /// Opsional. Kosong = semua riwayat milik pengguna.
  final int? tanamanId;
  const RiwayatDeteksiScreen({super.key, this.tanamanId});

  @override
  State<RiwayatDeteksiScreen> createState() => _RiwayatDeteksiScreenState();
}

class _RiwayatDeteksiScreenState extends State<RiwayatDeteksiScreen> {
  final _service = DeteksiPenyakitService();
  late Future<List<DeteksiPenyakit>> _future;

  static const _labelStatus = {
    'sehat': 'Sehat',
    'terindikasi_hama': 'Terindikasi hama',
    'sakit': 'Sakit',
    'tidak_yakin': 'Tidak yakin',
  };

  @override
  void initState() {
    super.initState();
    _muat();
  }

  void _muat() {
    _future = _service.riwayat(tanamanId: widget.tanamanId);
  }

  Future<void> _konfirmasiPenanganan(
      DeteksiPenyakit item, bool nilaiBaru) async {
    final catatanCtrl = TextEditingController(text: item.catatan ?? '');

    final simpan = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
            nilaiBaru ? 'Tandai Sudah Ditangani' : 'Batalkan Status Ditangani'),
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
              child: const Text('Batal')),
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

    try {
      await _service.ubahStatus(
        item.id,
        sudahDitangani: nilaiBaru,
        catatan: catatanCtrl.text.trim(),
      );
      if (!mounted) return;
      setState(_muat);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat terhubung ke server.')),
      );
    }
  }

  Future<void> _bukaDetail(DeteksiPenyakit d) async {
    final adaPerubahan = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => DetailDeteksiScreen(deteksi: d),
      ),
    );

    if (adaPerubahan == true && mounted) {
      setState(_muat);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        title: const Text('Riwayat Deteksi Hama'),
      ),
      body: FutureBuilder<List<DeteksiPenyakit>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.green));
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('${snap.error}', textAlign: TextAlign.center),
              ),
            );
          }
          final data = snap.data!;
          if (data.isEmpty) {
            return const Center(child: Text('Belum ada riwayat deteksi'));
          }

          return RefreshIndicator(
            onRefresh: () async => setState(_muat),
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: data.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final d = data[i];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    onTap: () => _bukaDetail(d),
                    contentPadding: const EdgeInsets.all(10),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        d.fotoUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image, size: 40),
                      ),
                    ),
                    title: Text(
                      d.hasilKlasifikasi,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (d.namaTanamanTerdeteksi != null &&
                            d.namaTanamanTerdeteksi!.isNotEmpty)
                          Text(
                            d.namaTanamanTerdeteksi!,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        Text(
                          '${_labelStatus[d.statusKondisi] ?? d.statusKondisi} • Keyakinan ${d.tingkatKeyakinan.toStringAsFixed(0)}%',
                        ),
                        if (d.catatan != null && d.catatan!.isNotEmpty)
                          Text(
                            'Catatan: ${d.catatan}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          ),
                      ],
                    ),
                    trailing: Switch(
                      activeThumbColor: Colors.green[700],
                      value: d.sudahDitangani,
                      onChanged: (v) => _konfirmasiPenanganan(d, v),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}