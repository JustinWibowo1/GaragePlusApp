import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/service_logistic_models.dart';

class DashboardService {
  final _supabase = Supabase.instance.client;

  Future<List<ServiceLogisticsItem>> fetchServiceLogistics() async {
    try {
      final response = await _supabase
          .from('order_service')
          .select('''
            nomor_wo,
            status,
            total_tagihan,
            created_at,
            customer (
              nama_pemilik,
              nomor_polisi,
              jenis_mobil,
              tipe_mobil
            ),
            order_service_detail (
              id,
              status,
              order_kerja (
                nama
              )
            )
          ''')
          .inFilter('status', ['Menunggu', 'Dikerjakan'])
          .order('created_at', ascending: false)
          .limit(8);

      return response.map((order) {
        final customer = order['customer'] as Map<String, dynamic>?;
        final details = order['order_service_detail'] as List<dynamic>? ?? [];

        final serviceNames = details
            .map<String>(
                (d) => d['order_kerja']?['nama'] as String? ?? '-')
            .toList();

        final totalItems = details.length;
        final completedItems =
            details.where((d) => d['status'] == 'Selesai').length;

        return ServiceLogisticsItem(
          nomorWo: order['nomor_wo'] as int,
          ownerName: customer?['nama_pemilik'] as String? ?? '-',
          licensePlate: customer?['nomor_polisi'] as String? ?? '-',
          vehicleName:
              '${customer?['jenis_mobil'] ?? ''} ${customer?['tipe_mobil'] ?? ''}'
                  .trim(),
          status: order['status'] as String? ?? 'Menunggu',
          totalBill: order['total_tagihan'] as int? ?? 0,
          tanggalMasuk: DateTime.parse(order['created_at'] as String),
          serviceNames: serviceNames,
          completedItems: completedItems,
          totalItems: totalItems,
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }
}
