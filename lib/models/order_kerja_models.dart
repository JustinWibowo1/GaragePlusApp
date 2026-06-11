class OrderKerja {
  final String id;
  final String kode;
  final String nama;
  final int estimasiHarga;
  final List<String> kompatibilitasMesin;
  final List<String> kompatibilitasTransmisi;
  final bool isActive;
  final List<KategoriSparepartRef> kategoriSparepart;
  final int? intervalKm; 

  OrderKerja({
    required this.id,
    required this.kode,
    required this.nama,
    this.estimasiHarga = 0,
    required this.kompatibilitasMesin,
    required this.kompatibilitasTransmisi,
    this.isActive = true,
    this.kategoriSparepart = const [],
    this.intervalKm,
  });

  /// Apakah pekerjaan ini membutuhkan sparepart?
  bool get requiresSparepart => kategoriSparepart.isNotEmpty;

  factory OrderKerja.fromJson(Map<String, dynamic> json) {
    // Parse kategori sparepart dari nested join
    final rawKategori = json['order_kerja_kategori_sparepart'] as List<dynamic>? ?? [];
    final kategoriList = rawKategori
        .map((item) => KategoriSparepartRef.fromJson(item as Map<String, dynamic>))
        .toList();

    return OrderKerja(
      id                        : json['id'] as String,
      kode                      : json['kode'] as String? ?? '',
      nama                      : json['nama'] as String,
      estimasiHarga             : json['estimasi_harga'] as int? ?? 0,
      kompatibilitasMesin       : List<String>.from(json['kompatibilitas_mesin'] ?? []),
      kompatibilitasTransmisi   : List<String>.from(json['kompatibilitas_transmisi'] ?? []),
      isActive                  : json['is_active'] as bool? ?? true,
      kategoriSparepart         : kategoriList,
      intervalKm                : json['interval_km'] as int?,
    );
  }
}

/// Referensi kategori sparepart yang dibutuhkan oleh pekerjaan
class KategoriSparepartRef {
  final String kategoriId;
  final String kategoriNama;
  final String kategoriUnit;
  final bool isRequired;

  KategoriSparepartRef({
    required this.kategoriId,
    required this.kategoriNama,
    required this.kategoriUnit,
    this.isRequired = false,
  });

  factory KategoriSparepartRef.fromJson(Map<String, dynamic> json) {
    final ks = json['kategori_sparepart'] as Map<String, dynamic>? ?? {};
    return KategoriSparepartRef(
      kategoriId    : ks['id'] as String? ?? '',
      kategoriNama  : ks['nama'] as String? ?? '',
      kategoriUnit  : ks['unit'] as String? ?? 'Pcs',
      isRequired    : json['is_required'] as bool? ?? false,
    );
  }
}

class ServiceReminderItem {
  final String nama;
  final int    intervalKm;
  final int    kmTerakhir;    // km kunjungan terakhir
  final int    kmBerikutnya;  // kapan jatuh tempo

  const ServiceReminderItem({
    required this.nama,
    required this.intervalKm,
    required this.kmTerakhir,
    required this.kmBerikutnya,
  });

  /// km yang harus ditempuh hingga service (negatif = sudah lewat)
  int get sisaKm => kmBerikutnya - kmTerakhir;

  /// Sudah lewat jadwal
  bool get isOverdue => sisaKm <= 0;

  /// Segera (dalam 1.500 km)
  bool get isUrgent => sisaKm > 0 && sisaKm <= 1500;
}
