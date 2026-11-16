import 'package:flutter_application_1/models/kategori_model.dart';
import 'package:flutter_application_1/models/zona_model.dart';

class Tanaman {
  final int id;
  final String nama;
  final String jenis;
  final String lokasi;
  final String status;
  final String catatan;
  final int? kategoriId;
  final int? zonaId;
  final Kategori? kategori;
  final Zona? zona;

  Tanaman({
    required this.id,
    required this.nama,
    this.jenis = '',
    this.lokasi = '',
    this.status = 'sehat',
    this.catatan = '',
    this.kategoriId,
    this.zonaId,
    this.kategori,
    this.zona,
  });

  factory Tanaman.fromJson(Map<String, dynamic> json) {
    final kategoriObj = json['kategori'] is Map<String, dynamic>
        ? Kategori.fromJson(json['kategori'])
        : null;
    final zonaObj = json['zona'] is Map<String, dynamic>
        ? Zona.fromJson(json['zona'])
        : null;

    final parsedKategoriId = json['kategori_id'] != null
        ? int.tryParse(json['kategori_id'].toString())
        : kategoriObj?.id;
    final parsedZonaId = json['zona_id'] != null
        ? int.tryParse(json['zona_id'].toString())
        : zonaObj?.id;

    return Tanaman(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      nama: (json['nama'] ?? '').toString(),
      jenis: (json['jenis'] ?? '').toString(),
      lokasi: (json['lokasi'] ?? '').toString(),
      status: (json['status'] ?? 'sehat').toString(),
      catatan: (json['catatan'] ?? '').toString(),
      kategoriId: parsedKategoriId,
      zonaId: parsedZonaId,
      kategori: kategoriObj,
      zona: zonaObj,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'jenis': jenis.isEmpty ? null : jenis,
      'lokasi': lokasi.isEmpty ? null : lokasi,
      'status': status,
      'catatan': catatan.isEmpty ? null : catatan,
      'kategori_id': kategoriId,
      'zona_id': zonaId,
    };
  }
}