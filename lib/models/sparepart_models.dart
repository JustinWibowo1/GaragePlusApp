class Sparepart {
  final String id;
  final String nama;
  final String? merk;
  final String kategori;          // kolom teks langsung, bukan FK
  final String? spesifikasi;
  final List<String> kompatibilitasMesin;
  final List<String> kompatibilitasTransmisi;
  final int hargaJual;
  final bool isActive;

  Sparepart({
    required this.id,
    required this.nama,
    this.merk,
    required this.kategori,
    this.spesifikasi,
    this.kompatibilitasMesin = const [],
    this.kompatibilitasTransmisi = const [],
    this.hargaJual = 0,
    this.isActive = true,
  });

  /// Label untuk ditampilkan di UI
  String get displayName {
    final parts = [nama, if (merk != null && merk!.isNotEmpty) merk];
    return parts.join(' ');
  }

  /// Label lengkap termasuk spesifikasi
  String get displayNameWithSpec {
    final parts = [
      nama,
      if (merk != null && merk!.isNotEmpty) merk,
      if (spesifikasi != null && spesifikasi!.isNotEmpty) '(${spesifikasi!})',
    ];
    return parts.join(' ');
  }

  factory Sparepart.fromJson(Map<String, dynamic> json) {
    return Sparepart(
      id                      : json['id'] as String,
      nama                    : json['nama'] as String,
      merk                    : json['merk'] as String?,
      kategori                : json['kategori'] as String? ?? '',
      spesifikasi             : json['spesifikasi'] as String?,
      kompatibilitasMesin     : List<String>.from(json['kompatibilitas_mesin'] ?? []),
      kompatibilitasTransmisi : List<String>.from(json['kompatibilitas_transmisi'] ?? []),
      hargaJual               : json['harga_jual'] as int? ?? 0,
      isActive                : json['is_active'] as bool? ?? true,
    );
  }
}
