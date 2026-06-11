class KategoriSparepart {
  final String id;
  final String nama;
  final String unit;

  KategoriSparepart({
    required this.id,
    required this.nama,
    required this.unit,
  });

  factory KategoriSparepart.fromJson(Map<String, dynamic> json) {
    return KategoriSparepart(
      id   : json['id'] as String,
      nama : json['nama'] as String,
      unit : json['unit'] as String? ?? 'Pcs',
    );
  }
}
