import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/kategori_model.dart';
import 'package:flutter_application_1/models/tanaman_model.dart';
import 'package:flutter_application_1/models/zona_model.dart';
import 'package:flutter_application_1/services/kategori_service.dart';
import 'package:flutter_application_1/services/tanaman_service.dart';
import 'package:flutter_application_1/services/zona_service.dart';

class TanamanFormPage extends StatefulWidget {
  final Tanaman? tanaman;
  final int? defaultZonaId;

  const TanamanFormPage({super.key, this.tanaman, this.defaultZonaId});

  @override
  State<TanamanFormPage> createState() => _TanamanFormPageState();
}

class _TanamanFormPageState extends State<TanamanFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _tanamanService = TanamanService();
  final _kategoriService = KategoriService();
  final _zonaService = ZonaService();

  late final TextEditingController _namaController;
  late final TextEditingController _jenisController;
  late final TextEditingController _lokasiController;
  late final TextEditingController _catatanController;

  late String _selectedStatus;
  int? _selectedKategoriId;
  int? _selectedZonaId;

  List<Kategori> _daftarKategori = [];
  List<Zona> _daftarZona = [];
  bool _isLoadingDropdown = true;
  bool _isSubmitting = false;

  bool get _isEdit => widget.tanaman != null;

  final List<String> _pilihanStatus = [
    'sehat',
    'perlu disiram',
    'terserang hama',
  ];

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.tanaman?.nama ?? '');
    _jenisController = TextEditingController(text: widget.tanaman?.jenis ?? '');
    _lokasiController =
        TextEditingController(text: widget.tanaman?.lokasi ?? '');
    _catatanController =
        TextEditingController(text: widget.tanaman?.catatan ?? '');

    final statusAwal = widget.tanaman?.status ?? 'sehat';
    if (!_pilihanStatus.contains(statusAwal)) {
      _pilihanStatus.add(statusAwal);
    }
    _selectedStatus = statusAwal;
    _selectedKategoriId = widget.tanaman?.kategoriId;
    _selectedZonaId = widget.tanaman?.zonaId ?? widget.defaultZonaId;

    _muatKategoriDanZona();
  }

  Future<void> _muatKategoriDanZona() async {
    try {
      final results = await Future.wait([
        _kategoriService.getKategori(),
        _zonaService.getZona(),
      ]);

      if (!mounted) return;
      final kategoriList = results[0] as List<Kategori>;
      final zonaList = results[1] as List<Zona>;

      setState(() {
        _daftarKategori = kategoriList;
        _daftarZona = zonaList;

        // Pastikan ID awal ada di daftar agar dropdown tidak error
        if (_selectedKategoriId != null &&
            !_daftarKategori.any((k) => k.id == _selectedKategoriId)) {
          _selectedKategoriId = null;
        }
        if (_selectedZonaId != null &&
            !_daftarZona.any((z) => z.id == _selectedZonaId)) {
          _selectedZonaId = null;
        }
        _isLoadingDropdown = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingDropdown = false);
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _jenisController.dispose();
    _lokasiController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final nama = _namaController.text.trim();
    final jenis = _jenisController.text.trim();
    final lokasi = _lokasiController.text.trim();
    final catatan = _catatanController.text.trim();

    final body = <String, dynamic>{
      'nama': nama,
      'jenis': jenis.isEmpty ? null : jenis,
      'lokasi': lokasi.isEmpty ? null : lokasi,
      'catatan': catatan.isEmpty ? null : catatan,
      'status': _selectedStatus,
      'kategori_id': _selectedKategoriId,
      'zona_id': _selectedZonaId,
    };

    try {
      final pesan = _isEdit
          ? await _tanamanService.ubahTanaman(widget.tanaman!.id, body)
          : await _tanamanService.tambahTanaman(body);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(pesan)),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red[700],
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        title: Text(_isEdit ? 'Ubah Tanaman' : 'Tambah Tanaman'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _namaController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Tanaman *',
                    hintText: 'Contoh: Monstera Deliciosa',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama tanaman wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                if (_isLoadingDropdown)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: LinearProgressIndicator(color: Colors.green),
                    ),
                  )
                else ...[
                  DropdownButtonFormField<int?>(
                    initialValue: _selectedZonaId,
                    decoration: const InputDecoration(
                      labelText: 'Zona Penempatan',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('-- Tanpa Zona --'),
                      ),
                      ..._daftarZona.map(
                        (z) => DropdownMenuItem<int?>(
                          value: z.id,
                          child: Text(z.nama),
                        ),
                      ),
                    ],
                    onChanged: (nilai) {
                      setState(() => _selectedZonaId = nilai);
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int?>(
                    initialValue: _selectedKategoriId,
                    decoration: const InputDecoration(
                      labelText: 'Kategori Tanaman',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('-- Tanpa Kategori --'),
                      ),
                      ..._daftarKategori.map(
                        (k) => DropdownMenuItem<int?>(
                          value: k.id,
                          child: Text(k.nama),
                        ),
                      ),
                    ],
                    onChanged: (nilai) {
                      setState(() => _selectedKategoriId = nilai);
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  controller: _jenisController,
                  decoration: const InputDecoration(
                    labelText: 'Jenis / Varietas',
                    hintText: 'Contoh: Variegata / Aglaonema Red',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _lokasiController,
                  decoration: const InputDecoration(
                    labelText: 'Detail Posisi / Nomor Sampel',
                    hintText: 'Contoh: Sampel 1 - Rak Kiri',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status Tanaman',
                    border: OutlineInputBorder(),
                  ),
                  items: _pilihanStatus
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (nilai) {
                    if (nilai != null) {
                      setState(() => _selectedStatus = nilai);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _catatanController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Catatan Perawatan',
                    hintText: 'Contoh: Batas kelembapan min 45%, siram pagi hari',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _isSubmitting ? null : _simpan,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(_isEdit ? 'Simpan Perubahan' : 'Simpan Tanaman'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}