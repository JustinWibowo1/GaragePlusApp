import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order_service_models.dart';

class OrderServiceServices {
  final _supabase = Supabase.instance.client;

  Future<List<OrderServiceSummary>> fetchOrderByCustomer(
      String customerId) async {
    try {
      final response = await _supabase
          .from('order_service')
          .select()
          .eq('customer_id', customerId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) =>
              OrderServiceSummary.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> updateTotalTagihan(int nomorWo, int totalBaru) async {
    try {
      await _supabase
          .from('order_service')
          .update({'total_tagihan': totalBaru})
          .eq('nomor_wo', nomorWo);
    } catch (_) {}
  }

  Future<bool> updateStatus(int nomorWo, String status) async {
    try {
      await _supabase.from('order_service').update({
        'status': status,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('nomor_wo', nomorWo);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateStatusSelesai(int nomorWo, {DateTime? completedAt}) async {
    try {
      await _supabase.from('order_service').update({
        'status': 'Selesai',
        'updated_at': (completedAt ?? DateTime.now()).toUtc().toIso8601String(),
      }).eq('nomor_wo', nomorWo);
      return true;
    } catch (e) {
      return false;
    }
  }
}
