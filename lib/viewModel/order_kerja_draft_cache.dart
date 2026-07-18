import '../models/order_kerja_models.dart';
import 'order_kerja_viewmodel.dart';

/// State draft satu sesi order kerja untuk satu kendaraan.
class OrderKerjaDraft {
  final List<OrderKerja> keranjangJasa;
  final Map<String, List<SparepartEntry>> sparepartPerPekerjaan;
  final Map<String, int> hargaJasaCustom;
  final int kilometer;
  final String keluhan;

  OrderKerjaDraft({
    required this.keranjangJasa,
    required this.sparepartPerPekerjaan,
    required this.hargaJasaCustom,
    required this.kilometer,
    required this.keluhan,
  });

  bool get isEmpty =>
      keranjangJasa.isEmpty &&
      sparepartPerPekerjaan.isEmpty &&
      kilometer == 0 &&
      keluhan.isEmpty;
}

class OrderKerjaDraftCache {
  OrderKerjaDraftCache._();
  static final OrderKerjaDraftCache instance = OrderKerjaDraftCache._();

  final Map<String, OrderKerjaDraft> _drafts = {};

  void simpan({
    required String nomorRangka,
    required OrderKerjaViewModel vm,
    required String keluhan,
  }) {
    _drafts[nomorRangka] = OrderKerjaDraft(
      keranjangJasa: List<OrderKerja>.from(vm.keranjangJasa),
      sparepartPerPekerjaan: Map.from(
        vm.sparepartPerPekerjaan.map(
          (key, entries) => MapEntry(key, List<SparepartEntry>.from(entries)),
        ),
      ),
      hargaJasaCustom: Map.from(vm.hargaJasaCustom),
      kilometer: vm.kilometer,
      keluhan: keluhan,
    );
  }

  OrderKerjaDraft? ambil(String nomorRangka) => _drafts[nomorRangka];

  void hapus(String nomorRangka) => _drafts.remove(nomorRangka);

  /// Cek apakah ada draft aktif untuk kendaraan ini.
  bool punyaDraft(String nomorRangka) {
    final draft = _drafts[nomorRangka];
    return draft != null && !draft.isEmpty;
  }
}
