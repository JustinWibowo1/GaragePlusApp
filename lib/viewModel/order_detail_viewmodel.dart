import 'package:flutter/material.dart';
import 'dart:math';
import '../models/order_service_models.dart';
import '../models/service_details_models.dart';
import '../models/order_kerja_models.dart';
import '../services/order_kerja_services.dart';
import '../services/customer_services.dart';
import '../services/service_details_services.dart';
import '../services/order_service_services.dart';

class OrderDetailViewModel extends ChangeNotifier {
  final _orderKerjaService = OrderKerjaServices();
  final _customerService = CarService();
  final _orderServiceDetailService = OrderServiceDetailServices();
  final _orderServiceService = OrderServiceServices();

  List<OrderServiceSummary> daftarOrder = [];
  List<OrderServiceDetail> daftarDetail = [];
  List<ServiceReminderItem> _serviceReminders = [];
  
  bool isLoading = false;
  String? errorMessage;

  int get totalItem => daftarDetail.length;
  int get itemSelesai =>
      daftarDetail.where((d) => d.status == StatusItem.selesai).length;
  double get progress => totalItem == 0 ? 0 : itemSelesai / totalItem;
  int _kmTerakhir = 0;
  int get kmTerakhir => _kmTerakhir;

  List<ServiceReminderItem> get serviceReminders {
    if (_serviceReminders.isEmpty) return [];
    
    // Sort so overdue/urgent ones are on top
    final result = List<ServiceReminderItem>.from(_serviceReminders);
    result.sort((a, b) {
      if (a.isOverdue && !b.isOverdue) return -1;
      if (!a.isOverdue && b.isOverdue) return 1;
      
      final aVal = a.sisaHari != null && a.sisaHari! < (a.sisaKm ?? 999999) ? a.sisaHari! : (a.sisaKm ?? 999999);
      final bVal = b.sisaHari != null && b.sisaHari! < (b.sisaKm ?? 999999) ? b.sisaHari! : (b.sisaKm ?? 999999);
      
      return aVal.compareTo(bVal);
    });
    return result;
  }

  Future<void> _muatServiceReminders(String customerId) async {
    try {
      _serviceReminders = await _orderKerjaService.fetchServiceReminders(customerId);
    } catch (e) {
      _serviceReminders = [];
    }
  }

  Future<void> muatOrderByCustomer(
    String customerId, {
    String tipeMesin = '',
    String tipeTransmisi = '',
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _orderServiceService.fetchOrderByCustomer(customerId),
        _muatServiceReminders(customerId),
        _customerService.fetchOdometer(customerId),
      ]);

      final kmDariCustomer = results[2] as int;
      daftarOrder = results[0] as List<OrderServiceSummary>;

      final kmDariOrder = daftarOrder.isEmpty
          ? 0
          : daftarOrder.map((o) => o.kilometer).reduce(max);
      _kmTerakhir = max(kmDariCustomer, kmDariOrder);
    } catch (e) {
      errorMessage = 'Gagal memuat data: $e';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> _cekDanUpdateStatusOrder() async {
    if (daftarDetail.isEmpty) return;

    final semuaSelesai =
        daftarDetail.every((d) => d.status == StatusItem.selesai);
    final semuaMenunggu =
        daftarDetail.every((d) => d.status == StatusItem.menunggu);

    final String statusBaru;
    if (semuaMenunggu) {
      statusBaru = 'Menunggu';
    } else {
      statusBaru = 'Dikerjakan';
    }

    final nomorWo = daftarDetail.first.nomorWo;
    final orderIndex = daftarOrder.indexWhere((o) => o.nomorWo == nomorWo);
    final statusSekarang =
        orderIndex != -1 ? daftarOrder[orderIndex].status : null;

    if (statusSekarang == 'Selesai') return;

    if (statusSekarang != statusBaru) {
      await _orderServiceService.updateStatus(nomorWo, statusBaru);

      if (orderIndex != -1) {
        daftarOrder[orderIndex] =
            daftarOrder[orderIndex].copyWith(status: statusBaru);
      }
    }

    if (semuaSelesai &&
        orderIndex != -1 &&
        daftarOrder[orderIndex].status != 'Selesai') {
    }
  }

  Future<void> muatDetail(int nomorWo) async {
    isLoading = true;
    notifyListeners();
    try {
      daftarDetail =
          await _orderServiceDetailService.fetchDetailByNomorWo(nomorWo);
    } catch (e) {
      errorMessage = 'Gagal memuat detail: $e';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> ubahStatusItem({
    required int nomorWo,
    required String detailId,
    required StatusItem statusBaru,
    String? catatan,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final success = await _orderServiceDetailService.updateStatusItem(
        detailId: detailId,
        statusBaru: statusBaru,
        catatanTeknisi: catatan,
      );
      if (!success) {
        throw Exception('Gagal menyimpan perubahan ke server.');
      }
      await _cekDanUpdateStatusOrder();
      await muatDetail(nomorWo);
      return; 
    } catch (e) {
      errorMessage = 'Gagal memperbarui status: $e';
    }
    
    isLoading = false;
    notifyListeners();
  }

  Future<bool> tambahPekerjaanBaru({
    required int nomorWo,
    required String orderKerjaId,
    required String namaPekerjaan,
    required int hargaFinal,
  }) async {
    try {
      final item = await _orderServiceDetailService.insertDetailItem(
        nomorWo      : nomorWo,
        orderKerjaId : orderKerjaId,
        hargaFinal   : hargaFinal,
      );
      if (item == null) throw Exception('Insert gagal');
      
      // Reassign list agar UI Flutter mendeteksi perubahan state
      daftarDetail = List.from(daftarDetail)..add(item);
      final orderIndex = daftarOrder.indexWhere((o) => o.nomorWo == nomorWo);
      if (orderIndex != -1) {
        final orderLama = daftarOrder[orderIndex];
        daftarOrder[orderIndex] = OrderServiceSummary(
          nomorWo        : orderLama.nomorWo,
          customerId     : orderLama.customerId,
          totalTagihan   : orderLama.totalTagihan + hargaFinal,
          status         : orderLama.status,
          kilometer      : orderLama.kilometer,
          catatanKeluhan : orderLama.catatanKeluhan,
          createdAt      : orderLama.createdAt,
          updatedAt      : DateTime.now(),
          completedAt    : orderLama.completedAt,
          deletedAt      : orderLama.deletedAt,
        );

        await _orderServiceService.updateTotalTagihan(
          nomorWo,
          orderLama.totalTagihan + hargaFinal,
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Gagal menambah pekerjaan: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> ubahHargaPekerjaan(int nomorWo, String detailId, int hargaLama, int hargaBaru) async {
    try {
      final success = await _orderServiceDetailService.updateHargaFinal(
        detailId: detailId,
        hargaBaru: hargaBaru,
      );
      if (!success) throw Exception('Update gagal');

      // Update local state
      final detailIndex = daftarDetail.indexWhere((d) => d.id == detailId);
      if (detailIndex != -1) {
        daftarDetail[detailIndex] = OrderServiceDetail(
          id: daftarDetail[detailIndex].id,
          nomorWo: daftarDetail[detailIndex].nomorWo,
          orderKerjaId: daftarDetail[detailIndex].orderKerjaId,
          hargaFinal: hargaBaru,
          status: daftarDetail[detailIndex].status,
          catatanTeknisi: daftarDetail[detailIndex].catatanTeknisi,
          createdAt: daftarDetail[detailIndex].createdAt,
          namaPekerjaan: daftarDetail[detailIndex].namaPekerjaan,
        );
      }

      // Update WO total tagihan
      final orderIndex = daftarOrder.indexWhere((o) => o.nomorWo == nomorWo);
      if (orderIndex != -1) {
        final orderLama = daftarOrder[orderIndex];
        final selisih = hargaBaru - hargaLama;
        final totalBaru = orderLama.totalTagihan + selisih;
        
        daftarOrder[orderIndex] = orderLama.copyWith(
          updatedAt: DateTime.now(),
        );
        // Kita tidak bisa copyWith totalTagihan karena tidak ada parameter totalTagihan di copyWith OrderServiceSummary.
        // Kita assign ulang saja:
        daftarOrder[orderIndex] = OrderServiceSummary(
          nomorWo        : orderLama.nomorWo,
          customerId     : orderLama.customerId,
          totalTagihan   : totalBaru,
          status         : orderLama.status,
          kilometer      : orderLama.kilometer,
          catatanKeluhan : orderLama.catatanKeluhan,
          createdAt      : orderLama.createdAt,
          updatedAt      : DateTime.now(),
          completedAt    : orderLama.completedAt,
          deletedAt      : orderLama.deletedAt,
        );

        await _orderServiceService.updateTotalTagihan(nomorWo, totalBaru);
      }

      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Gagal mengubah harga: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> hapusPekerjaan(int nomorWo, String detailId, int hargaFinal) async {
    try {
      final success = await _orderServiceDetailService.hapusDetailItem(detailId);
      if (!success) throw Exception('Hapus gagal');

      // Update local state by reassigning list
      final newList = List<OrderServiceDetail>.from(daftarDetail);
      newList.removeWhere((d) => d.id == detailId);
      daftarDetail = newList;

      // Update WO total tagihan
      final orderIndex = daftarOrder.indexWhere((o) => o.nomorWo == nomorWo);
      if (orderIndex != -1) {
        final orderLama = daftarOrder[orderIndex];
        final totalBaru = orderLama.totalTagihan - hargaFinal;

        daftarOrder[orderIndex] = OrderServiceSummary(
          nomorWo        : orderLama.nomorWo,
          customerId     : orderLama.customerId,
          totalTagihan   : totalBaru,
          status         : orderLama.status,
          kilometer      : orderLama.kilometer,
          catatanKeluhan : orderLama.catatanKeluhan,
          createdAt      : orderLama.createdAt,
          updatedAt      : DateTime.now(),
          completedAt    : orderLama.completedAt,
          deletedAt      : orderLama.deletedAt,
        );

        await _orderServiceService.updateTotalTagihan(nomorWo, totalBaru);
      }

      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Gagal menghapus pekerjaan: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> finalisasiOrder(int nomorWo, {DateTime? completedAt}) async {
    final selesaiPada = completedAt ?? DateTime.now();
    try {
      final success = await _orderServiceService.updateStatusSelesai(
        nomorWo,
        completedAt: selesaiPada,
      );
      if (!success) throw Exception('Gagal update database');

      // Update local state agar UI langsung ter-refresh jadi Read-Only
      final index = daftarOrder.indexWhere((o) => o.nomorWo == nomorWo);
      if (index != -1) {
        daftarOrder[index] = daftarOrder[index].copyWith(
          status: 'Selesai',
          completedAt: selesaiPada,
          updatedAt: selesaiPada,
        );
      }
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  int hitungSisaKilometer(int odometerInputUser) {
    return kmTerakhir - odometerInputUser;
  }

  String getPesanReminder(int odometerInputUser) {
    if (kmTerakhir == 0) return 'Target odometer belum diatur';

    final sisa = hitungSisaKilometer(odometerInputUser);
    if (sisa < 0) {
      return 'OVERDUE: Terlewat ${sisa.abs()} km dari jadwal service';
    } else if (sisa <= 1500) {
      return 'SEGERA: Sisa $sisa km menuju service';
    } else {
      return 'Aman: Sisa $sisa km menuju service';
    }
  }
}
