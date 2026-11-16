import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/kategori_model.dart';
import 'package:flutter_application_1/screens/tanaman/kategori/kategori_form_page.dart';
import 'package:flutter_application_1/services/kategori_service.dart';

class KategoriListView extends StatefulWidget {
  final VoidCallback? onDataChanged;

  const KategoriListView({super.key, this.onDataChanged});

  @override
  State<KategoriListView> createState() => KategoriListViewState();
}

class KategoriListViewState extends State<KategoriListView> {
  final _service = KategoriService();
  List<Kategori> _daftarKategori = [];
  bool _isLoading = true;
  String? _pesanError;

  @override
  void initState() {
    super.initState();
    reload();
  }

  Future<void> reload() async {
    setState(() {
      _isLoading = true;
      _pesanError = null;
    });

    try {
      final data = await _service.getKategori();
      if (!mounted) return;
      setState(() => _daftarKategori = data);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _pesanError = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _snack(String pesan, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(pesan),
        backgroundColor: isError ? Colors.red[700] : null,
      ),
    );
  }

  Future<void> bukaForm({Kategori? kategori}) async {
    final berhasil = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => KategoriFormPage(kategori: kategori),
      ),
    );

    if (berhasil == true) {
      await reload();
      widget.onDataChanged?.call();
    }
  }

  Future<void> _hapusKategori(Kategori kategori) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Kategori'),
        content: Text(
          'Hapus kategori "${kategori.nama}"? Tanaman di kategori ini tidak akan ikut terhapus.',
        ),
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
      final pesan = await _service.hapusKategori(kategori.id);
      _snack(pesan);
      await reload();
      widget.onDataChanged?.call();
    } catch (e) {
      _snack(
        e.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: reload,
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.green),
      );
    }

    if (_pesanError != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _pesanError!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      );
    }

    if (_daftarKategori.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
          const Center(
            child: Text(
              'Belum ada data kategori.\nTekan "Tambah Kategori" untuk mulai.',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      itemCount: _daftarKategori.length,
      itemBuilder: (context, index) {
        final item = _daftarKategori[index];
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
                  color: Colors.purple.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.category, color: Colors.purple[700], size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.nama,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    if (item.deskripsi.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          item.deskripsi,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.purple[50],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${item.tanamanCount} Tanaman',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (aksi) {
                  if (aksi == 'ubah') {
                    bukaForm(kategori: item);
                  } else if (aksi == 'hapus') {
                    _hapusKategori(item);
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
      },
    );
  }
}