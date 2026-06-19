import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order_kerja_models.dart';

class OrderKerjaServices {
  final _supabase = Supabase.instance.client;

  /// Query SELECT dengan join ke kategori_sparepart
  static const _selectWithKategori = '''
    *,
    order_kerja_kategori_sparepart (
      is_required,
      kategori_sparepart (
        id, nama, unit
      )
    )
  ''';

  /// Fetch semua pekerjaan aktif
  Future<List<OrderKerja>> fetchSemuaKerja() async {
    try {
      final response = await _supabase
          .from('order_kerja')
          .select(_selectWithKategori)
          .eq('is_active', true)
          .order('kode', ascending: true);

      return response
          .map((item) => OrderKerja.fromJson(item))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Fetch pekerjaan yang kompatibel dengan mesin & transmisi mobil
  Future<List<OrderKerja>> fetchKerjaSesuaiMobil({
    required String mesinMobil,
    required String transmisiMobil,
  }) async {
    try {
      // Ambil semua yang aktif, lalu filter di client
      // karena PostgREST tidak support "contains OR is null" dalam 1 filter
      final response = await _supabase
          .from('order_kerja')
          .select(_selectWithKategori)
          .eq('is_active', true)
          .order('kode', ascending: true);

      final semuaKerja = response
          .map((item) => OrderKerja.fromJson(item))
          .toList();

      // Filter: kompatibel jika array null/kosong (universal) ATAU mengandung tipe mobil
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
}