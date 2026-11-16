class Zona {
  final int id;
  final String nama;
  final String deskripsi;
  final int tanamanCount;

  Zona({
    required this.id,
    required this.nama,
    this.deskripsi = '',
    this.tanamanCount = 0,
  });

  factory Zona.fromJson(Map<String, dynamic> json) {
    return Zona(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      nama: (json['nama_zona'] ??
              json['nama'] ??
              json['name'] ??
              json['kode_zona'] ??
              json['kode'] ??
              '')
          .toString(),
      deskripsi: (json['deskripsi'] ?? json['keterangan'] ?? '').toString(),
      tanamanCount: json['tanaman_count'] is int
          ? json['tanaman_count']
          : int.tryParse(json['tanaman_count']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama_zona': nama,
      'nama': nama,
      'deskripsi': deskripsi.isEmpty ? null : deskripsi,
      'keterangan': deskripsi.isEmpty ? null : deskripsi,
    };
  }
}