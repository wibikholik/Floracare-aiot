class Tanaman {
  final int id;
  final String nama;
  final String jenis;
  final String lokasi;
  final String status;
  final String catatan;

  Tanaman({
    required this.id,
    required this.nama,
    this.jenis = '',
    this.lokasi = '',
    this.status = 'sehat',
    this.catatan = '',
  });

  factory Tanaman.fromJson(Map<String, dynamic> json) {
    return Tanaman(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      nama: (json['nama'] ?? '').toString(),
      jenis: (json['jenis'] ?? '').toString(),
      lokasi: (json['lokasi'] ?? '').toString(),
      status: (json['status'] ?? 'sehat').toString(),
      catatan: (json['catatan'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'jenis': jenis.isEmpty ? null : jenis,
      'lokasi': lokasi.isEmpty ? null : lokasi,
      'status': status,
      'catatan': catatan.isEmpty ? null : catatan,
    };
  }
}