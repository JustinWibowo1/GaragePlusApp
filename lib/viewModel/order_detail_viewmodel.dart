import 'package:flutter/material.dart';
import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order_service_models.dart';
import '../models/service_details_models.dart';
import '../models/order_kerja_models.dart';

class OrderDetailViewModel extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  List<OrderServiceSummary> daftarOrder    = [];
  List<OrderServiceDetail>  daftarDetail   = [];
  List<OrderKerja>          _serviceRules  = [];
  Map<String, int>          _lastServiceOdometer = {};
  bool    isLoading    = false;
  String? errorMessage;

  // ── Metadata kendaraan (untuk filter kompatibilitas reminder) ──
  String _tipeMesin     = '';
  String _tipeTransmisi = '';

  // ── Getters progress ──────────────────────────────────────
  int    get totalItem   => daftarDetail.length;
  int    get itemSelesai => daftarDetail.where((d) => d.status == StatusItem.selesai).length;
  double get progress    => totalItem == 0 ? 0 : itemSelesai / totalItem;
  int _kmTerakhir = 0;
  int get kmTerakhir => _kmTerakhir;

  List<ServiceReminderItem> get serviceReminders {
    if (kmTerakhir == 0 || _serviceRules.isEmpty) return [];

    final result = <ServiceReminderItem>[];

    for (final rule in _serviceRules) {
      final interval = rule.intervalKm;
      if (interval == null || interval <= 0) continue;

      // ── FIX #3: Filter berdasarkan kompatibilitas mesin & transmisi ──
      // Hanya tampilkan reminder jika mesin/transmisi kendaraan ini kompatibel,
      // atau jika daftar kompatibilitas kosong (berlaku untuk semua).
      if (_tipeMesin.isNotEmpty && rule.kompatibilitasMesin.isNotEmpty) {
        if (!rule.kompatibilitasMesin.contains(_tipeMesin)) continue;
      }
      if (_tipeTransmisi.isNotEmpty && rule.kompatibilitasTransmisi.isNotEmpty) {
        if (!rule.kompatibilitasTransmisi.contains(_tipeTransmisi)) continue;
      }

      final lastDoneOdometer = _lastServiceOdometer[rule.id];

      int kmBerikutnya;

      if (lastDoneOdometer != null) {
        // Sudah pernah dikerjakan → target = terakhir dikerjakan + interval
        kmBerikutnya = lastDoneOdometer + interval;
      } else {
        // ── FIX #1: Kendaraan baru / belum pernah direkam ──
        // Jadwalkan dari km sekarang + interval, sehingga tidak langsung OVERDUE.
        // Sebelumnya menggunakan modulo yang menghasilkan false-positive OVERDUE
        // ketika km tepat merupakan kelipatan interval (mis. 50.000 % 5.000 = 0).
        kmBerikutnya = kmTerakhir + interval;
      }

      result.add(ServiceReminderItem(
        nama         : rule.nama,
        intervalKm   : interval,
        kmTerakhir   : kmTerakhir,
        kmBerikutnya : kmBerikutnya,
      ));
    }

    // Urutkan: overdue dulu, lalu yang paling dekat
    result.sort((a, b) => a.sisaKm.compareTo(b.sisaKm));
    return result;
  }

  // ── Fetch: service rules ──────────────────────────────────

  Future<void> _muatServiceRules() async {
    try {
      final response = await _supabase
          .from('order_kerja')
          .select('id, nama, kode, interval_km, kompatibilitas_mesin, kompatibilitas_transmisi, is_active')
          .not('interval_km', 'is', null)
          .eq('is_active', true)
          .order('interval_km', ascending: true);

      _serviceRules = (response as List)
          .map((e) => OrderKerja.fromJson(e as Map<String, dynamic>))
          .toList();

      print('✅ serviceRules: ${_serviceRules.length} item');
    } catch (e) {
      print('❌ Gagal muat service rules: $e');
      _serviceRules = [];
    }
  }

  // ── Fetch: orders by customer ─────────────────────────────

  Future<void> muatOrderByCustomer(
    String customerId, {
    String tipeMesin     = '',
    String tipeTransmisi = '',
  }) async {
    // Simpan metadata kendaraan untuk filter kompatibilitas
    _tipeMesin     = tipeMesin;
    _tipeTransmisi = tipeTransmisi;
    isLoading    = true;
    errorMessage = null;
    notifyListeners();

    print('🔍 customerId yang dikirim: $customerId');

    try {
      // Jalankan paralel: orders + service rules + odometer customer + riwayat item selesai
      final results = await Future.wait([
        _supabase
            .from('order_service')
            .select()
            .eq('customer_id', customerId)
            .order('created_at', ascending: false),
        _muatServiceRules(),
        _supabase
            .from('customer')
            .select('odometer_terakhir')
            .eq('nomor_rangka', customerId)
            .maybeSingle(),
        _supabase
            .from('order_service_detail')
            .select('''
              order_kerja_id,
              order_service!inner(customer_id, kilometer)
            ''')
            .eq('order_service.customer_id', customerId)
            .eq('status', 'Selesai'),
      ]);

      // ── FIX #2: Gunakan km tertinggi antara odometer_terakhir dan km dari WO ──
      // Mencegah _kmTerakhir stale jika odometer_terakhir belum diperbarui.
      final customerRow = results[2] as Map<String, dynamic>?;
      final kmDariCustomer = customerRow?['odometer_terakhir'] as int? ?? 0;
      final response = results[0] as List<dynamic>;

      daftarOrder = response
          .map((item) => OrderServiceSummary.fromJson(item as Map<String, dynamic>))
          .toList();

      final kmDariOrder = daftarOrder.isEmpty
          ? 0
          : daftarOrder.map((o) => o.kilometer).reduce(max);

      // Ambil nilai terbesar agar km tidak mundur
      _kmTerakhir = max(kmDariCustomer, kmDariOrder);

      print('📦 Response mentah: $response');
      print('📊 Jumlah data: ${response.length}');


      // 4. Proses riwayat item selesai untuk reset warning
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

      print('✅ daftarOrder: ${daftarOrder.length} item');
      print('✅ kmTerakhir: $_kmTerakhir km');
      print('✅ serviceReminders: ${serviceReminders.length} item');
      print('✅ lastServiceOdometer tracker: ${_lastServiceOdometer.length} pekerjaan pernah diselesaikan');
    } catch (e) {
      errorMessage = 'Gagal memuat data: $e';
      print('❌ Error: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  // ── Internal: sinkronisasi status order header ────────────

  Future<void> _cekDanUpdateStatusOrder() async {
    if (daftarDetail.isEmpty) {
      print('⚠️ daftarDetail kosong, skip cek');
      return;
    }

    print('🔍 Cek status semua item:');
    for (var d in daftarDetail) {
      print('   ${d.namaPekerjaan} → ${d.status.label}');
    }

    final semuaSelesai  = daftarDetail.every((d) => d.status == StatusItem.selesai);
    final semuaMenunggu = daftarDetail.every((d) => d.status == StatusItem.menunggu);

    final String statusBaruOrder;
    if (semuaSelesai) {
      statusBaruOrder = 'Selesai';
    } else if (semuaMenunggu) {
      statusBaruOrder = 'Menunggu';
    } else {
      statusBaruOrder = 'Dikerjakan';
    }

    print('📊 Status baru order: $statusBaruOrder');

    final nomorWo       = daftarDetail.first.nomorWo;
    final orderIndex    = daftarOrder.indexWhere((o) => o.nomorWo == nomorWo);
    final statusSekarang = orderIndex != -1 ? daftarOrder[orderIndex].status : null;

    print('📊 Status sekarang: $statusSekarang → akan jadi: $statusBaruOrder');

    if (statusSekarang == statusBaruOrder) {
      print('ℹ️ Status sama, skip update');
      return;
    }

    try {
      final result = await _supabase
          .from('order_service')
          .update({'status': statusBaruOrder})
          .eq('nomor_wo', nomorWo)
          .select();

      print('✅ Supabase diupdate: $result');

      if (orderIndex != -1) {
        daftarOrder[orderIndex] = daftarOrder[orderIndex].copyWith(
          status: statusBaruOrder,
        );
        print('✅ daftarOrder lokal → $statusBaruOrder');
      }
    } catch (e) {
      print('❌ Gagal update order status: $e');
    }
  }

  // ── Fetch: detail WO ──────────────────────────────────────

  Future<void> muatDetail(int nomorWo) async {
    isLoading = true;
    notifyListeners();

    print('🔍 nomorWo: $nomorWo');

    try {
      final response = await _supabase
          .from('order_service_detail')
          .select('''
            id,
            nomor_wo,
            order_kerja_id,
            harga_final,
            status,
            catatan_teknisi,
            created_at,
            order_kerja (
              nama,
              kode
            )
          ''')
          .eq('nomor_wo', nomorWo)
          .order('created_at', ascending: true);

      print('📦 Detail response: $response');

      daftarDetail = (response as List)
          .map((item) => OrderServiceDetail.fromJson(item as Map<String, dynamic>))
          .toList();

      print('✅ daftarDetail: ${daftarDetail.length} item');

      await _cekDanUpdateStatusOrder();
    } catch (e) {
      errorMessage = 'Gagal memuat detail: $e';
      print('❌ Error detail: $e');
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
      print('📤 Update status item $detailId → ${statusBaru.label}');

      final result = await _supabase
          .from('order_service_detail')
          .update({
            'status'         : statusBaru.label,
            'catatan_teknisi': catatan,
          })
          .eq('id', detailId)
          .select();

      print('✅ Result Supabase: $result');

      final index = daftarDetail.indexWhere((d) => d.id == detailId);
      if (index != -1) {
        daftarDetail[index] = daftarDetail[index].copyWith(
          status         : statusBaru,
          catatanTeknisi : catatan,
        );
        print('✅ Lokal diupdate index $index → ${statusBaru.label}');
      }

      await _cekDanUpdateStatusOrder();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      errorMessage = 'Gagal memperbarui status: $e';
      print('❌ Error ubah status: $e');
      notifyListeners();
    }
  }

  // ── Logic Reminder Kilometer Simple ─────────────────────────
  
  /// Menghitung sisa kilometer berdasarkan odometer target (odometer_terakhir) 
  /// dikurangi dengan odometer saat ini yang dimasukkan oleh user.
  int hitungSisaKilometer(int odometerInputUser) {
    return kmTerakhir - odometerInputUser;
  }

  /// Menghasilkan pesan reminder berdasarkan sisa kilometer.
  /// UI bisa memanggil ini dengan memberikan odometer yang dimasukkan user.
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