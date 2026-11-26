import 'package:flutter_application_1/models/tanaman_model.dart';

class SampelSensor {
  final int id, nomor, tanamanId, zonaId;
  final String nama;
  final Tanaman? tanaman;
  SampelSensor({required this.id, required this.nomor, required this.tanamanId, required this.zonaId, this.nama = '', this.tanaman});
  factory SampelSensor.fromJson(Map<String, dynamic> json) => SampelSensor(
    id: int.parse(json['id'].toString()),
    nomor: int.parse(json['nomor'].toString()),
    nama: (json['nama'] ?? '').toString(),
    tanamanId: int.parse((json['tanaman_id'] ?? json['tanaman']?['id']).toString()),
    zonaId: int.parse(json['zona_id'].toString()),
    tanaman: json['tanaman'] is Map<String, dynamic> ? Tanaman.fromJson(json['tanaman']) : null,
  );
}
