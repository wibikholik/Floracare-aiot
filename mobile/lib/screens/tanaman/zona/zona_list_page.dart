import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/zona_model.dart';
import 'package:flutter_application_1/screens/tanaman/zona/zona_form_page.dart';
import 'package:flutter_application_1/services/zona_service.dart';

class ZonaListView extends StatefulWidget {
  final VoidCallback? onDataChanged;
  final ValueChanged<int>? onPilihZona;

  const ZonaListView({
    super.key,
    this.onDataChanged,
    this.onPilihZona,
  });

  @override
  State<ZonaListView> createState() => ZonaListViewState();
}

class ZonaListViewState extends State<ZonaListView> {
  final _service = ZonaService();
  List<Zona> _daftarZona = [];
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
      final data = await _service.getZona();
      if (!mounted) return;
      setState(() => _daftarZona = data);
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

  Future<void> bukaForm({Zona? zona}) async {
    final berhasil = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ZonaFormPage(zona: zona),
      ),
    );

    if (berhasil == true) {
      await reload();
      widget.onDataChanged?.call();
    }
  }

  Future<void> _hapusZona(Zona zona) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Zona'),
        content: Text(
          'Hapus zona "${zona.nama}"? Tanaman di zona ini tetap tersimpan dengan status tanpa zona.',
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
      final pesan = await _service.hapusZona(zona.id);
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

    if (_daftarZona.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
          const Center(
            child: Text(
              'Belum ada data zona.\nTekan "Tambah Zona" untuk mulai.',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      itemCount: _daftarZona.length,
      itemBuilder: (context, index) {
        final item = _daftarZona[index];
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => widget.onPilihZona?.call(item.id),
          child: Container(
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
                    color: Colors.teal.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.grid_view_rounded,
                    color: Colors.teal[700],
                    size: 22,
                  ),
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
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.teal[50],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${item.tanamanCount} Tanaman Sampel',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal[700],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Ketuk untuk filter →',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (aksi) {
                    if (aksi == 'ubah') {
                      bukaForm(zona: item);
                    } else if (aksi == 'hapus') {
                      _hapusZona(item);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'ubah', child: Text('Ubah')),
                    PopupMenuItem(value: 'hapus', child: Text('Hapus')),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}