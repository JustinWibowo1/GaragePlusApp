class OrderKerja {
  final String id;
  final String nama;
  final int estimasiHarga;
  final List<String> kompatibilitasMesin;
  final List<String> kompatibilitasTransmisi;
  final bool isActive;
  final String? kategoriSparepart;   // teks langsung, bukan FK
  final String? kategoriPerbaikan;   // PLM / MSN / REM / TRN / BDY / ELK / SUS
  final int? intervalKm;
  final int? intervalBulan;

  OrderKerja({
    required this.id,
    required this.nama,
    this.estimasiHarga = 0,
    required this.kompatibilitasMesin,
    required this.kompatibilitasTransmisi,
    this.isActive = true,
    this.kategoriSparepart,
    this.kategoriPerbaikan,
    this.intervalKm,
    this.intervalBulan,
  });

  /// Apakah pekerjaan ini membutuhkan pilihan sparepart dari katalog?
  bool get requiresSparepart => kategoriSparepart != null && kategoriSparepart!.isNotEmpty;

  factory OrderKerja.fromJson(Map<String, dynamic> json) {
    return OrderKerja(
      id                      : json['id'] as String,
      nama                    : json['nama'] as String,
      estimasiHarga           : json['estimasi_harga'] as int? ?? 0,
      kompatibilitasMesin     : List<String>.from(json['kompatibilitas_mesin'] ?? []),
      kompatibilitasTransmisi : List<String>.from(json['kompatibilitas_transmisi'] ?? []),
      isActive                : json['is_active'] as bool? ?? true,
      kategoriSparepart       : json['kategori_sparepart'] as String?,
      kategoriPerbaikan       : json['kategori_perbaikan'] as String?,
      intervalKm              : json['interval_km'] as int?,
      intervalBulan           : json['interval_bulan'] as int?,
    );
  }
}

class ServiceReminderItem {
  final String nama;
  final int?   intervalKm;
  final int?   intervalBulan;
  final int?   sisaKm;
  final int?   sisaHari;
  final DateTime? tanggalBerikutnya;

  const ServiceReminderItem({
    required this.nama,
    this.intervalKm,
    this.intervalBulan,
    this.sisaKm,
    this.sisaHari,
    this.tanggalBerikutnya,
  });

  factory ServiceReminderItem.fromJson(Map<String, dynamic> json) {
    return ServiceReminderItem(
      nama: json['nama_pekerjaan'] as String,
      intervalKm: json['interval_km'] as int?,
      intervalBulan: json['interval_bulan'] as int?,
      sisaKm: json['sisa_km'] as int?,
      sisaHari: json['sisa_hari'] as int?,
      tanggalBerikutnya: json['tanggal_berikutnya'] != null 
          ? DateTime.parse(json['tanggal_berikutnya'] as String) 
          : null,
    );
  }

  bool get isOverdue {
    final kmOver = sisaKm != null && sisaKm! <= 0;
    final hariOver = sisaHari != null && sisaHari! <= 0;
    return kmOver || hariOver;
  }
  
  bool get isUrgent {
    final kmUrgent = sisaKm != null && sisaKm! > 0 && sisaKm! <= 1500;
    final hariUrgent = sisaHari != null && sisaHari! > 0 && sisaHari! <= 30;
    return kmUrgent || hariUrgent;
  }
}
