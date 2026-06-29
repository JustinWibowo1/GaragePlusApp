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
          .eq('is_active', true)
          .order('kode', ascending: true);

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
          .order('kode', ascending: true);

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

  /// Fetch pekerjaan yang memiliki interval service (untuk reminder)
  Future<List<OrderKerja>> fetchServiceRules() async {
    try {
      final response = await _supabase
          .from('order_kerja')
          .select('id, nama, kode, interval_km, kompatibilitas_mesin, kompatibilitas_transmisi, is_active')
          .not('interval_km', 'is', null)
          .eq('is_active', true)
          .order('interval_km', ascending: true);

      return (response as List)
          .map((e) => OrderKerja.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }
}