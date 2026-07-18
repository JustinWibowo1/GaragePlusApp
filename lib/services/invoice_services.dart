import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/invoice_models.dart';

class InvoiceServices {
  final _supabase = Supabase.instance.client;
  final String _table = 'invoice';

  /// Mengambil semua invoice item berdasarkan nomor_wo
  Future<List<InvoiceItem>> fetchByNomorWo(int nomorWo) async {
    try {
      final response = await _supabase
          .from(_table)
          .select()
          .eq('nomor_wo', nomorWo)
          .order('created_at', ascending: true);

      return response.map((json) => InvoiceItem.fromJson(json)).toList();
    } catch (e) {
      print('ERROR fetchByNomorWo: $e');
      return [];
    }
  }

  /// Menambahkan invoice item baru
  Future<InvoiceItem?> insertInvoice({
    required int nomorWo,
    required String namaPekerjaan,
    required int harga,
  }) async {
    try {
      final response = await _supabase
          .from(_table)
          .insert({
            'nomor_wo': nomorWo,
            'nama_pekerjaan': namaPekerjaan,
            'harga': harga,
          })
          .select()
          .single();

      return InvoiceItem.fromJson(response);
    } catch (e) {
      print('ERROR insertInvoice: $e');
      return null;
    }
  }

  /// Mengubah nama atau harga invoice item berdasarkan id
  Future<bool> updateInvoice({
    required String id,
    required String namaBaru,
    required int hargaBaru,
  }) async {
    try {
      await _supabase.from(_table).update({
        'nama_pekerjaan': namaBaru,
        'harga': hargaBaru,
      }).eq('id', id);
      return true;
    } catch (e) {
      print('ERROR updateInvoice: $e');
      return false;
    }
  }

  /// Menghapus invoice item berdasarkan id
  Future<bool> deleteInvoice(String id) async {
    try {
      await _supabase.from(_table).delete().eq('id', id);
      return true;
    } catch (e) {
      print('ERROR deleteInvoice: $e');
      return false;
    }
  }
}
