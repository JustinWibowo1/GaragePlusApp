import 'package:flutter/material.dart';
import '../models/service_logistic_models.dart';
import '../services/dashboard_services.dart';

class DashboardViewModel extends ChangeNotifier {
  final DashboardService _service = DashboardService();

  List<ServiceLogisticsItem> serviceLogistics = [];
  bool isLoading    = false;
  String? errorMessage;

  bool _isDisposed = false;

  /// Override dispose untuk set flag agar async yang masih berjalan
  /// tidak memanggil notifyListeners() setelah widget di-dispose.
  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _safeNotify() {
    if (!_isDisposed) notifyListeners();
  }

  Future<void> muatServiceLogistics() async {
    isLoading    = true;
    errorMessage = null;
    _safeNotify();

    try {
      serviceLogistics = await _service.fetchServiceLogistics();
    } catch (e) {
      errorMessage = 'Gagal memuat Service Logistics: $e';
    }

    isLoading = false;
    _safeNotify();
  }
}