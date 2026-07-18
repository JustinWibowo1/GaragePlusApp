import 'package:flutter/material.dart';
import '../../models/pemeriksaan_wo_models.dart';
import '../../services/pemeriksaan_wo_service.dart';

class PemeriksaanViewModel extends ChangeNotifier {
  final _pemeriksaanService = PemeriksaanWOService();

  PemeriksaanWO? dataPemeriksaan;
  bool isLoadingPemeriksaan = false;
  String? errorMessage;

  Future<void> muatPemeriksaan(int nomorWo) async {
    isLoadingPemeriksaan = true;
    notifyListeners();
    try {
      dataPemeriksaan = await _pemeriksaanService.fetchByNomorWo(nomorWo);
    } catch (e) {
      errorMessage = 'Gagal memuat pemeriksaan: $e';
    } finally {
      isLoadingPemeriksaan = false;
      notifyListeners();
    }
  }

  Future<bool> simpanPemeriksaan(PemeriksaanWO data) async {
    isLoadingPemeriksaan = true;
    notifyListeners();
    try {
      final result = await _pemeriksaanService.upsert(data);
      if (result == null) throw Exception('Upsert gagal');
      dataPemeriksaan = result;
      return true;
    } catch (e) {
      errorMessage = 'Gagal menyimpan pemeriksaan: $e';
      return false;
    } finally {
      isLoadingPemeriksaan = false;
      notifyListeners();
    }
  }
}
