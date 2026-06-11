// lib/viewModel/dashboard_viewmodel.dart

import 'package:flutter/material.dart';
import '../models/service_logistic_models.dart';
import '../services/dashboard_services.dart';   // ← import service

class DashboardViewModel extends ChangeNotifier {
  final DashboardService _service = DashboardService();  // ← pakai service

  List<ServiceLogisticsItem> serviceLogistics = [];
  bool isLoading   = false;
  String? errorMessage;

  Future<void> muatServiceLogistics() async {
    isLoading    = true;
    errorMessage = null;
    notifyListeners();

    try {
      // ✅ Cukup 1 baris — logika ada di service
      serviceLogistics = await _service.fetchServiceLogistics();
      print('✅ Service Logistics: ${serviceLogistics.length} item');

    } catch (e) {
      errorMessage = 'Gagal memuat Service Logistics: $e';
      print('❌ $errorMessage');
    }

    isLoading = false;
    notifyListeners();
  }
}