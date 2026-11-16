import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/zona_model.dart';
import 'package:flutter_application_1/services/zona_service.dart';

class ZonaFormPage extends StatefulWidget {
  final Zona? zona;

  const ZonaFormPage({super.key, this.zona});

  @override
  State<ZonaFormPage> createState() => _ZonaFormPageState();
}

class _ZonaFormPageState extends State<ZonaFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _service = ZonaService();

  late final TextEditingController _namaController;
  late final TextEditingController _deskripsiController;
  bool _isSubmitting = false;

  bool get _isEdit => widget.zona != null;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.zona?.nama ?? '');
    _deskripsiController =
        TextEditingController(text: widget.zona?.deskripsi ?? '');
  }

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final nama = _namaController.text.trim();
    final deskripsi = _deskripsiController.text.trim();

    final body = <String, dynamic>{
      'nama_zona': nama,
      'nama': nama,
      'deskripsi': deskripsi.isEmpty ? null : deskripsi,
      'keterangan': deskripsi.isEmpty ? null : deskripsi,
    };

    try {
      final pesan = _isEdit
          ? await _service.ubahZona(widget.zona!.id, body)
          : await _service.tambahZona(body);

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
        title: Text(_isEdit ? 'Ubah Zona' : 'Tambah Zona'),
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
                    labelText: 'Nama Zona *',
                    hintText: 'Contoh: Zona 1',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama zona wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _deskripsiController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi / Keterangan Zona',
                    hintText: 'Contoh: Area penempatan tanaman zona 1',
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
                        : Text(_isEdit ? 'Simpan Perubahan' : 'Simpan Zona'),
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