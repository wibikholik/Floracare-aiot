import 'dart:convert';
import 'package:flutter_application_1/helper/constant.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

final String baseUrl = apiurl;

class API {
  // Helper internal untuk membaca token Sanctum dan menyusun Header
  Future<Map<String, String>> _getHeaders({Map<String, String>? customHeaders}) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }

    return headers;
  }

  // 1. Eksekusi HTTP POST Request
  Future<http.Response> postRequest({
    required String route,
    required Map<String, dynamic> data,
    Map<String, String>? customHeaders,
  }) async {
    String url = baseUrl + route;
    try {
      Map<String, String> headers = await _getHeaders(customHeaders: customHeaders);

      print('==============================');
      print('🌐 API REQUEST [POST]: $url');
      print('📦 Request Body: ${jsonEncode(data)}');
      print('==============================');

      http.Response response = await http.post(
        Uri.parse(url),
        body: jsonEncode(data),
        headers: headers,
      );

      print('==============================');
      print('📥 API RESPONSE: $url');
      print('🔢 Status Code: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');
      print('==============================');

      return response;
    } catch (e) {
      print('❌ POST Error: $e');
      rethrow;
    }
  }

  // 2. Eksekusi HTTP GET Request
  Future<http.Response> getRequest({
    required String route,
    Map<String, String>? customHeaders,
  }) async {
    String url = baseUrl + route;
    try {
      Map<String, String> headers = await _getHeaders(customHeaders: customHeaders);

      print('==============================');
      print('🌐 API REQUEST [GET]: $url');
      print('📦 Request Headers: $headers');
      print('==============================');

      http.Response response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('==============================');
      print('📥 API RESPONSE: $url');
      print('🔢 Status Code: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');
      print('==============================');

      return response;
    } catch (e) {
      print('❌ GET Error: $e');
      rethrow;
    }
  }

  // 3. Eksekusi HTTP PUT Request (untuk Update)
  Future<http.Response> putRequest({
    required String route,
    required Map<String, dynamic> data,
    Map<String, String>? customHeaders,
  }) async {
    String url = baseUrl + route;
    try {
      Map<String, String> headers = await _getHeaders(customHeaders: customHeaders);

      print('==============================');
      print('🌐 API REQUEST [PUT]: $url');
      print('📦 Request Body: ${jsonEncode(data)}');
      print('==============================');

      http.Response response = await http.put(
        Uri.parse(url),
        body: jsonEncode(data),
        headers: headers,
      );

      print('==============================');
      print('📥 API RESPONSE: $url');
      print('🔢 Status Code: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');
      print('==============================');

      return response;
    } catch (e) {
      print('❌ PUT Error: $e');
      rethrow;
    }
  }

  // 4. Eksekusi HTTP DELETE Request (untuk Hapus)
  Future<http.Response> deleteRequest({
    required String route,
    Map<String, String>? customHeaders,
  }) async {
    String url = baseUrl + route;
    try {
      Map<String, String> headers = await _getHeaders(customHeaders: customHeaders);

      print('==============================');
      print('🌐 API REQUEST [DELETE]: $url');
      print('==============================');

      http.Response response = await http.delete(
        Uri.parse(url),
        headers: headers,
      );

      print('==============================');
      print('📥 API RESPONSE: $url');
      print('🔢 Status Code: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');
      print('==============================');

      return response;
    } catch (e) {
      print('❌ DELETE Error: $e');
      rethrow;
    }
  }
}