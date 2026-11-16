import 'dart:convert';
import 'package:flutter_application_1/methods/api.dart';
import 'package:flutter_application_1/models/zona_model.dart';

class ZonaService {
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

  // READ: GET /api/zona
  Future<List<Zona>> getZona() async {
    final result = await API().getRequest(route: '/zona');
    final response = jsonDecode(result.body);

    if (result.statusCode == 200) {
      final List<dynamic> rawList =
          response is List ? response : (response['data'] ?? []);
      return rawList.map((e) => Zona.fromJson(e)).toList();
    } else {
      throw Exception(_parseError(response, 'Gagal memuat data zona'));
    }
  }

  // CREATE: POST /api/zona
  Future<String> tambahZona(Map<String, dynamic> data) async {
    final result = await API().postRequest(route: '/zona', data: data);
    final response = jsonDecode(result.body);

    if (result.statusCode == 200 || result.statusCode == 201) {
      return (response is Map ? response['message'] : null) ??
          'Zona berhasil ditambahkan';
    } else {
      throw Exception(_parseError(response, 'Gagal menambah zona'));
    }
  }

  // UPDATE: PUT /api/zona/{id}
  Future<String> ubahZona(int id, Map<String, dynamic> data) async {
    final result = await API().putRequest(route: '/zona/$id', data: data);
    final response = jsonDecode(result.body);

    if (result.statusCode == 200) {
      return (response is Map ? response['message'] : null) ??
          'Zona berhasil diperbarui';
    } else {
      throw Exception(_parseError(response, 'Gagal mengubah zona'));
    }
  }

  // DELETE: DELETE /api/zona/{id}
  Future<String> hapusZona(int id) async {
    final result = await API().deleteRequest(route: '/zona/$id');
    final response =
        result.body.isNotEmpty ? jsonDecode(result.body) : <String, dynamic>{};

    if (result.statusCode == 200 || result.statusCode == 204) {
      return (response is Map ? response['message'] : null) ??
          'Zona berhasil dihapus';
    } else {
      throw Exception(_parseError(response, 'Gagal menghapus zona'));
    }
  }
}