import 'dart:convert';
import 'package:flutter_application_1/methods/api.dart';
import 'package:flutter_application_1/models/tanaman_model.dart';

class TanamanService {
  // READ: GET /api/tanaman
  Future<List<Tanaman>> getTanaman() async {
    final result = await API().getRequest(route: '/tanaman');
    final response = jsonDecode(result.body);

    if (result.statusCode == 200 && response['status'] == 200) {
      final List<dynamic> rawList = response['data'] ?? [];
      return rawList.map((e) => Tanaman.fromJson(e)).toList();
    } else {
      throw Exception(response['message'] ?? 'Gagal memuat data tanaman');
    }
  }

  // CREATE: POST /api/tanaman
  Future<String> tambahTanaman(Map<String, dynamic> data) async {
    final result = await API().postRequest(route: '/tanaman', data: data);
    final response = jsonDecode(result.body);

    if (result.statusCode == 200 || result.statusCode == 201) {
      return response['message'] ?? 'Tanaman berhasil ditambahkan';
    } else {
      throw Exception(response['message'] ?? 'Gagal menambah tanaman');
    }
  }

  // UPDATE: PUT /api/tanaman/{id}
  Future<String> ubahTanaman(int id, Map<String, dynamic> data) async {
    final result = await API().putRequest(route: '/tanaman/$id', data: data);
    final response = jsonDecode(result.body);

    if (result.statusCode == 200) {
      return response['message'] ?? 'Data tanaman berhasil diperbarui';
    } else {
      throw Exception(response['message'] ?? 'Gagal mengubah tanaman');
    }
  }

  // DELETE: DELETE /api/tanaman/{id}
  Future<String> hapusTanaman(int id) async {
    final result = await API().deleteRequest(route: '/tanaman/$id');
    final response = jsonDecode(result.body);

    if (result.statusCode == 200 || result.statusCode == 204) {
      return response['message'] ?? 'Tanaman berhasil dihapus';
    } else {
      throw Exception(response['message'] ?? 'Gagal menghapus tanaman');
    }
  }
}