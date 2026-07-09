import 'package:flutter/material.dart';

enum StatusItem {
  menunggu,
  dikerjakan,
  selesai;

  String get label {
    switch (this) {
      case StatusItem.menunggu:   return 'Menunggu';
      case StatusItem.dikerjakan: return 'Dikerjakan';
      case StatusItem.selesai:    return 'Selesai';
    }
  }

  String get emoji {
    switch (this) {
      case StatusItem.menunggu:   return '🕐';
      case StatusItem.dikerjakan: return '🔧';
      case StatusItem.selesai:    return '✅';
    }
  }

  Color get warna {
    switch (this) {
      case StatusItem.menunggu:   return Colors.orange;
      case StatusItem.dikerjakan: return Colors.blue;
      case StatusItem.selesai:    return Colors.green;
    }
  }

  static StatusItem fromString(String value) {
    return StatusItem.values.firstWhere(
      (e) => e.label == value,
      orElse: () => StatusItem.menunggu,
    );
  }
}

class OrderServiceDetail {
  final String id;
  final int nomorWo;
  final String orderKerjaId;
  final int hargaFinal;
  final StatusItem status;
  final String? catatanTeknisi;
  final DateTime createdAt;
  final String? namaPekerjaan;

  OrderServiceDetail({
    required this.id,
    required this.nomorWo,
    required this.orderKerjaId,
    required this.hargaFinal,
    required this.status,
    this.catatanTeknisi,
    required this.createdAt,
    this.namaPekerjaan,
  });

  factory OrderServiceDetail.fromJson(Map<String, dynamic> json) {
    return OrderServiceDetail(
      id              : json['id'] as String,
      nomorWo         : json['nomor_wo'] as int,
      orderKerjaId    : json['order_kerja_id'] as String,
      hargaFinal      : json['harga_final'] as int? ?? 0,
      status          : StatusItem.fromString(json['status'] as String? ?? 'Menunggu'),
      catatanTeknisi  : json['catatan_teknisi'] as String?,
      createdAt       : DateTime.parse(json['created_at'] as String),
      namaPekerjaan   : json['order_kerja']?['nama'] as String?,
    );
  }

  OrderServiceDetail copyWith({StatusItem? status, String? catatanTeknisi}) {
    return OrderServiceDetail(
      id              : id,
      nomorWo         : nomorWo,
      orderKerjaId    : orderKerjaId,
      hargaFinal      : hargaFinal,
      status          : status ?? this.status,
      catatanTeknisi  : catatanTeknisi ?? this.catatanTeknisi,
      createdAt       : createdAt,
      namaPekerjaan   : namaPekerjaan,
    );
  }
}