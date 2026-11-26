import 'package:flutter_application_1/helper/json_helper.dart';
import 'package:flutter_application_1/methods/api.dart';
import 'package:flutter_application_1/models/monitoring_model.dart';

class MonitoringService {
  // GET /api/monitoring
  Future<List<MonitoringZona>> semuaZona() async {
    final result = await API().getRequest(route: '/monitoring');
    final response = decodeBody(result.body);

    if (result.statusCode == 200 && response is Map) {
      final list = (response['data'] as List?) ?? [];
      return list
          .map((e) => MonitoringZona.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception(parseApiError(response, 'Gagal memuat monitoring'));
  }

  // GET /api/zona/{id}/monitoring
  Future<MonitoringZona> satuZona(int zonaId) async {
    final result = await API().getRequest(route: '/zona/$zonaId/monitoring');
    final response = decodeBody(result.body);

    if (result.statusCode == 200 && response is Map) {
      return MonitoringZona.fromJson(response['data'] as Map<String, dynamic>);
    }
    throw Exception(parseApiError(response, 'Gagal memuat status zona'));
  }

  // GET /api/zona/{id}/monitoring/riwayat?jam=24
  Future<List<TitikSensor>> riwayatSensor(int zonaId, {int jam = 24}) async {
    final result =
        await API().getRequest(route: '/zona/$zonaId/monitoring/riwayat?jam=$jam');
    final response = decodeBody(result.body);

    if (result.statusCode == 200 && response is Map) {
      final list = (response['data'] as List?) ?? [];
      return list
          .map((e) => e as Map<String, dynamic>)
          .where((e) => toDoubleOrNull(e['kelembapan_tanah']) != null)
          .map((e) => TitikSensor(
                kelembapanTanah: toDoubleOrNull(e['kelembapan_tanah'])!,
                waktu: toWaktu(e['created_at']),
              ))
          .toList();
    }
    throw Exception(parseApiError(response, 'Gagal memuat grafik'));
  }
}