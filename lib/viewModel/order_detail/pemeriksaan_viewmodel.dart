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
  Future<bool> prosesDanSimpanForm(int nomorWo, Map<String, String> formResult) async {
    final pemeriksaanBaru = PemeriksaanWO(
      id             : dataPemeriksaan?.id ?? '',
      nomorWo        : nomorWo,
      batteryAwal    : double.tryParse(formResult['batteryAwal']?.replaceAll(',', '.') ?? ''),
      batteryStater  : double.tryParse(formResult['batteryStater']?.replaceAll(',', '.') ?? ''),
      batteryPengisian: double.tryParse(formResult['batteryPengisian']?.replaceAll(',', '.') ?? ''),
      batteryStatus  : formResult['batteryStatus'],
      oliMesin       : formResult['oliMesin'],
      oliMatik       : formResult['oliMatik'],
      coolant        : formResult['coolant'],
      oliRemKopling  : formResult['oliRemKopling'],
      tekananDepan   : int.tryParse(formResult['tekananDepan'] ?? ''),
      tekananBelakang: int.tryParse(formResult['tekananBelakang'] ?? ''),
      tekananCadangan: int.tryParse(formResult['tekananCadangan'] ?? ''),
      torsiMur       : formResult['torsiMur'],
      serviceBerikutKm   : int.tryParse(formResult['serviceKm']?.replaceAll('.', '') ?? ''),
      serviceBerikutBulan: DateTime.tryParse(formResult['serviceBulan'] ?? ''),
      catatanTambahan: formResult['catatanTambahan'],
      namaMekanik    : formResult['namaMekanik'],
      namaForeman    : formResult['namaForeman'],
      createdAt      : dataPemeriksaan?.createdAt ?? DateTime.now(),
      updatedAt      : DateTime.now(),
    );
    return await simpanPemeriksaan(pemeriksaanBaru);
  }
}
