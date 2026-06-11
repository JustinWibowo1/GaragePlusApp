import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/sparepart_models.dart';

class SparepartServices {
  final _supabase = Supabase.instance.client;

  /// Fetch sparepart berdasarkan kategori ID
  Future<List<Sparepart>> fetchByKategori(String kategoriId) async {
    try {
      final response = await _supabase
          .from('sparepart')
          .select('''
            *,
            kategori_sparepart ( nama )
          ''')
          .eq('kategori_id', kategoriId)
          .eq('is_active', true)
          .order('nama', ascending: true);

      return response
          .map((item) => Sparepart.fromJson(item))
          .toList();
    } catch (e) {
      print('❌ Error fetch sparepart by kategori: $e');
      return [];
    }
  }

  /// Fetch sparepart berdasarkan multiple kategori IDs
  Future<List<Sparepart>> fetchByKategoriList(List<String> kategoriIds) async {
    if (kategoriIds.isEmpty) return [];

    try {
      final response = await _supabase
          .from('sparepart')
          .select('''
            *,
            kategori_sparepart ( nama )
          ''')
          .inFilter('kategori_id', kategoriIds)
          .eq('is_active', true)
          .order('nama', ascending: true);

      return response
          .map((item) => Sparepart.fromJson(item))
          .toList();
    } catch (e) {
      print('❌ Error fetch sparepart by kategori list: $e');
      return [];
    }
  }

  /// Fetch semua sparepart aktif
  Future<List<Sparepart>> fetchSemua() async {
    try {
      final response = await _supabase
          .from('sparepart')
          .select('''
            *,
            kategori_sparepart ( nama )
          ''')
          .eq('is_active', true)
          .order('nama', ascending: true);

      return response
          .map((item) => Sparepart.fromJson(item))
          .toList();
    } catch (e) {
      print('❌ Error fetch semua sparepart: $e');
      return [];
    }
  }

  /// Cari sparepart berdasarkan keyword
  Future<List<Sparepart>> cari(String keyword) async {
    try {
      final response = await _supabase
          .from('sparepart')
          .select('''
            *,
            kategori_sparepart ( nama )
          ''')
          .eq('is_active', true)
          .ilike('nama', '%$keyword%')
          .order('nama', ascending: true);

      return response
          .map((item) => Sparepart.fromJson(item))
          .toList();
    } catch (e) {
      print('❌ Error cari sparepart: $e');
      return [];
    }
  }
}
