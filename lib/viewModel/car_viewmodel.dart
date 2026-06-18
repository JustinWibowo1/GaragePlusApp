import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../Services/customer_services.dart';

class CarViewModel extends ChangeNotifier {
  final CarService _carService = CarService();
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<Map<String, dynamic>> _cars = [];
  List<Map<String, dynamic>> get cars => _cars;

  // ── Form State & Controllers ──────────────────────────────────
  final TextEditingController rangkaCtrl     = TextEditingController();
  final TextEditingController mesinCtrl      = TextEditingController();
  final TextEditingController polisiCtrl     = TextEditingController();
  final TextEditingController jenisCtrl      = TextEditingController();
  final TextEditingController typeCtrl       = TextEditingController();
  final TextEditingController tahunCtrl      = TextEditingController();
  final TextEditingController ownerCtrl      = TextEditingController(); // nama saja, tanpa sapaan
  final TextEditingController alamatCtrl     = TextEditingController();
  final TextEditingController teleponCtrl    = TextEditingController();
  final TextEditingController perusahaanCtrl = TextEditingController();
  final TextEditingController kotaCtrl       = TextEditingController();

  String? tipeMesin;
  String? tipeTransmisi;
  String  sapaan = 'Bapak'; // default sapaan

  static const List<String> mesinOpts     = ['Bensin', 'Diesel', 'Hybrid'];
  static const List<String> transmisiOpts = ['Manual', 'Matic', 'CVT'];
  static const List<String> sapaanOpts    = ['Bapak', 'Ibu'];

  void setTipeMesin(String? value) {
    tipeMesin = value;
    notifyListeners();
  }

  void setTipeTransmisi(String? value) {
    tipeTransmisi = value;
    notifyListeners();
  }

  void setSapaan(String value) {
    sapaan = value;
    notifyListeners();
  }

  void initForm({Map<String, dynamic>? data}) {
    final d = data ?? {};
    rangkaCtrl.text      = d['nomor_rangka']    ?? '';
    mesinCtrl.text       = d['nomor_mesin']     ?? '';
    polisiCtrl.text      = d['nomor_polisi']    ?? '';
    jenisCtrl.text       = d['jenis_mobil']     ?? '';
    typeCtrl.text        = d['tipe_mobil']      ?? '';
    tahunCtrl.text       = d['tahun']?.toString() ?? '';
    alamatCtrl.text      = d['alamat_pemilik']  ?? '';
    teleponCtrl.text     = d['no_telepon']      ?? '';
    perusahaanCtrl.text  = d['nama_perusahaan'] ?? '';
    kotaCtrl.text        = d['kota_pemilik']    ?? '';

    // Parse sapaan & nama dari nama_pemilik yang tersimpan
    final fullName = d['nama_pemilik'] as String? ?? '';
    final knownSapaan = sapaanOpts.firstWhere(
      (s) => fullName.startsWith('$s '),
      orElse: () => 'Bapak',
    );
    sapaan        = knownSapaan;
    ownerCtrl.text = fullName.startsWith('$knownSapaan ')
        ? fullName.substring(knownSapaan.length + 1)
        : fullName;

    final rawM = d['tipe_mesin']     as String? ?? '';
    final rawT = d['tipe_transmisi'] as String? ?? '';
    tipeMesin     = mesinOpts.contains(rawM)     ? rawM : null;
    tipeTransmisi = transmisiOpts.contains(rawT) ? rawT : null;

    _errorMessage = null;
  }

  void clearForm() {
    initForm(data: null);
  }

  // ── Actions ───────────────────────────────────────────────────

  Future<bool> submitAddCar() async {
    final rangka = rangkaCtrl.text.trim();
    if (rangka.isEmpty) {
      _errorMessage = 'Nomor Rangka wajib diisi';
      notifyListeners();
      return false;
    }
    if (tipeMesin == null || tipeTransmisi == null) {
      _errorMessage = 'Tipe mesin dan transmisi wajib dipilih';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Gabungkan sapaan + nama untuk disimpan
    final namaPemilikFull = '$sapaan ${ownerCtrl.text.trim()}';

    try {
      bool exists = await _carService.isCarExists(rangka);
      if (exists) {
        _errorMessage = 'Mobil Sudah ada';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      await _carService.saveCar({
        'nomor_rangka'   : rangka,
        'nomor_mesin'    : mesinCtrl.text.trim(),
        'nomor_polisi'   : polisiCtrl.text.trim(),
        'jenis_mobil'    : jenisCtrl.text.trim(),
        'tipe_mobil'     : typeCtrl.text.trim(),
        'tahun'          : int.tryParse(tahunCtrl.text.trim()) ?? 0,
        'tipe_mesin'     : tipeMesin,
        'tipe_transmisi' : tipeTransmisi,
        'nama_pemilik'   : namaPemilikFull,
        'alamat_pemilik' : alamatCtrl.text.trim().isEmpty ? null : alamatCtrl.text.trim(),
        'no_telepon'     : teleponCtrl.text.trim(),
        'nama_perusahaan': perusahaanCtrl.text.trim().isEmpty ? null : perusahaanCtrl.text.trim(),
        'kota_pemilik'   : kotaCtrl.text.trim().isEmpty ? null : kotaCtrl.text.trim(),
      });
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

  

  Future<bool> submitEditCar(String originalRangka) async {
    if (originalRangka.isEmpty) {
      _errorMessage = 'Data mobil tidak valid';
      notifyListeners();
      return false;
    }
    if (tipeMesin == null || tipeTransmisi == null) {
      _errorMessage = 'Tipe mesin dan transmisi wajib dipilih';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final namaPemilikFull = '$sapaan ${ownerCtrl.text.trim()}';

    try {
      await Supabase.instance.client
          .from('customer')
          .update({
            'nomor_rangka'   : rangkaCtrl.text.trim(),
            'nomor_mesin'    : mesinCtrl.text.trim(),
            'nomor_polisi'   : polisiCtrl.text.trim(),
            'jenis_mobil'    : jenisCtrl.text.trim(),
            'tipe_mobil'     : typeCtrl.text.trim(),
            'tahun'          : int.tryParse(tahunCtrl.text.trim()) ?? 0,
            'nama_pemilik'   : namaPemilikFull,
            'alamat_pemilik' : alamatCtrl.text.trim().isEmpty ? null : alamatCtrl.text.trim(),
            'no_telepon'     : teleponCtrl.text.trim(),
            'tipe_mesin'     : tipeMesin,
            'tipe_transmisi' : tipeTransmisi,
            'nama_perusahaan': perusahaanCtrl.text.trim().isEmpty ? null : perusahaanCtrl.text.trim(),
            'kota_pemilik'   : kotaCtrl.text.trim().isEmpty ? null : kotaCtrl.text.trim(),
          })
          .eq('nomor_rangka', originalRangka);

      await getAllCars();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal mengedit data: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
}
