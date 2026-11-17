import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/helper/constant.dart';
import '../models/deteksi_penyakit.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class DeteksiPenyakitService {
  // Mengambil token Sanctum dari SharedPreferences
  Future<String?> _token() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, String>> _headers({bool json = false}) async {
    final token = await _token();
    return {
      'Accept': 'application/json',
      if (json) 'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // Ambil pesan error dari respons Laravel (aman kalau body bukan JSON)
  String _pesanError(http.Response res, String cadangan) {
    try {
      final body = jsonDecode(res.body);
      if (body is Map && body['message'] != null) {
        return body['message'].toString();
      }
    } catch (_) {}
    return '$cadangan (${res.statusCode})';
  }

    // 1. Kirim foto untuk dianalisis. tanamanId opsional (null = foto bebas)
  Future<DeteksiPenyakit> analisis({
    int? tanamanId,
    required File foto,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$apiurl/deteksi-penyakit'),
    );
    request.headers.addAll(await _headers());
    if (tanamanId != null) {
      request.fields['tanaman_id'] = tanamanId.toString();
    }
    request.files.add(await http.MultipartFile.fromPath('foto', foto.path));

    final streamed = await request.send().timeout(const Duration(seconds: 90));
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return DeteksiPenyakit.fromJson(decoded['data'] as Map<String, dynamic>);
    }
    throw ApiException(_pesanError(response, 'Gagal menganalisis foto tanaman'));
  }

  // 2. Riwayat deteksi (Laravel paginate: data.data)
  Future<List<DeteksiPenyakit>> riwayat({
    int? tanamanId,
    String? statusKondisi,
    int page = 1,
  }) async {
    final uri = Uri.parse('$apiurl/deteksi-penyakit').replace(
      queryParameters: {
        'page': page.toString(),
        if (tanamanId != null) 'tanaman_id': tanamanId.toString(),
        if (statusKondisi != null && statusKondisi.isNotEmpty)
          'status_kondisi': statusKondisi,
      },
    );

    final response = await http.get(uri, headers: await _headers());

    if (response.statusCode != 200) {
      throw ApiException(_pesanError(response, 'Gagal memuat riwayat deteksi'));
    }

    final decoded = jsonDecode(response.body);
    final raw = decoded['data'];
    final List list = raw is List
        ? raw
        : (raw is Map && raw['data'] is List ? raw['data'] : []);

    return list
        .map((e) => DeteksiPenyakit.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // 3. Ubah status penanganan / catatan
  Future<void> ubahStatus(
    int id, {
    bool? sudahDitangani,
    String? catatan,
  }) async {
    final response = await http.patch(
      Uri.parse('$apiurl/deteksi-penyakit/$id'),
      headers: await _headers(json: true),
      body: jsonEncode({
        if (sudahDitangani != null) 'sudah_ditangani': sudahDitangani,
        if (catatan != null) 'catatan': catatan,
      }),
    );

    if (response.statusCode != 200) {
      throw ApiException(_pesanError(response, 'Gagal memperbarui status'));
    }
  }

  // 4. Hapus riwayat
  Future<void> hapus(int id) async {
    final response = await http.delete(
      Uri.parse('$apiurl/deteksi-penyakit/$id'),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw ApiException(_pesanError(response, 'Gagal menghapus data deteksi'));
    }
  }
}