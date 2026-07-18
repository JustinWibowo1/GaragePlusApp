import 'package:flutter/material.dart';
import 'dart:math';
import '../../models/order_kerja_models.dart';
import '../../services/order_kerja_services.dart';
import '../../services/customer_services.dart';

class ServiceReminderViewModel extends ChangeNotifier {
  final _orderKerjaService = OrderKerjaServices();
  final _customerService = CarService();

  List<ServiceReminderItem> _serviceReminders = [];
  int _kmTerakhir = 0;
  
  int get kmTerakhir => _kmTerakhir;
  bool isLoading = false;
  String? errorMessage;

  List<ServiceReminderItem> get serviceReminders {
    if (_serviceReminders.isEmpty) return [];

    final result = List<ServiceReminderItem>.from(_serviceReminders);
    result.sort((a, b) {
      if (a.isOverdue && !b.isOverdue) return -1;
      if (!a.isOverdue && b.isOverdue) return 1;

      final aVal = a.sisaHari != null && a.sisaHari! < (a.sisaKm ?? 999999)
          ? a.sisaHari!
          : (a.sisaKm ?? 999999);
      final bVal = b.sisaHari != null && b.sisaHari! < (b.sisaKm ?? 999999)
          ? b.sisaHari!
          : (b.sisaKm ?? 999999);

      return aVal.compareTo(bVal);
    });
    return result;
  }

  Future<void> muatRemindersDanKm(String customerId, int kmDariOrder) async {
    isLoading = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        _orderKerjaService.fetchServiceReminders(customerId),
        _customerService.fetchOdometer(customerId),
      ]);
      
      _serviceReminders = results[0] as List<ServiceReminderItem>;
      final kmDariCustomer = results[1] as int;
      
      _kmTerakhir = max(kmDariCustomer, kmDariOrder);
      
    } catch (e) {
      _serviceReminders = [];
      errorMessage = 'Gagal memuat reminder: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  int hitungSisaKilometer(int odometerInputUser) {
    return _kmTerakhir - odometerInputUser;
  }

  String getPesanReminder(int odometerInputUser) {
    if (_kmTerakhir == 0) return 'Target odometer belum diatur';

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
