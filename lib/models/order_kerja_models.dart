class OrderKerja {
  final String id;
  final String kode;
  final String nama;
  final int estimasiHarga;
  final List<String> kompatibilitasMesin;
  final List<String> kompatibilitasTransmisi;
  final bool isActive;
  final String? kategoriSparepart;   // teks langsung, bukan FK
  final String? kategoriPerbaikan;   // PLM / MSN / REM / TRN / BDY / ELK / SUS
  final int? intervalKm;

  OrderKerja({
    required this.id,
    required this.kode,
    required this.nama,
    this.estimasiHarga = 0,
    required this.kompatibilitasMesin,
    required this.kompatibilitasTransmisi,
    this.isActive = true,
    this.kategoriSparepart,
    this.kategoriPerbaikan,
    this.intervalKm,
  });

  /// Apakah pekerjaan ini membutuhkan pilihan sparepart dari katalog?
  bool get requiresSparepart => kategoriSparepart != null && kategoriSparepart!.isNotEmpty;

  factory OrderKerja.fromJson(Map<String, dynamic> json) {
    return OrderKerja(
      id                      : json['id'] as String,
      kode                    : json['kode'] as String? ?? '',
      nama                    : json['nama'] as String,
      estimasiHarga           : json['estimasi_harga'] as int? ?? 0,
      kompatibilitasMesin     : List<String>.from(json['kompatibilitas_mesin'] ?? []),
      kompatibilitasTransmisi : List<String>.from(json['kompatibilitas_transmisi'] ?? []),
      isActive                : json['is_active'] as bool? ?? true,
      kategoriSparepart       : json['kategori_sparepart'] as String?,
      kategoriPerbaikan       : json['kategori_perbaikan'] as String?,
      intervalKm              : json['interval_km'] as int?,
    );
  }
}

class ServiceReminderItem {
  final String nama;
  final int    intervalKm;
  final int    kmTerakhir;
  final int    kmBerikutnya;

  const ServiceReminderItem({
    required this.nama,
    required this.intervalKm,
    required this.kmTerakhir,
    required this.kmBerikutnya,
  });

  int get sisaKm    => kmBerikutnya - kmTerakhir;
  bool get isOverdue => sisaKm <= 0;
  bool get isUrgent  => sisaKm > 0 && sisaKm <= 1500;
}
