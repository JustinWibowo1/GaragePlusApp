import 'package:flutter/material.dart';
import '../models/customer_models.dart';
import '../services/customer_services.dart';

class CarViewModel extends ChangeNotifier {
  final CarService _carService = CarService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<Customer> _cars = [];
  List<Customer> get cars => _cars;

  static const List<String> mesinOpts     = ['Bensin', 'Diesel', 'Hybrid'];
  static const List<String> transmisiOpts = ['Manual', 'Matic', 'CVT'];
  static const List<String> sapaanOpts    = ['Bapak', 'Ibu'];

  Future<bool> submitAddCar(Map<String, dynamic> data) async {
    final rangka = (data['nomor_rangka'] as String? ?? '').trim();
    if (rangka.isEmpty) {
      _errorMessage = 'Nomor Rangka wajib diisi';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final exists = await _carService.isCarExists(rangka);
      if (exists) {
        _errorMessage = 'Mobil dengan nomor rangka ini sudah ada';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      await _carService.saveCar(data);
      await getAllCars(); // refresh daftar
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Edit data kendaraan yang sudah ada.
  /// Data dikumpulkan oleh View (EditCarScreen) dan dikirim sebagai Map.
  Future<bool> submitEditCar(String originalRangka, Map<String, dynamic> data) async {
    if (originalRangka.isEmpty) {
      _errorMessage = 'Data mobil tidak valid';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _carService.updateCar(originalRangka, data);
      await getAllCars(); // refresh daftar
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal mengedit data: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Muat semua data kendaraan dari database.
  Future<void> getAllCars() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _cars = await _carService.fetchAllCars();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
