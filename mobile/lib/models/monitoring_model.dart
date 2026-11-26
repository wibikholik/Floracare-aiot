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

class TanamanZonaData {
  final int id;
  final String nama;
  final String? jenis;
  final String? kategori;

  TanamanZonaData({
    required this.id,
    required this.nama,
    this.jenis,
    this.kategori,
  });

  factory TanamanZonaData.fromJson(Map<String, dynamic> j) => TanamanZonaData(
        id: toIntValue(j['id']),
        nama: (j['nama'] ?? '').toString(),
        jenis: j['jenis']?.toString(),
        kategori: j['kategori']?.toString(),
      );
}

class SampelSensorData {
  final int? sampelSensorId;
  final int? nomor;
  final String nama;
  final double? kelembapanTanah;
  final double? phTanah;

  SampelSensorData({
    this.sampelSensorId,
    this.nomor,
    required this.nama,
    this.kelembapanTanah,
    this.phTanah,
  });

  factory SampelSensorData.fromJson(Map<String, dynamic> j) => SampelSensorData(
        sampelSensorId: j['sampel_sensor_id'] == null
            ? null
            : toIntValue(j['sampel_sensor_id']),
        nomor: j['nomor'] == null ? null : toIntValue(j['nomor']),
        nama: (j['nama'] ?? 'Sampel').toString(),
        kelembapanTanah: toDoubleOrNull(j['kelembapan_tanah']),
        phTanah: toDoubleOrNull(j['ph_tanah']),
      );
}

class PerintahAktif {
  final int id;
  final String sumber;
  final String status;
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
  final String status;
  final SensorData? sensor;
  final List<TanamanZonaData> tanaman;
  final int jumlahTanaman;
  final List<SampelSensorData> sampel;
  final bool otomatisAktif;
  final double? batasKelembapanMin;
  final double? batasKelembapanMaks;
  final int? durasiDetik;
  final int? jedaMenit;
  final PerintahAktif? perintahAktif;

  MonitoringZona({
    required this.zonaId,
    required this.namaZona,
    required this.status,
    this.sensor,
    this.tanaman = const [],
    this.jumlahTanaman = 0,
    this.sampel = const [],
    this.otomatisAktif = false,
    this.batasKelembapanMin,
    this.batasKelembapanMaks,
    this.durasiDetik,
    this.jedaMenit,
    this.perintahAktif,
  });

  factory MonitoringZona.fromJson(Map<String, dynamic> j) => MonitoringZona(
        zonaId: toIntValue(j['zona_id']),
        namaZona: (j['nama_zona'] ?? '').toString(),
        status: (j['status'] ?? 'offline').toString(),
        sensor: j['sensor'] is Map<String, dynamic>
            ? SensorData.fromJson(j['sensor'])
            : null,
        tanaman: (j['tanaman'] as List? ?? [])
            .map((e) => TanamanZonaData.fromJson(e as Map<String, dynamic>))
            .toList(),
        jumlahTanaman: toIntValue(j['jumlah_tanaman']),
        sampel: (j['sampel'] as List? ?? [])
            .map((e) => SampelSensorData.fromJson(e as Map<String, dynamic>))
            .toList(),
        otomatisAktif: toBoolValue(j['otomatis_aktif']),
        batasKelembapanMin: toDoubleOrNull(j['batas_kelembapan_min']),
        batasKelembapanMaks: toDoubleOrNull(j['batas_kelembapan_maks']),
        durasiDetik: j['durasi_detik'] == null ? null : toIntValue(j['durasi_detik']),
        jedaMenit: j['jeda_menit'] == null ? null : toIntValue(j['jeda_menit']),
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
