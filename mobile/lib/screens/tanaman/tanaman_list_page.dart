import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/tanaman_model.dart';
import 'package:flutter_application_1/screens/tanaman/tanaman_form_page.dart';
import 'package:flutter_application_1/services/tanaman_service.dart';

class TanamanListPage extends StatefulWidget {
  const TanamanListPage({super.key});

  @override
  State<TanamanListPage> createState() => _TanamanListPageState();
}

class _TanamanListPageState extends State<TanamanListPage> {
  final _service = TanamanService();
  List<Tanaman> _daftarTanaman = [];
  bool _isLoading = true;
  String? _pesanError;

  @override
  void initState() {
    super.initState();
    _ambilTanaman();
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

  Future<void> _ambilTanaman() async {
    setState(() {
      _isLoading = true;
      _pesanError = null;
    });

    try {
      final data = await _service.getTanaman();
      if (!mounted) return;
      setState(() {
        _daftarTanaman = data;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _pesanError = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _bukaForm({Tanaman? tanaman}) async {
    final berhasil = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TanamanFormPage(tanaman: tanaman),
      ),
    );

    if (berhasil == true) {
      _ambilTanaman();
    }
  }

  Future<void> _hapusTanaman(Tanaman tanaman) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Tanaman'),
        content: Text('Hapus "${tanaman.nama}"? Data tidak bisa dikembalikan.'),
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
      final pesan = await _service.hapusTanaman(tanaman.id);
      _snack(pesan);
      _ambilTanaman();
    } catch (e) {
      _snack(
        e.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        title: const Text('Data Tanaman'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _ambilTanaman,
            tooltip: 'Perbarui Data',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        onPressed: () => _bukaForm(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Tanaman'),
      ),
      body: RefreshIndicator(
        onRefresh: _ambilTanaman,
        child: _buildBody(),
      ),
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
          _pesanKosong(
            Icons.cloud_off,
            _pesanError!,
            'Tarik ke bawah untuk coba lagi',
          ),
        ],
      );
    }

    if (_daftarTanaman.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
          _pesanKosong(
            Icons.eco_outlined,
            'Belum ada tanaman',
            'Tekan tombol "Tambah Tanaman" untuk mulai',
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      itemCount: _daftarTanaman.length,
      itemBuilder: (context, index) => _kartuTanaman(_daftarTanaman[index]),
    );
  }

  Widget _pesanKosong(IconData icon, String judul, String keterangan) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
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

  Widget _kartuTanaman(Tanaman t) {
    final statusLower = t.status.toLowerCase();
    final Color bgStatus;
    final Color textStatus;

    if (statusLower == 'sehat') {
      bgStatus = Colors.green[50]!;
      textStatus = Colors.green[700]!;
    } else if (statusLower.contains('hama')) {
      bgStatus = Colors.red[50]!;
      textStatus = Colors.red[700]!;
    } else {
      bgStatus = Colors.orange[50]!;
      textStatus = Colors.orange[800]!;
    }

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
                  t.nama,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (t.jenis.isNotEmpty)
                  Text(
                    t.jenis,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                if (t.lokasi.isNotEmpty)
                  Text(
                    'Zona/Lokasi: ${t.lokasi}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                if (t.catatan.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      t.catatan,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: bgStatus,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    t.status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: textStatus,
                    ),
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (aksi) {
              if (aksi == 'ubah') {
                _bukaForm(tanaman: t);
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