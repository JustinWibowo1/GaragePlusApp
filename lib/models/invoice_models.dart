class InvoiceItem {
  final String id;
  final int nomorWo;
  final String namaPekerjaan;
  final int harga;
  final DateTime createdAt;

  InvoiceItem({
    required this.id,
    required this.nomorWo,
    required this.namaPekerjaan,
    required this.harga,
    required this.createdAt,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      id: json['id'] as String,
      nomorWo: json['nomor_wo'] as int,
      namaPekerjaan: json['nama_pekerjaan'] as String,
      harga: json['harga'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nomor_wo': nomorWo,
      'nama_pekerjaan': namaPekerjaan,
      'harga': harga,
    };
  }
}
