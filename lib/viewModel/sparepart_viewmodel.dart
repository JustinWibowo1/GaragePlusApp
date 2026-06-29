import 'package:flutter/material.dart';
import '../models/sparepart_models.dart';
import '../services/sparepart_services.dart';

class SparepartViewModel extends ChangeNotifier {
  final SparepartServices _service = SparepartServices();

  List<Sparepart> daftarSparepart = [];
  List<Sparepart> daftarSparepartAsli = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> muatByKategori(
    String kategori, {
    String? tipeMesin,
    String? tipeTransmisi,
  }) async {
    _setLoading(true);
    try {
      daftarSparepart = await _service.fetchCocokUntukPekerjaan(
        kategori: kategori,
        tipeMesin: tipeMesin,
        tipeTransmisi: tipeTransmisi,
      );
      daftarSparepartAsli = daftarSparepart;
      errorMessage = null;
    } catch (e) {
      errorMessage = 'Gagal memuat sparepart: $e';
    }
    _setLoading(false);
  }

  /// Muat semua sparepart aktif
  Future<void> muatSemua() async {
    _setLoading(true);
    try {
      daftarSparepart = await _service.fetchSemua();
      daftarSparepartAsli = daftarSparepart;
      errorMessage = null;
    } catch (e) {
      errorMessage = 'Gagal memuat sparepart: $e';
    }
    _setLoading(false);
  }

  /// Cari di daftar yang sudah dimuat (client-side)
  void cariSparepart(String keyword) {
    if (keyword.isEmpty) {
      daftarSparepart = daftarSparepartAsli;
    } else {
      daftarSparepart = daftarSparepartAsli.where((sp) {
        final nama = sp.nama.toLowerCase();
        final merk = (sp.merk ?? '').toLowerCase();
        final spec = (sp.spesifikasi ?? '').toLowerCase();
        final kw = keyword.toLowerCase();
        return nama.contains(kw) || merk.contains(kw) || spec.contains(kw);
      }).toList();
    }
    notifyListeners();
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}
