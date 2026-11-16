class Kategori {
  final int id;
  final String nama;
  final String deskripsi;
  final int tanamanCount;

  Kategori({
    required this.id,
    required this.nama,
    this.deskripsi = '',
    this.tanamanCount = 0,
  });

  factory Kategori.fromJson(Map<String, dynamic> json) {
    return Kategori(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      nama: (json['nama_kategori'] ?? json['nama'] ?? json['name'] ?? '')
          .toString(),
      deskripsi: (json['deskripsi'] ?? json['keterangan'] ?? '').toString(),
      tanamanCount: json['tanaman_count'] is int
          ? json['tanaman_count']
          : int.tryParse(json['tanaman_count']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama_kategori': nama,
      'nama': nama,
      'deskripsi': deskripsi.isEmpty ? null : deskripsi,
      'keterangan': deskripsi.isEmpty ? null : deskripsi,
    };
  }
}