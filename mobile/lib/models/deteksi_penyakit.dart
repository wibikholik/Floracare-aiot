class DeteksiPenyakit {
  final int id;
  final int? tanamanId; // null = foto bebas (bukan tanaman terdaftar)
  final String? namaTanamanTerdeteksi;
  final String fotoUrl;
  final String hasilKlasifikasi;
  final String? jenisMasalah;
  final double tingkatKeyakinan;
  final String statusKondisi; // sehat | terindikasi_hama | sakit | tidak_yakin
  final String? saranPenanganan;
  bool sudahDitangani;
  final String? catatan;
  final String? provider;
  final DateTime? createdAt;

  DeteksiPenyakit({
    required this.id,
    this.tanamanId,
    this.namaTanamanTerdeteksi,
    required this.fotoUrl,
    required this.hasilKlasifikasi,
    this.jenisMasalah,
    required this.tingkatKeyakinan,
    required this.statusKondisi,
    this.saranPenanganan,
    required this.sudahDitangani,
    this.catatan,
    this.provider,
    this.createdAt,
  });

  factory DeteksiPenyakit.fromJson(Map<String, dynamic> j) => DeteksiPenyakit(
        id: j['id'],
        tanamanId: j['tanaman_id'],
        namaTanamanTerdeteksi: j['nama_tanaman_terdeteksi'],
        fotoUrl: j['foto_url'] ?? '',
        hasilKlasifikasi: j['hasil_klasifikasi'] ?? '',
        jenisMasalah: j['jenis_masalah'],
        tingkatKeyakinan: (j['tingkat_keyakinan'] as num?)?.toDouble() ?? 0,
        statusKondisi: j['status_kondisi'] ?? 'tidak_yakin',
        saranPenanganan: j['saran_penanganan'],
        sudahDitangani:
            j['sudah_ditangani'] == true || j['sudah_ditangani'] == 1,
        catatan: j['catatan'],
        provider: j['provider'],
        createdAt:
            j['created_at'] != null ? DateTime.tryParse(j['created_at']) : null,
      );
}