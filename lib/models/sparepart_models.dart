class Sparepart {
  final String id;
  final String kategoriId;
  final String? kode;
  final String nama;
  final String? merk;
  final int hargaJual;
  final int stok;
  final bool isActive;
  // Join field
  final String? kategoriNama;

  Sparepart({
    required this.id,
    required this.kategoriId,
    this.kode,
    required this.nama,
    this.merk,
    this.hargaJual = 0,
    this.stok = 0,
    this.isActive = true,
    this.kategoriNama,
  });

  /// Label untuk ditampilkan di UI
  String get displayName => merk != null ? '$nama ($merk)' : nama;

  factory Sparepart.fromJson(Map<String, dynamic> json) {
    return Sparepart(
      id            : json['id'] as String,
      kategoriId    : json['kategori_id'] as String,
      kode          : json['kode'] as String?,
      nama          : json['nama'] as String,
      merk          : json['merk'] as String?,
      hargaJual     : json['harga_jual'] as int? ?? 0,
      stok          : json['stok'] as int? ?? 0,
      isActive      : json['is_active'] as bool? ?? true,
      kategoriNama  : json['kategori_sparepart']?['nama'] as String?,
    );
  }
}
