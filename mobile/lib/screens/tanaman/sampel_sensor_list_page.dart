import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/tanaman_model.dart';
import 'package:flutter_application_1/models/sampel_sensor_model.dart';
import 'package:flutter_application_1/services/sampel_sensor_service.dart';

class SampelSensorListPage extends StatefulWidget {
  final Tanaman tanaman;
  const SampelSensorListPage({super.key, required this.tanaman});
  @override
  State<SampelSensorListPage> createState() => _SampelSensorListPageState();
}
class _SampelSensorListPageState extends State<SampelSensorListPage> {
  final _service = SampelSensorService();
  List<SampelSensor> _items = [];
  bool _loading = true;
  String? _error;
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final items = await _service.getSampel(widget.tanaman.id);
      if (!mounted) return;
      setState(() => _items = items);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally { if (mounted) setState(() => _loading = false); }
  }
  void _snack(String msg, {bool error = false}) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: error ? Colors.red[700] : null));
  Future<void> _form({SampelSensor? item}) async {
    final controller = TextEditingController(text: item?.nama ?? '');
    final result = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(item == null ? 'Tambah Sampel' : 'Ubah Nama Sampel'),
        content: TextField(controller: controller, autofocus: true, maxLength: 255, decoration: const InputDecoration(labelText: 'Nama sampel (opsional)', hintText: 'Contoh: Pot A, Bedeng 1')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: const Text('Simpan')),
        ],
      ),
    );
    controller.dispose();
    if (result == null) return;
    try {
      final msg = item == null ? await _service.tambah(widget.tanaman.id, nama: result) : await _service.ubah(item.id, result);
      _snack(msg); await _load();
    } catch (e) { _snack(e.toString().replaceFirst('Exception: ', ''), error: true); }
  }
  Future<void> _delete(SampelSensor item) async {
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Hapus Sampel'),
      content: Text('Hapus ${item.nama.isEmpty ? 'Sampel ${item.nomor}' : item.nama}? Data sensor sampel terkait juga akan terhapus.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
        FilledButton(style: FilledButton.styleFrom(backgroundColor: Colors.red), onPressed: () => Navigator.pop(ctx, true), child: const Text('Hapus')),
      ],
    ));
    if (ok != true) return;
    try { _snack(await _service.hapus(item.id)); await _load(); }
    catch (e) { _snack(e.toString().replaceFirst('Exception: ', ''), error: true); }
  }
  @override
  Widget build(BuildContext context) {
    final plant = widget.tanaman;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(backgroundColor: Colors.green[700], foregroundColor: Colors.white, title: const Text('Kelola Sampel Sensor')),
      floatingActionButton: FloatingActionButton.extended(backgroundColor: Colors.green[700], foregroundColor: Colors.white, onPressed: () => _form(), icon: const Icon(Icons.add), label: const Text('Tambah Sampel')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
          ? const ListView(children: [SizedBox(height: 260), Center(child: CircularProgressIndicator())])
          : _error != null
            ? ListView(children: [SizedBox(height: 220), Center(child: Text(_error!)), Center(child: TextButton(onPressed: _load, child: const Text('Coba lagi')))])
            : ListView(padding: const EdgeInsets.fromLTRB(16,16,16,90), children: [
                Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(plant.nama, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8), Text('Kategori: ${plant.kategori?.nama ?? '-'}'), Text('Zona: ${plant.zona?.nama ?? '-'}'),
                  const SizedBox(height: 4), const Text('Kategori dan zona mengikuti data tanaman terpilih', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ]))),
                const SizedBox(height: 10),
                if (_items.isEmpty) const Card(child: Padding(padding: EdgeInsets.all(22), child: Center(child: Text('Belum ada sampel sensor untuk tanaman ini')))),
                ..._items.map((item) => Card(child: ListTile(
                  leading: CircleAvatar(backgroundColor: Colors.green[50], child: Icon(Icons.sensors, color: Colors.green[700])),
                  title: Text(item.nama.isEmpty ? 'Sampel ${item.nomor}' : item.nama),
                  subtitle: Text('Nomor sampel ${item.nomor} • ${plant.zona?.nama ?? 'Zona terkait'}'),
                  trailing: PopupMenuButton<String>(onSelected: (value) => value == 'edit' ? _form(item: item) : _delete(item), itemBuilder: (_) => const [PopupMenuItem(value: 'edit', child: Text('Ubah nama')), PopupMenuItem(value: 'delete', child: Text('Hapus'))]),
                ))),
              ]),
      ),
    );
  }
}
