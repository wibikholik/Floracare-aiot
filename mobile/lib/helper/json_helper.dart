import 'dart:convert';

dynamic decodeBody(String body) {
  try {
    return jsonDecode(body);
  } catch (_) {
    return null;
  }
}

String parseApiError(dynamic response, String fallback) {
  if (response is Map<String, dynamic>) {
    if (response['errors'] is Map) {
      final errors = response['errors'] as Map;
      if (errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) return first.first.toString();
      }
    }
    if (response['message'] != null) return response['message'].toString();
  }
  return fallback;
}

String bersihkanError(Object e) => e.toString().replaceFirst('Exception: ', '');

double? toDoubleOrNull(dynamic v) => v == null ? null : double.tryParse(v.toString());
int toIntValue(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;
bool toBoolValue(dynamic v) => v == true || v == 1 || v == '1';
DateTime? toWaktu(dynamic v) =>
    v == null ? null : DateTime.tryParse(v.toString())?.toLocal();

String formatWaktu(DateTime? d) {
  if (d == null) return '-';
  String dua(int n) => n.toString().padLeft(2, '0');
  return '${dua(d.day)}/${dua(d.month)} ${dua(d.hour)}:${dua(d.minute)}';
}