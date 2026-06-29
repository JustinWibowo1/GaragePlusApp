import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/sparepart_models.dart';

class SparepartServices {
  final _supabase = Supabase.instance.client;

  /// Fetch sparepart berdasarkan kategori teks dari order_kerja
  /// dan filter sesuai tipe mesin / transmisi kendaraan.
  Future<List<Sparepart>> fetchCocokUntukPekerjaan({
    required String kategori,
    String? tipeMesin,
    String? tipeTransmisi,
  }) async {
    try {
      final response = await _supabase
          .from('sparepart')
          .select('*')
          .eq('kategori', kategori)
          .eq('is_active', true)
          .order('nama', ascending: true);

      final semua = response.map((item) => Sparepart.fromJson(item)).toList();

      // Filter kompatibilitas di sisi client
      return semua.where((sp) {
        // Kompatibilitas mesin: kosong = universal
        final mesinOk = tipeMesin == null ||
            sp.kompatibilitasMesin.isEmpty ||
            sp.kompatibilitasMesin.contains(tipeMesin);

        // Kompatibilitas transmisi: kosong = universal
        final transmisiOk = tipeTransmisi == null ||
            sp.kompatibilitasTransmisi.isEmpty ||
            sp.kompatibilitasTransmisi.contains(tipeTransmisi);

        return mesinOk && transmisiOk;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Fetch semua sparepart aktif
  Future<List<Sparepart>> fetchSemua() async {
    try {
      final response = await _supabase
          .from('sparepart')
          .select('*')
          .eq('is_active', true)
          .order('nama', ascending: true);

      return response.map((item) => Sparepart.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Cari sparepart berdasarkan keyword nama
  Future<List<Sparepart>> cari(String keyword) async {
    try {
      final response = await _supabase
          .from('sparepart')
          .select('*')
          .eq('is_active', true)
          .ilike('nama', '%$keyword%')
          .order('nama', ascending: true);

      return response.map((item) => Sparepart.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }
}
