import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order_kerja_models.dart';
import '../models/sparepart_models.dart';
import '../services/order_kerja_services.dart';
import '../services/sparepart_services.dart';

class SparepartEntry {
  final Sparepart sparepart;
  int qty;

  SparepartEntry({required this.sparepart, this.qty = 1});

  int get subtotal => sparepart.hargaJual * qty;
}

class OrderKerjaViewModel extends ChangeNotifier {
  final OrderKerjaServices _orderKerjaServices = OrderKerjaServices();
  final SparepartServices _sparepartServices = SparepartServices();

  List<OrderKerja> daftarKerja = [];
  List<OrderKerja> daftarKerjaAsli = [];
  List<OrderKerja> daftarKerjaTampil = [];
  List<OrderKerja> keranjangJasa = [];

  String _keywordPencarian = '';
  String _kategoriTerpilih = 'Semua';

  String get kategoriTerpilih => _kategoriTerpilih;

  /// Daftar kategori diambil dinamis dari pekerjaan yang tersedia
  List<String> get daftarKategori {
    final Set<String> categories = {'Semua'};
    for (var jasa in daftarKerjaAsli) {
      if (jasa.kategoriPerbaikan != null && jasa.kategoriPerbaikan!.isNotEmpty) {
        categories.add(jasa.kategoriPerbaikan!);
      }
    }
    return categories.toList()..sort((a, b) => a == 'Semua' ? -1 : (b == 'Semua' ? 1 : a.compareTo(b)));
  }

  /// Sparepart yang dipilih per pekerjaan (key = orderKerja.id)
  Map<String, List<SparepartEntry>> sparepartPerPekerjaan = {};

  /// Sparepart yang tersedia untuk dialog pilih
  List<Sparepart> daftarSparepart = [];
  bool isLoadingSparepart = false;

  bool isLoading = false;
  String? errorMessage;

  /// Tipe kendaraan pelanggan — diisi saat muatKerjaUntukMobil dipanggil
  /// agar dapat dipakai sebagai filter saat memilih sparepart.
  String _tipeMesin = '';
  String _tipeTransmisi = '';

  String get tipeMesin => _tipeMesin;
  String get tipeTransmisi => _tipeTransmisi;

  // ── Kilometer ─────────────────────────────────
  int _kilometer = 0;
  int get kilometer => _kilometer;

  void setKilometer(int value) {
    _kilometer = value;
    notifyListeners();
  }

  // ── Load pekerjaan ────────────────────────────


  Future<void> loadKerja() async {
    _setLoading(true);
    try {
      daftarKerja = await _orderKerjaServices.fetchSemuaKerja();
      errorMessage = null;
    } catch (e) {
      errorMessage = 'Gagal memuat daftar menu: $e';
    }
    _setLoading(false);
  }

  Future<void> muatKerjaUntukMobil({
    required String mesin,
    required String transmisi,
  }) async {
    _tipeMesin = mesin;
    _tipeTransmisi = transmisi;
    _setLoading(true);
    try {
      daftarKerja = await _orderKerjaServices.fetchKerjaSesuaiMobil(
        mesinMobil: mesin,
        transmisiMobil: transmisi,
      );
      daftarKerjaAsli = daftarKerja;
      daftarKerjaTampil = daftarKerja;
      errorMessage = null;
    } catch (e) {
      errorMessage = 'Gagal memuat menu untuk mobil ini: $e';
    }
    _setLoading(false);
  }

  // ── Sparepart loading ─────────────────────────

  /// Muat sparepart yang tersedia berdasarkan kategori teks pekerjaan,
  /// difilter otomatis sesuai tipe mesin & transmisi kendaraan.
  Future<void> muatSparepartUntukPekerjaan(OrderKerja jasa) async {
    // Jika pekerjaan tidak butuh sparepart, skip
    if (!jasa.requiresSparepart) {
      daftarSparepart = [];
      return;
    }

    isLoadingSparepart = true;
    notifyListeners();

    try {
      daftarSparepart = await _sparepartServices.fetchCocokUntukPekerjaan(
        kategori: jasa.kategoriSparepart!,
        tipeMesin: _tipeMesin.isNotEmpty ? _tipeMesin : null,
        tipeTransmisi: _tipeTransmisi.isNotEmpty ? _tipeTransmisi : null,
      );
    } catch (e) {
      daftarSparepart = [];
    }

    isLoadingSparepart = false;
    notifyListeners();
  }


  // ── Keranjang management ──────────────────────

  void cariPekerjaan(String keyword) {
    _keywordPencarian = keyword;
    _terapkanFilter();
  }

  void setKategori(String kategori) {
    _kategoriTerpilih = kategori;
    _terapkanFilter();
  }

  void _terapkanFilter() {
    daftarKerjaTampil = daftarKerjaAsli.where((jasa) {
      final matchKeyword = _keywordPencarian.isEmpty ||
          jasa.nama.toLowerCase().contains(_keywordPencarian.toLowerCase());
      
      final matchKategori = _kategoriTerpilih == 'Semua' ||
          jasa.kategoriPerbaikan == _kategoriTerpilih;

      return matchKeyword && matchKategori;
    }).toList();
    notifyListeners();
  }

  void toggleKeranjang(OrderKerja jasa) {
    if (keranjangJasa.contains(jasa)) {
      keranjangJasa.remove(jasa);
    } else {
      keranjangJasa.add(jasa);
    }
    notifyListeners();
  }

  bool isJasaDipilih(OrderKerja jasa) {
    return keranjangJasa.contains(jasa);
  }

  void tambahKeKeranjangDenganSparepart(
    OrderKerja jasa,
    List<SparepartEntry> items,
  ) {
    sparepartPerPekerjaan[jasa.id] = items;

    if (!keranjangJasa.contains(jasa)) {
      keranjangJasa.add(jasa);
    }
    notifyListeners();
  }

  void hapusDariKeranjang(OrderKerja jasa) {
    keranjangJasa.remove(jasa);
    sparepartPerPekerjaan.remove(jasa.id);
    notifyListeners();
  }

  // ── Hitung total ──────────────────────────────

  int get totalEstimasi {
    int total = 0;
    for (final jasa in keranjangJasa) {
      total += jasa.estimasiHarga;
      final spareparts = sparepartPerPekerjaan[jasa.id] ?? [];
      for (final sp in spareparts) {
        total += sp.subtotal;
      }
    }
    return total;
  }

  Future<bool> simpanOrderKerja({
    required String customerId, // nomor_rangka
    required String catatanKeluhan,
  }) async {
    if (keranjangJasa.isEmpty) return false;
    if (_kilometer <= 0) {
      return false;
    }

    try {
      final supabase = Supabase.instance.client;
      final header = await supabase
          .from('order_service')
          .insert({
            'customer_id': customerId,
            'kilometer': _kilometer,
            'catatan_keluhan': catatanKeluhan,
            'total_tagihan': totalEstimasi,
            'status': 'Menunggu',
          })
          .select('nomor_wo')
          .single();

      final int nomorWo = header['nomor_wo'];
      for (final jasa in keranjangJasa) {
        final sparepartItems = sparepartPerPekerjaan[jasa.id] ?? [];
        final totalSparepart = sparepartItems.fold<int>(
          0,
          (sum, sp) => sum + sp.subtotal,
        );

        final detail = await supabase
            .from('order_service_detail')
            .insert({
              'nomor_wo': nomorWo,
              'order_kerja_id': jasa.id,
              'harga_final': jasa.estimasiHarga + totalSparepart,
            })
            .select('id')
            .single();

        final String detailId = detail['id'];

        // 3. Insert sparepart per pekerjaan
        for (final entry in sparepartItems) {
          await supabase.from('sparepart_service').insert({
            'order_service_detail_id': detailId,
            'sparepart_id': entry.sparepart.id,
            'nama_item_snapshot': entry.sparepart.displayName,
            'spesifikasi_snapshot': entry.sparepart.merk,
            'harga_satuan': entry.sparepart.hargaJual,
            'qty': entry.qty,
          });
        }
      }

      await supabase.from('customer').update({
        'odometer_terakhir': _kilometer,
        'tgl_service_terakhir': DateTime.now().toIso8601String(),
      }).eq('nomor_rangka', customerId);

      keranjangJasa.clear();
      sparepartPerPekerjaan.clear();
      _kilometer = 0;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}
