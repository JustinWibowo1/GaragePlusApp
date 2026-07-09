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
              nama
            )
          ''')
          .eq('nomor_wo', nomorWo)
          .order('created_at', ascending: true);

      return response
          .map((item) => OrderServiceDetail.fromJson(item))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<OrderServiceDetail?> insertDetailItem({
    required int nomorWo,
    required String orderKerjaId,
    required int hargaFinal,
  }) async {
    try {
      final response = await _supabase
          .from('order_service_detail')
          .insert({
            'nomor_wo'      : nomorWo,
            'order_kerja_id': orderKerjaId,
            'harga_final'   : hargaFinal,
            'status'        : 'Menunggu',
          })
          .select('''
            id, nomor_wo, order_kerja_id, harga_final,
            status, catatan_teknisi, created_at,
            order_kerja ( nama )
          ''')
          .single();
      return OrderServiceDetail.fromJson(response);
    } catch (e) {
      return null;
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
      return false;
    }
  }

  Future<bool> updateHargaFinal({
    required String detailId,
    required int hargaBaru,
  }) async {
    try {
      await _supabase
          .from('order_service_detail')
          .update({'harga_final': hargaBaru})
          .eq('id', detailId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> hapusDetailItem(String detailId) async {
    try {
      await _supabase
          .from('order_service_detail')
          .delete()
          .eq('id', detailId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchCompletedServiceOdometer(String customerId) async {
    try {
      final response = await _supabase
          .from('order_service_detail')
          .select('''
            order_kerja_id,
            order_service!inner(customer_id, kilometer)
          ''')
          .eq('order_service.customer_id', customerId)
          .eq('status', 'Selesai');
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }
}