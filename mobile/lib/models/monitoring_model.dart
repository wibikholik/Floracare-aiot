import 'package:flutter_application_1/helper/json_helper.dart';

class SensorData {
  final double? suhu;
  final double? kelembapanUdara;
  final double? kelembapanTanah;
  final double? phTanah;
  final DateTime? waktu;

  SensorData({
    this.suhu,
    this.kelembapanUdara,
    this.kelembapanTanah,
    this.phTanah,
    this.waktu,
  });

  factory SensorData.fromJson(Map<String, dynamic> j) => SensorData(
        suhu: toDoubleOrNull(j['suhu']),
        kelembapanUdara: toDoubleOrNull(j['kelembapan_udara']),
        kelembapanTanah: toDoubleOrNull(j['kelembapan_tanah']),
        phTanah: toDoubleOrNull(j['ph_tanah']),
        waktu: toWaktu(j['waktu'] ?? j['created_at']),
      );
}

class PerintahAktif {
  final int id;
  final String sumber;
  final String status; // pending | dikirim
  final int durasiDetik;

  PerintahAktif({
    required this.id,
    required this.sumber,
    required this.status,
    required this.durasiDetik,
  });

  bool get menunggu => status == 'pending';

  factory PerintahAktif.fromJson(Map<String, dynamic> j) => PerintahAktif(
        id: toIntValue(j['id']),
        sumber: (j['sumber'] ?? '').toString(),
        status: (j['status'] ?? '').toString(),
        durasiDetik: toIntValue(j['durasi_detik']),
      );
}

class MonitoringZona {
  final int zonaId;
  final String namaZona;
  final String status; // normal | kering | basah | offline
  final SensorData? sensor;
  final bool otomatisAktif;
  final PerintahAktif? perintahAktif;

  MonitoringZona({
    required this.zonaId,
    required this.namaZona,
    required this.status,
    this.sensor,
    this.otomatisAktif = false,
    this.perintahAktif,
  });

  factory MonitoringZona.fromJson(Map<String, dynamic> j) => MonitoringZona(
        zonaId: toIntValue(j['zona_id']),
        namaZona: (j['nama_zona'] ?? '').toString(),
        status: (j['status'] ?? 'offline').toString(),
        sensor: j['sensor'] is Map<String, dynamic>
            ? SensorData.fromJson(j['sensor'])
            : null,
        otomatisAktif: toBoolValue(j['otomatis_aktif']),
        perintahAktif: j['perintah_aktif'] is Map<String, dynamic>
            ? PerintahAktif.fromJson(j['perintah_aktif'])
            : null,
      );
}

class TitikSensor {
  final double kelembapanTanah;
  final DateTime? waktu;

  TitikSensor({required this.kelembapanTanah, this.waktu});
}