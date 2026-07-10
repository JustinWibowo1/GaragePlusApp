import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order_kerja_models.dart';

class OrderKerjaServices {
  final _supabase = Supabase.instance.client;

  /// Fetch semua pekerjaan aktif (tanpa join, schema baru)
  Future<List<OrderKerja>> fetchSemuaKerja() async {
    try {
      final response = await _supabase
          .from('order_kerja')
          .select('*')
          .eq('is_active', true,)
          .order('nama', ascending: true);

      return response.map((item) => OrderKerja.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Fetch pekerjaan yang kompatibel dengan mesin & transmisi mobil.
  /// Filter dilakukan di sisi client karena PostgREST tidak support
  /// "contains OR is null" dalam satu filter.
  Future<List<OrderKerja>> fetchKerjaSesuaiMobil({
    required String mesinMobil,
    required String transmisiMobil,
  }) async {
    try {
      final response = await _supabase
          .from('order_kerja')
          .select('*')
          .eq('is_active', true)
          .order('nama', ascending: true);

      final semuaKerja = response
          .map((item) => OrderKerja.fromJson(item))
          .toList();

      // Kompatibel jika array null/kosong (universal) ATAU mengandung tipe mobil
      return semuaKerja.where((kerja) {
        final mesinOk = kerja.kompatibilitasMesin.isEmpty ||
            kerja.kompatibilitasMesin.contains(mesinMobil);
        final transmisiOk = kerja.kompatibilitasTransmisi.isEmpty ||
            kerja.kompatibilitasTransmisi.contains(transmisiMobil);
        return mesinOk && transmisiOk;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Fetch pengingat servis dari View SQL
  Future<List<ServiceReminderItem>> fetchServiceReminders(String customerId) async {
    try {
      final response = await _supabase
          .from('v_service_reminders')
          .select('*')
          .eq('customer_id', customerId);

      return response
          .map((item) => ServiceReminderItem.fromJson(item))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Menambah pekerjaan custom baru yang ditulis manual oleh user
  Future<OrderKerja?> insertPekerjaanCustom(String nama, {int harga = 0}) async {
    try {
      final response = await _supabase.from('order_kerja').insert({
        'nama': nama,
        'estimasi_harga': harga,
        'is_active': false,
      }).select().single();

      return OrderKerja.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // ── Admin: Katalog Management ─────────────────────────────

  /// Fetch SEMUA pekerjaan (termasuk yang is_active = false) untuk halaman admin
  Future<List<OrderKerja>> fetchSemuaKerjaTermasukNonAktif() async {
    try {
      final response = await _supabase
          .from('order_kerja')
          .select('*')
          .order('kategori_perbaikan', ascending: true)
          .order('nama', ascending: true);
      return response.map((item) => OrderKerja.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Update data pekerjaan yang sudah ada
  Future<bool> updatePekerjaan(String id, Map<String, dynamic> data) async {
    try {
      await _supabase.from('order_kerja').update(data).eq('id', id);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Hapus pekerjaan secara permanen dari database
  Future<bool> deletePekerjaan(String id) async {
    try {
      await _supabase.from('order_kerja').delete().eq('id', id);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Insert pekerjaan baru dari admin (is_active = true secara default)
  Future<OrderKerja?> insertPekerjaanBaru({
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
    try {
      final response = await _supabase.from('order_kerja').insert({
        'nama': nama,
        'estimasi_harga': estimasiHarga,
        'kategori_perbaikan': kategoriPerbaikan,
        'kategori_sparepart': kategoriSparepart,
        'kompatibilitas_mesin': kompatibilitasMesin,
        'kompatibilitas_transmisi': kompatibilitasTransmisi,
        'interval_km': intervalKm,
        'interval_bulan': intervalBulan,
        'is_active': isActive,
      }).select().single();
      return OrderKerja.fromJson(response);
    } catch (e) {
      return null;
    }
  }
}