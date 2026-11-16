import 'dart:convert';
import 'package:flutter_application_1/methods/api.dart';
import 'package:flutter_application_1/models/tanaman_model.dart';

class TanamanService {
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

  // READ: GET /api/tanaman (mendukung filter ?zona_id=... & ?kategori_id=...)
  Future<List<Tanaman>> getTanaman({int? zonaId, int? kategoriId}) async {
    final queryParams = <String>[];
    if (zonaId != null) queryParams.add('zona_id=$zonaId');
    if (kategoriId != null) queryParams.add('kategori_id=$kategoriId');

    final route = queryParams.isEmpty
        ? '/tanaman'
        : '/tanaman?${queryParams.join('&')}';

    final result = await API().getRequest(route: route);
    final response = jsonDecode(result.body);

    if (result.statusCode == 200) {
      final List<dynamic> rawList =
          response is List ? response : (response['data'] ?? []);
      return rawList.map((e) => Tanaman.fromJson(e)).toList();
    } else {
      throw Exception(_parseError(response, 'Gagal memuat data tanaman'));
    }
  }

  // CREATE: POST /api/tanaman
  Future<String> tambahTanaman(Map<String, dynamic> data) async {
    final result = await API().postRequest(route: '/tanaman', data: data);
    final response = jsonDecode(result.body);

    if (result.statusCode == 200 || result.statusCode == 201) {
      return (response is Map ? response['message'] : null) ??
          'Tanaman berhasil ditambahkan';
    } else {
      throw Exception(_parseError(response, 'Gagal menambah tanaman'));
    }
  }

  // UPDATE: PUT /api/tanaman/{id}
  Future<String> ubahTanaman(int id, Map<String, dynamic> data) async {
    final result = await API().putRequest(route: '/tanaman/$id', data: data);
    final response = jsonDecode(result.body);

    if (result.statusCode == 200) {
      return (response is Map ? response['message'] : null) ??
          'Data tanaman berhasil diperbarui';
    } else {
      throw Exception(_parseError(response, 'Gagal mengubah tanaman'));
    }
  }

  // DELETE: DELETE /api/tanaman/{id}
  Future<String> hapusTanaman(int id) async {
    final result = await API().deleteRequest(route: '/tanaman/$id');
    final response =
        result.body.isNotEmpty ? jsonDecode(result.body) : <String, dynamic>{};

    if (result.statusCode == 200 || result.statusCode == 204) {
      return (response is Map ? response['message'] : null) ??
          'Tanaman berhasil dihapus';
    } else {
      throw Exception(_parseError(response, 'Gagal menghapus tanaman'));
    }
  }
}