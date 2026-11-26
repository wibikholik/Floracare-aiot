import 'package:flutter_application_1/helper/json_helper.dart';
import 'package:flutter_application_1/methods/api.dart';

class PenyiramanService {
  bool _ok(int code) => code == 200 || code == 201;

  String _pesan(dynamic response, String cadangan) =>
      (response is Map ? response['message'] : null)?.toString() ?? cadangan;

  // POST /api/zona/{id}/siram (manual)
  Future<String> siram(int zonaId,
      {required int durasi, required bool campurPupuk}) async {
    final result = await API().postRequest(
      route: '/zona/$zonaId/siram',
      data: {'durasi_detik': durasi, 'campur_pupuk': campurPupuk},
    );
    final response = decodeBody(result.body);
    if (_ok(result.statusCode)) {
      return _pesan(response, 'Perintah penyiraman dikirim');
    }
    throw Exception(parseApiError(response, 'Gagal mengirim perintah siram'));
  }

  // POST /api/perintah/{id}/batal
  Future<String> batal(int perintahId) async {
    final result =
        await API().postRequest(route: '/perintah/$perintahId/batal', data: {});
    final response = decodeBody(result.body);
    if (_ok(result.statusCode)) return _pesan(response, 'Perintah dibatalkan');
    throw Exception(parseApiError(response, 'Gagal membatalkan perintah'));
  }
}