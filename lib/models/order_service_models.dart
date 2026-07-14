class OrderServiceSummary {
  final int nomorWo;
  final String customerId;
  final int totalTagihan;
  final String status;
  final int kilometer;
  final String catatanKeluhan;
  final DateTime tanggalMasuk;
  final DateTime tanggalSelesai;
  final DateTime? completedAt;
  final DateTime? deletedAt;

  OrderServiceSummary({
    required this.nomorWo,
    required this.customerId,
    required this.totalTagihan,
    required this.status,
    required this.kilometer,
    required this.catatanKeluhan,
    required this.tanggalMasuk,
    required this.tanggalSelesai,
    this.completedAt,
    this.deletedAt,
  });

  /// Display-friendly WO number
  String get nomorWoDisplay =>
      'WO-${tanggalMasuk.year}-${nomorWo.toString().padLeft(4, '0')}';

  factory OrderServiceSummary.fromJson(Map<String, dynamic> json) {
    return OrderServiceSummary(
      nomorWo: json['nomor_wo'] as int,
      customerId: json['customer_id'] as String? ?? '',
      totalTagihan: json['total_tagihan'] as int? ?? 0,
      status: json['status'] as String? ?? 'Menunggu',
      kilometer: json['kilometer'] as int? ?? 0,
      catatanKeluhan: json['catatan_keluhan'] as String? ?? '',
      tanggalMasuk: DateTime.parse(json['created_at'] as String),
      tanggalSelesai: DateTime.parse(json['updated_at'] as String),
      // Tidak ada kolom completed_at di SQL → gunakan updated_at jika status Selesai
      completedAt: (json['status'] as String? ?? '') == 'Selesai'
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
    );
  }

  OrderServiceSummary copyWith({
    String? status,
    DateTime? completedAt,
    DateTime? tanggalSelesai,
  }) {
    return OrderServiceSummary(
      nomorWo        : nomorWo,
      customerId     : customerId,
      totalTagihan   : totalTagihan,
      status         : status ?? this.status,
      kilometer      : kilometer,
      catatanKeluhan : catatanKeluhan,
      tanggalMasuk   : tanggalMasuk,
      tanggalSelesai : tanggalSelesai ?? this.tanggalSelesai,
      completedAt    : completedAt ?? this.completedAt,
      deletedAt      : deletedAt,
    );
  }
}
