import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/service_details_models.dart';

class OrderServiceDetailServices {
  final _supabase = Supabase.instance.client;

  Future<List<OrderServiceDetail>> fetchDetailByNomorWo(
    int nomorWo,
  ) async {
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

      return response
          .map((item) => OrderServiceDetail.fromJson(item))
          .toList();
    } catch (e) {
      print('Error fetch detail: $e');
      return [];
    }
  }

  Future<bool> updateStatusItem({
    required String detailId,
    required StatusItem statusBaru,
    String? catatanTeknisi,
  }) async {
    try {
      await _supabase
          .from('order_service_detail')
          .update({
            'status'          : statusBaru.label,
            'catatan_teknisi' : catatanTeknisi,
          })
          .eq('id', detailId);
      return true;
    } catch (e) {
      print('Error update status item: $e');
      return false;
    }
  }
}