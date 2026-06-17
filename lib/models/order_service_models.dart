class OrderServiceSummary {
  final int nomorWo;
  final String customerId;
  final int totalTagihan;
  final String status;
  final int kilometer;
  final String catatanKeluhan;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final DateTime? deletedAt;

  OrderServiceSummary({
    required this.nomorWo,
    required this.customerId,
    required this.totalTagihan,
    required this.status,
    required this.kilometer,
    required this.catatanKeluhan,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
    this.deletedAt,
  });

  /// Display-friendly WO number
  String get nomorWoDisplay => 'WO-${createdAt.year}-${nomorWo.toString().padLeft(4, '0')}';

  factory OrderServiceSummary.fromJson(Map<String, dynamic> json) {
    return OrderServiceSummary(
      nomorWo        : json['nomor_wo'] as int,
      customerId     : json['customer_id'] as String? ?? '',
      totalTagihan   : json['total_tagihan'] as int? ?? 0,
      status         : json['status'] as String? ?? 'Menunggu',
      kilometer      : json['odometer_terakhir'] as int? ?? 0,
      catatanKeluhan : json['catatan_keluhan'] as String? ?? '',
      createdAt      : DateTime.parse(json['created_at'] as String),
      updatedAt      : DateTime.parse(json['updated_at'] as String),
      completedAt    : json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      deletedAt      : json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
    );
  }

  OrderServiceSummary copyWith({String? status, DateTime? completedAt}) {
    return OrderServiceSummary(
      nomorWo        : nomorWo,
      customerId     : customerId,
      totalTagihan   : totalTagihan,
      status         : status ?? this.status,
      kilometer      : kilometer,
      catatanKeluhan : catatanKeluhan,
      createdAt      : createdAt,
      updatedAt      : updatedAt,
      completedAt    : completedAt ?? this.completedAt,
      deletedAt      : deletedAt,
    );
  }
}