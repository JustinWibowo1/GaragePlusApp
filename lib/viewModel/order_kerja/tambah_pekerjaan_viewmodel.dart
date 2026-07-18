import 'package:flutter/material.dart';
import '../../models/order_kerja_models.dart';
import '../../services/order_kerja_services.dart';

class TambahPekerjaanViewModel extends ChangeNotifier {
  final OrderKerjaServices _service = OrderKerjaServices();

  List<OrderKerja> _semuaKatalog = [];
  List<OrderKerja> filtered = [];
  OrderKerja? dipilih;

  bool isLoading = true;
  bool isSaving = false;
  String selectedKategori = 'Semua';
  String keyword = '';

  String? errorMessage;

  TambahPekerjaanViewModel() {
    _muat();
  }

  Future<void> _muat() async {
    isLoading = true;
    notifyListeners();
    try {
      final data = await _service.fetchSemuaKerja();
      _semuaKatalog = data.where((e) => e.isActive).toList();
      filtered = _semuaKatalog;
    } catch (e) {
      errorMessage = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  List<Map<String, String>> get kategoriDinamis {
    final Set<String> rawCategories = {'Semua'};
    for (var jasa in _semuaKatalog) {
      if (jasa.kategoriPerbaikan != null &&
          jasa.kategoriPerbaikan!.isNotEmpty) {
        rawCategories.add(jasa.kategoriPerbaikan!);
      }
    }

    final sorted = rawCategories.toList()
      ..sort((a, b) => a == 'Semua' ? -1 : (b == 'Semua' ? 1 : a.compareTo(b)));

    const mapping = {
      'Semua': 'Semua',
      'MSN': 'Mesin',
      'REM': 'Rem',
      'PLM': 'Pelumas',
      'TRN': 'Transmisi',
      'BDY': 'Bodi',
      'ELK': 'Kelistrikan',
      'SUS': 'Suspensi',
    };

    return sorted
        .map((kode) => {
              'kode': kode,
              'nama': mapping[kode] ?? kode,
            })
        .toList();
  }

  void cariPekerjaan(String q) {
    keyword = q.trim();
    _terapkanFilter();
  }

  void setKategori(String k) {
    selectedKategori = k;
    _terapkanFilter();
  }

  void _terapkanFilter() {
    final q = keyword.toLowerCase();
    filtered = _semuaKatalog.where((e) {
      final cocokKategori = selectedKategori == 'Semua' ||
          e.kategoriPerbaikan == selectedKategori;
      final cocokSearch = q.isEmpty ||
          e.nama.toLowerCase().contains(q);
      return cocokKategori && cocokSearch;
    }).toList();

    if (q.isNotEmpty) {
      final isExactMatch = filtered.any((e) => e.nama.toLowerCase() == q);
      if (!isExactMatch) {
        filtered.insert(
            0,
            OrderKerja(
              id: 'CUSTOM',
              nama: '➕ Tambah Baru: "$keyword"',
              estimasiHarga: 0,
              kompatibilitasMesin: [],
              kompatibilitasTransmisi: [],
              isActive: true,
            ));
      }
    }
    notifyListeners();
  }

  void pilih(OrderKerja item) {
    if (dipilih?.id == item.id) {
      dipilih = null;
    } else {
      dipilih = item;
    }
    notifyListeners();
  }

  Future<OrderKerja?> insertPekerjaanCustom(int harga) async {
    isSaving = true;
    notifyListeners();
    try {
      final customItem =
          await _service.insertPekerjaanCustom(keyword, harga: harga);
      isSaving = false;
      notifyListeners();
      return customItem;
    } catch (e) {
      isSaving = false;
      notifyListeners();
      return null;
    }
  }
}
