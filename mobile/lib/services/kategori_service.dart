import 'dart:convert';
import 'package:flutter_application_1/methods/api.dart';
import 'package:flutter_application_1/models/kategori_model.dart';

class KategoriService {
  String _parseError(dynamic response, String fallback) {
    if (response is Map<String, dynamic>) {
      if (response['errors'] is Map) {
        final errors = response['errors'] as Map;
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          return firstError.first.toString();
        }
      }
      if (response['message'] != null) {
        return response['message'].toString();
      }
    }
    return fallback;
  }

  // READ: GET /api/kategori
  Future<List<Kategori>> getKategori() async {
    final result = await API().getRequest(route: '/kategori');
    final response = jsonDecode(result.body);

    if (result.statusCode == 200) {
      final List<dynamic> rawList =
          response is List ? response : (response['data'] ?? []);
      return rawList.map((e) => Kategori.fromJson(e)).toList();
    } else {
      throw Exception(_parseError(response, 'Gagal memuat data kategori'));
    }
  }

  // CREATE: POST /api/kategori
  Future<String> tambahKategori(Map<String, dynamic> data) async {
    final result = await API().postRequest(route: '/kategori', data: data);
    final response = jsonDecode(result.body);

    if (result.statusCode == 200 || result.statusCode == 201) {
      return (response is Map ? response['message'] : null) ??
          'Kategori berhasil ditambahkan';
    } else {
      throw Exception(_parseError(response, 'Gagal menambah kategori'));
    }
  }

  // UPDATE: PUT /api/kategori/{id}
  Future<String> ubahKategori(int id, Map<String, dynamic> data) async {
    final result = await API().putRequest(route: '/kategori/$id', data: data);
    final response = jsonDecode(result.body);

    if (result.statusCode == 200) {
      return (response is Map ? response['message'] : null) ??
          'Kategori berhasil diperbarui';
    } else {
      throw Exception(_parseError(response, 'Gagal mengubah kategori'));
    }
  }

  // DELETE: DELETE /api/kategori/{id}
  Future<String> hapusKategori(int id) async {
    final result = await API().deleteRequest(route: '/kategori/$id');
    final response =
        result.body.isNotEmpty ? jsonDecode(result.body) : <String, dynamic>{};

    if (result.statusCode == 200 || result.statusCode == 204) {
      return (response is Map ? response['message'] : null) ??
          'Kategori berhasil dihapus';
    } else {
      throw Exception(_parseError(response, 'Gagal menghapus kategori'));
    }
  }
}