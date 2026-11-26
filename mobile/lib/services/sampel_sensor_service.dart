import 'dart:convert';
import 'package:flutter_application_1/methods/api.dart';
import 'package:flutter_application_1/models/sampel_sensor_model.dart';

class SampelSensorService {
  String _error(dynamic response, String fallback) {
    if (response is Map<String, dynamic>) {
      final errors = response['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) return first.first.toString();
      }
      if (response['message'] != null) return response['message'].toString();
    }
    return fallback;
  }
  Future<List<SampelSensor>> getSampel(int tanamanId) async {
    final result = await API().getRequest(route: '/sampel-sensor?tanaman_id=$tanamanId');
    final decoded = jsonDecode(result.body);
    if (result.statusCode == 200) {
      final data = decoded is Map ? decoded['data'] : decoded;
      return (data as List).map((e) => SampelSensor.fromJson(e)).toList();
    }
    throw Exception(_error(decoded, 'Gagal memuat sampel'));
  }
  Future<String> tambah(int tanamanId, {String? nama}) async {
    final result = await API().postRequest(route: '/sampel-sensor', data: {'tanaman_id': tanamanId, 'nama': nama?.trim().isEmpty == true ? null : nama?.trim()});
    final decoded = jsonDecode(result.body);
    if (result.statusCode == 200 || result.statusCode == 201) return decoded['message']?.toString() ?? 'Sampel berhasil ditambahkan';
    throw Exception(_error(decoded, 'Gagal menambah sampel'));
  }
  Future<String> ubah(int id, String? nama) async {
    final result = await API().putRequest(route: '/sampel-sensor/$id', data: {'nama': nama?.trim().isEmpty == true ? null : nama?.trim()});
    final decoded = jsonDecode(result.body);
    if (result.statusCode == 200) return decoded['message']?.toString() ?? 'Sampel diperbarui';
    throw Exception(_error(decoded, 'Gagal memperbarui sampel'));
  }
  Future<String> hapus(int id) async {
    final result = await API().deleteRequest(route: '/sampel-sensor/$id');
    final decoded = result.body.isNotEmpty ? jsonDecode(result.body) : {};
    if (result.statusCode == 200 || result.statusCode == 204) return decoded['message']?.toString() ?? 'Sampel dihapus';
    throw Exception(_error(decoded, 'Gagal menghapus sampel'));
  }
}
