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
  List<OrderKerja> _serviceRules = [];
  final Map<String, int> _lastServiceOdometer = {};
  bool isLoading = false;
  String? errorMessage;
  String _tipeMesin = '';
  String _tipeTransmisi = '';

  int get totalItem => daftarDetail.length;
  int get itemSelesai =>
      daftarDetail.where((d) => d.status == StatusItem.selesai).length;
  double get progress => totalItem == 0 ? 0 : itemSelesai / totalItem;
  int _kmTerakhir = 0;
  int get kmTerakhir => _kmTerakhir;

  List<ServiceReminderItem> get serviceReminders {
    if (kmTerakhir == 0 || _serviceRules.isEmpty) return [];

    final result = <ServiceReminderItem>[];

    for (final rule in _serviceRules) {
      final interval = rule.intervalKm;
      if (interval == null || interval <= 0) {
        continue;
      }

      if (_tipeMesin.isNotEmpty && rule.kompatibilitasMesin.isNotEmpty) {
        if (!rule.kompatibilitasMesin.contains(_tipeMesin)) continue;
      }
      if (_tipeTransmisi.isNotEmpty &&
          rule.kompatibilitasTransmisi.isNotEmpty) {
        if (!rule.kompatibilitasTransmisi.contains(_tipeTransmisi)) continue;
      }

      final lastDoneOdometer = _lastServiceOdometer[rule.id];

      int kmBerikutnya;

      if (lastDoneOdometer != null) {
        kmBerikutnya = lastDoneOdometer + interval;
      } else {
        kmBerikutnya = kmTerakhir + interval;
      }

      result.add(ServiceReminderItem(
        nama: rule.nama,
        intervalKm: interval,
        kmTerakhir: kmTerakhir,
        kmBerikutnya: kmBerikutnya,
      ));
    }

    // Urutkan: overdue dulu, lalu yang paling dekat
    result.sort((a, b) => a.sisaKm.compareTo(b.sisaKm));
    return result;
  }

  // ── Fetch: service rules ──────────────────────────────────

  Future<void> _muatServiceRules() async {
    try {
      _serviceRules = await _orderKerjaService.fetchServiceRules();
    } catch (e) {
      _serviceRules = [];
    }
  }

  Future<void> muatOrderByCustomer(
    String customerId, {
    String tipeMesin = '',
    String tipeTransmisi = '',
  }) async {
    _tipeMesin = tipeMesin;
    _tipeTransmisi = tipeTransmisi;
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _orderServiceService.fetchOrderByCustomer(customerId),
        _muatServiceRules(),
        _customerService.fetchOdometer(customerId),
        _orderServiceDetailService.fetchCompletedServiceOdometer(customerId),
      ]);

      final kmDariCustomer = results[2] as int;
      daftarOrder = results[0] as List<OrderServiceSummary>;

      final kmDariOrder = daftarOrder.isEmpty
          ? 0
          : daftarOrder.map((o) => o.kilometer).reduce(max);
      _kmTerakhir = max(kmDariCustomer, kmDariOrder);

      final completedItems = results[3] as List<dynamic>;
      _lastServiceOdometer.clear();
      for (var row in completedItems) {
        final orderKerjaId = row['order_kerja_id'] as String;
        final os = row['order_service'] as Map<String, dynamic>?;
        if (os != null) {
          final odometer = os['kilometer'] as int? ?? 0;
          if (!_lastServiceOdometer.containsKey(orderKerjaId) ||
              _lastServiceOdometer[orderKerjaId]! < odometer) {
            _lastServiceOdometer[orderKerjaId] = odometer;
          }
        }
      }
    } catch (e) {
      errorMessage = 'Gagal memuat data: $e';
    }

    isLoading = false;
    notifyListeners();
  }

  /// Menyinkronkan status order_service ke DB berdasarkan progress item pekerjaan.
  /// Dipanggil setiap kali status item berubah.
  /// Status 'Selesai' di DB hanya ditulis oleh [finalisasiOrder].
  Future<void> _cekDanUpdateStatusOrder() async {
    if (daftarDetail.isEmpty) return;

    final semuaSelesai =
        daftarDetail.every((d) => d.status == StatusItem.selesai);
    final semuaMenunggu =
        daftarDetail.every((d) => d.status == StatusItem.menunggu);

    // Tentukan status baru untuk DB — 'Selesai' di DB hanya lewat finalisasiOrder
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

    // Jangan overwrite jika sudah 'Selesai' di DB (sudah difinalisasi)
    if (statusSekarang == 'Selesai') return;

    // Update DB hanya jika status berubah
    if (statusSekarang != statusBaru) {
      await _orderServiceService.updateStatus(nomorWo, statusBaru);

      // Update local state
      if (orderIndex != -1) {
        daftarOrder[orderIndex] =
            daftarOrder[orderIndex].copyWith(status: statusBaru);
      }
    }

    // Tandai progress selesai di local state untuk menampilkan tombol Finalisasi
    // (hanya UI, tidak mengubah DB)
    if (semuaSelesai &&
        orderIndex != -1 &&
        daftarOrder[orderIndex].status != 'Selesai') {
      // Gunakan flag lokal, bukan mengubah daftarOrder.status
      // Tombol Finalisasi dikontrol dari isSemuaItemSelesai && !isHistory di UI
    }
  }

  // ── Fetch: detail WO ──────────────────────────────────────

  Future<void> muatDetail(int nomorWo) async {
    isLoading = true;
    notifyListeners();
    try {
      daftarDetail =
          await _orderServiceDetailService.fetchDetailByNomorWo(nomorWo);
      // Catatan: TIDAK memanggil _cekDanUpdateStatusOrder di sini
      // agar status dari DB tidak ditimpa saat pertama kali load
    } catch (e) {
      errorMessage = 'Gagal memuat detail: $e';
    }

    isLoading = false;
    notifyListeners();
  }

  // ── Ubah status item pekerjaan ────────────────────────────

  Future<void> ubahStatusItem({
    required String detailId,
    required StatusItem statusBaru,
    String? catatan,
  }) async {
    try {
      // 1. Simpan ke Database (Supabase) terlebih dahulu
      final success = await _orderServiceDetailService.updateStatusItem(
        detailId: detailId,
        statusBaru: statusBaru,
        catatanTeknisi: catatan,
      );

      if (!success) {
        throw Exception('Gagal menyimpan perubahan ke server.');
      }

      // 2. Jika berhasil, baru update UI (Local State)
      final index = daftarDetail.indexWhere((d) => d.id == detailId);
      if (index != -1) {
        daftarDetail[index] = daftarDetail[index].copyWith(
          status: statusBaru,
          catatanTeknisi: catatan,
        );
      }

      // 3. Sinkronkan status order_service ke DB
      await _cekDanUpdateStatusOrder();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      errorMessage = 'Gagal memperbarui status: $e';
      notifyListeners();
    }
  }

  /// Menambahkan pekerjaan baru ke dalam WO yang sedang berjalan.
  /// Dipanggil dari tombol "Tambah Pekerjaan / Part" di halaman detail.
  Future<bool> tambahPekerjaanBaru({
    required int nomorWo,
    required String orderKerjaId,
    required String namaPekerjaan,
    required String kodePekerjaan,
    required int hargaFinal,
  }) async {
    try {
      final item = await _orderServiceDetailService.insertDetailItem(
        nomorWo      : nomorWo,
        orderKerjaId : orderKerjaId,
        hargaFinal   : hargaFinal,
      );
      if (item == null) throw Exception('Insert gagal');

      // Update local state
      daftarDetail.add(item);

      // Update total tagihan di local daftarOrder
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

        // Update total tagihan di DB juga
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

  /// Finalisasi order: set status 'Selesai' di DB dan update local state.
  /// Dipanggil saat kasir menekan tombol "FINALISASI & CETAK WO".
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
