import 'package:flutter/material.dart';
import '../models/order_kerja_models.dart';
import '../services/order_kerja_services.dart';

class EditKatalogViewModel extends ChangeNotifier {
  final OrderKerjaServices _service = OrderKerjaServices();
  bool _disposed = false;

  List<OrderKerja> daftarKerja = [];
  List<OrderKerja> daftarFiltered = [];
  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;
  String? successMessage;

  String _keyword = '';
  String _kategoriFilter = 'Semua';

  List<String> get daftarKategori {
    final Set<String> categories = {'Semua'};
    for (var jasa in daftarKerja) {
      if (jasa.kategoriPerbaikan != null && jasa.kategoriPerbaikan!.isNotEmpty) {
        categories.add(jasa.kategoriPerbaikan!);
      }
    }
    return categories.toList()..sort((a, b) => a == 'Semua' ? -1 : (b == 'Semua' ? 1 : a.compareTo(b)));
  }

  static const List<String> mesinList = ['Bensin', 'Diesel', 'Hybrid', 'Electric'];
  static const List<String> transmisiList = ['Manual', 'Automatic', 'CVT', 'DCT'];

  String get kategoriFilter => _kategoriFilter;

  EditKatalogViewModel() {
    load();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    _safeNotify();
    try {
      daftarKerja = await _service.fetchSemuaKerjaTermasukNonAktif();
      _terapkanFilter();
    } catch (e) {
      errorMessage = 'Gagal memuat data: $e';
    }
    isLoading = false;
    _safeNotify();
  }

  void cari(String keyword) {
    _keyword = keyword.trim().toLowerCase();
    _terapkanFilter();
  }

  void setKategori(String kategori) {
    _kategoriFilter = kategori;
    _terapkanFilter();
  }

  void _terapkanFilter() {
    daftarFiltered = daftarKerja.where((e) {
      final cocokKategori =
          _kategoriFilter == 'Semua' || e.kategoriPerbaikan == _kategoriFilter;
      final cocokKeyword = _keyword.isEmpty ||
          e.nama.toLowerCase().contains(_keyword);
      return cocokKategori && cocokKeyword;
    }).toList();
    _safeNotify();
  }

  Future<bool> simpanBaru({
    required String nama,
    required int estimasiHarga,
    String? kategoriPerbaikan,
    String? kategoriSparepart,
    List<String> kompatibilitasMesin = const [],
    List<String> kompatibilitasTransmisi = const [],
    int? intervalKm,
    int? intervalBulan,
    bool isActive = true,
  }) async {
    isSaving = true;
    errorMessage = null;
    successMessage = null;
    _safeNotify();

    final result = await _service.insertPekerjaanBaru(
      nama: nama,
      estimasiHarga: estimasiHarga,
      kategoriPerbaikan: kategoriPerbaikan == 'Semua' ? null : kategoriPerbaikan,
      kategoriSparepart: kategoriSparepart,
      kompatibilitasMesin: kompatibilitasMesin,
      kompatibilitasTransmisi: kompatibilitasTransmisi,
      intervalKm: intervalKm,
      intervalBulan: intervalBulan,
      isActive: isActive,
    );

    isSaving = false;
    if (result != null) {
      successMessage = '"${result.nama}" berhasil ditambahkan';
      await load();
      return true;
    } else {
      errorMessage = 'Gagal menambah. Cek RLS INSERT di Supabase.';
      _safeNotify();
      return false;
    }
  }

  Future<bool> simpanUpdate({
    required String id,
    required String nama,
    required int estimasiHarga,
    String? kategoriPerbaikan,
    String? kategoriSparepart,
    List<String> kompatibilitasMesin = const [],
    List<String> kompatibilitasTransmisi = const [],
    int? intervalKm,
    int? intervalBulan,
    required bool isActive,
  }) async {
    isSaving = true;
    errorMessage = null;
    successMessage = null;
    _safeNotify();

    final ok = await _service.updatePekerjaan(id, {
      'nama': nama,
      'estimasi_harga': estimasiHarga,
      'kategori_perbaikan': kategoriPerbaikan == 'Semua' ? null : kategoriPerbaikan,
      'kategori_sparepart': kategoriSparepart,
      'kompatibilitas_mesin': kompatibilitasMesin,
      'kompatibilitas_transmisi': kompatibilitasTransmisi,
      'interval_km': intervalKm,
      'interval_bulan': intervalBulan,
      'is_active': isActive,
    });

    isSaving = false;
    if (ok) {
      successMessage = '"$nama" berhasil diperbarui';
      await load();
      return true;
    } else {
      errorMessage = 'Gagal memperbarui. Cek RLS UPDATE di Supabase.';
      _safeNotify();
      return false;
    }
  }

  Future<bool> hapusPekerjaan(String id, String nama) async {
    isSaving = true;
    errorMessage = null;
    successMessage = null;
    _safeNotify();

    final ok = await _service.deletePekerjaan(id);
    isSaving = false;
    if (ok) {
      successMessage = '"$nama" berhasil dihapus';
      await load();
      return true;
    } else {
      errorMessage = 'Gagal menghapus. Pekerjaan mungkin masih dipakai WO aktif.';
      _safeNotify();
      return false;
    }
  }

  void clearPesan() {
    errorMessage = null;
    successMessage = null;
    _safeNotify();
  }
}
