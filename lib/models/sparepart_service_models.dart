class SparepartService {
  final String id;
  final String orderServiceDetailId;
  final String? sparepartId;
  final String namaItemSnapshot;
  final String? spesifikasiSnapshot;
  final int hargaSatuan;
  final int qty;
  final int subtotal;
  final DateTime createdAt;

  SparepartService({
    required this.id,
    required this.orderServiceDetailId,
    this.sparepartId,
    required this.namaItemSnapshot,
    this.spesifikasiSnapshot,
    this.hargaSatuan = 0,
    this.qty = 1,
    this.subtotal = 0,
    required this.createdAt,
  });

  factory SparepartService.fromJson(Map<String, dynamic> json) {
    return SparepartService(
      id                    : json['id'] as String,
      orderServiceDetailId  : json['order_service_detail_id'] as String,
      sparepartId           : json['sparepart_id'] as String?,
      namaItemSnapshot      : json['nama_item_snapshot'] as String,
      spesifikasiSnapshot   : json['spesifikasi_snapshot'] as String?,
      hargaSatuan           : json['harga_satuan'] as int? ?? 0,
      qty                   : json['qty'] as int? ?? 1,
      subtotal              : json['subtotal'] as int? ?? 0,
      createdAt             : DateTime.parse(json['created_at'] as String),
    );
  }
}