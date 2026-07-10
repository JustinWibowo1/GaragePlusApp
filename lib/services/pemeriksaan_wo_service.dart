import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pemeriksaan_wo_models.dart';

class PemeriksaanWOService {
  final _supabase = Supabase.instance.client;
  static const _table = 'pemeriksaan_wo';

  /// Ambil data pemeriksaan berdasarkan nomor WO. Returns null jika belum ada.
  Future<PemeriksaanWO?> fetchByNomorWo(int nomorWo) async {
    try {
      final response = await _supabase
          .from(_table)
          .select('*')
          .eq('nomor_wo', nomorWo)
          .maybeSingle();

      if (response == null) return null;
      return PemeriksaanWO.fromJson(response);
    } catch (e) {
      print('PemeriksaanWOService.fetchByNomorWo error: $e');
      return null;
    }
  }

  /// Simpan atau update (upsert) data pemeriksaan untuk satu WO.
  /// Karena ada UNIQUE constraint di nomor_wo, konflik akan diupdate.
  Future<PemeriksaanWO?> upsert(PemeriksaanWO data) async {
    try {
      final response = await _supabase
          .from(_table)
          .upsert(
            data.toUpsertJson(data.nomorWo),
            onConflict: 'nomor_wo',
          )
          .select()
          .single();

      return PemeriksaanWO.fromJson(response);
    } catch (e) {
      print('PemeriksaanWOService.upsert error: $e');
      return null;
    }
  }
}
