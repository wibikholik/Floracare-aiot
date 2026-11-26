import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/tanaman_model.dart';
import 'package:flutter_application_1/models/zona_model.dart';
import 'package:flutter_application_1/screens/tanaman/kategori/kategori_list_page.dart';
import 'package:flutter_application_1/screens/tanaman/tanaman_form_page.dart';
import 'package:flutter_application_1/screens/tanaman/sampel_sensor_list_page.dart';
import 'package:flutter_application_1/screens/tanaman/zona/zona_list_page.dart';
import 'package:flutter_application_1/services/tanaman_service.dart';
import 'package:flutter_application_1/services/zona_service.dart';

class TanamanListPage extends StatefulWidget {
  final int? initialZonaId;

  const TanamanListPage({super.key, this.initialZonaId});

  @override
  State<TanamanListPage> createState() => _TanamanListPageState();
}

class _TanamanListPageState extends State<TanamanListPage>
    with SingleTickerProviderStateMixin {
  final _tanamanService = TanamanService();
  final _zonaService = ZonaService();

  late final TabController _tabController;
  final _zonaKey = GlobalKey<ZonaListViewState>();
  final _kategoriKey = GlobalKey<KategoriListViewState>();

  List<Tanaman> _daftarTanaman = [];
  List<Zona> _daftarZona = [];
  int? _filterZonaId;

  bool _isLoading = true;
  String? _pesanError;

  @override
  void initState() {
    super.initState();
    _filterZonaId = widget.initialZonaId;
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    _muatAwal();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _muatAwal() async {
    await _ambilDaftarZona();
    await _ambilTanaman();
  }

  Future<void> _ambilDaftarZona() async {
    try {
      final zonas = await _zonaService.getZona();
      if (!mounted) return;
      setState(() {
        _daftarZona = zonas;
        if (_filterZonaId != null &&
            !_daftarZona.any((z) => z.id == _filterZonaId)) {
          _filterZonaId = null;
        }
      });
    } catch (_) {}
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
      final data = await _tanamanService.getTanaman(zonaId: _filterZonaId);
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

  Future<void> _bukaFormTanaman({Tanaman? tanaman}) async {
    final berhasil = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TanamanFormPage(
          tanaman: tanaman,
          defaultZonaId: _filterZonaId,
        ),
      ),
    );

    if (berhasil == true) {
      await _ambilTanaman();
      _zonaKey.currentState?.reload();
      _kategoriKey.currentState?.reload();
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
      final pesan = await _tanamanService.hapusTanaman(tanaman.id);
      _snack(pesan);
      await _ambilTanaman();
      _zonaKey.currentState?.reload();
      _kategoriKey.currentState?.reload();
    } catch (e) {
      _snack(
        e.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    }
  }

  void _aksiTombolTambah() {
    if (_tabController.index == 0) {
      _bukaFormTanaman();
    } else if (_tabController.index == 1) {
      _zonaKey.currentState?.bukaForm();
    } else {
      _kategoriKey.currentState?.bukaForm();
    }
  }

  String get _labelTombolTambah {
    if (_tabController.index == 1) return 'Tambah Zona';
    if (_tabController.index == 2) return 'Tambah Kategori';
    return 'Tambah Tanaman';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        title: const Text('Manajemen Tanaman'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Perbarui Semua',
            onPressed: () {
              _muatAwal();
              _zonaKey.currentState?.reload();
              _kategoriKey.currentState?.reload();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.eco, size: 18), text: 'Tanaman'),
            Tab(icon: Icon(Icons.grid_view_rounded, size: 18), text: 'Zona'),
            Tab(icon: Icon(Icons.category, size: 18), text: 'Kategori'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        onPressed: _aksiTombolTambah,
        icon: const Icon(Icons.add),
        label: Text(_labelTombolTambah),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Daftar Tanaman
          Column(
            children: [
              if (_daftarZona.isNotEmpty) _barFilterZona(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _muatAwal,
                  child: _buildTabTanaman(),
                ),
              ),
            ],
          ),
          // Tab 2: Kelola Zona
          ZonaListView(
            key: _zonaKey,
            onDataChanged: () async {
              await _ambilDaftarZona();
              await _ambilTanaman();
            },
            onPilihZona: (zonaId) {
              setState(() => _filterZonaId = zonaId);
              _tabController.animateTo(0);
              _ambilTanaman();
            },
          ),
          // Tab 3: Kelola Kategori
          KategoriListView(
            key: _kategoriKey,
            onDataChanged: _ambilTanaman,
          ),
        ],
      ),
    );
  }

  Widget _barFilterZona() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ChoiceChip(
              label: const Text('Semua Zona'),
              selected: _filterZonaId == null,
              selectedColor: Colors.green[100],
              onSelected: (_) {
                setState(() => _filterZonaId = null);
                _ambilTanaman();
              },
            ),
            const SizedBox(width: 8),
            ..._daftarZona.map((z) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(z.nama),
                  selected: _filterZonaId == z.id,
                  selectedColor: Colors.green[100],
                  onSelected: (_) {
                    setState(() => _filterZonaId = z.id);
                    _ambilTanaman();
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTabTanaman() {
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
            _filterZonaId == null
                ? 'Belum ada tanaman'
                : 'Belum ada tanaman di zona ini',
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
                    'Posisi: ${t.lokasi}',
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
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _chipLabel(t.status, bgStatus, textStatus),
                    if (t.zona != null)
                      _chipLabel(
                        t.zona!.nama,
                        Colors.teal[50]!,
                        Colors.teal[700]!,
                      ),
                    if (t.kategori != null)
                      _chipLabel(
                        t.kategori!.nama,
                        Colors.purple[50]!,
                        Colors.purple[700]!,
                      ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (aksi) {
              if (aksi == 'ubah') {
                _bukaFormTanaman(tanaman: t);
              } else if (aksi == 'sampel') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => SampelSensorListPage(tanaman: t)));
              } else if (aksi == 'hapus') {
                _hapusTanaman(t);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'ubah', child: Text('Ubah')),
              PopupMenuItem(value: 'sampel', child: Text('Kelola Sampel Sensor')),
              PopupMenuItem(value: 'hapus', child: Text('Hapus')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chipLabel(String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: text,
        ),
      ),
    );
  }
}