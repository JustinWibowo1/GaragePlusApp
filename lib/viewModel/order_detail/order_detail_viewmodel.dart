import 'package:flutter/material.dart';
import '../../models/order_service_models.dart';
import '../../models/service_details_models.dart';
import '../../services/service_details_services.dart';
import '../../services/order_service_services.dart';
import '../../models/sparepart_service_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../ui/widgets/order_kerja/tambah_pekerjaan_sheet.dart';
import '../../component/app_colors.dart';

class OrderDetailViewModel extends ChangeNotifier {
  final _orderServiceDetailService = OrderServiceDetailServices();
  final _orderServiceService = OrderServiceServices();



  List<OrderServiceSummary> daftarOrder = [];
  List<OrderServiceDetail> daftarDetail = [];
  Map<String, List<SparepartService>> sparepartMap = {}; // Menampung sparepart per detail.id


  bool isLoading = false;
  String? errorMessage;

  int get totalItem => daftarDetail.length;
  int get itemSelesai =>
      daftarDetail.where((d) => d.status == StatusItem.selesai).length;
  double get progress => totalItem == 0 ? 0 : itemSelesai / totalItem;


  Future<void> muatOrderByCustomer(
    String customerId, {
    String tipeMesin = '',
    String tipeTransmisi = '',
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _orderServiceService.fetchOrderByCustomer(customerId),
      ]);

      daftarOrder = results[0];
    } catch (e) {
      errorMessage = 'Gagal memuat data: $e';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> _cekDanUpdateStatusOrder() async {
    if (daftarDetail.isEmpty) return;

    final semuaSelesai =
        daftarDetail.every((d) => d.status == StatusItem.selesai);
    final semuaMenunggu =
        daftarDetail.every((d) => d.status == StatusItem.menunggu);

    final String statusBaru;
    if (semuaMenunggu) {
      statusBaru = 'Menunggu';
    } else {
      statusBaru = 'Dikerjakan';
    }

    final nomorWo = daftarDetail.first.nomorWo;
    final orderIndex = daftarOrder.indexWhere((o) => o.nomorWo == nomorWo);
    final statusSekarang =
        orderIndex != -1 ? daftarOrder[orderIndex].status : null;

    if (statusSekarang == 'Selesai') return;

    if (statusSekarang != statusBaru) {
      await _orderServiceService.updateStatus(nomorWo, statusBaru);

      if (orderIndex != -1) {
        daftarOrder[orderIndex] =
            daftarOrder[orderIndex].copyWith(status: statusBaru);
      }
    }

    if (semuaSelesai &&
        orderIndex != -1 &&
        daftarOrder[orderIndex].status != 'Selesai') {}
  }

  Future<void> muatDetail(int nomorWo) async {
    isLoading = true;
    notifyListeners();
    try {
      // Muat detail pekerjaan
      final results = await Future.wait([
        _orderServiceDetailService.fetchDetailByNomorWo(nomorWo),
      ]);
      daftarDetail = results[0];

      // Load spareparts for these details
      sparepartMap.clear();
      if (daftarDetail.isNotEmpty) {
        final detailIds = daftarDetail.map((d) => d.id).toList();
        final spResponse = await Supabase.instance.client
            .from('sparepart_service')
            .select()
            .inFilter('order_service_detail_id', detailIds);
        
        for (var row in spResponse) {
          final sp = SparepartService.fromJson(row);
          sparepartMap.putIfAbsent(sp.orderServiceDetailId, () => []).add(sp);
        }
      }
    } catch (e) {
      errorMessage = 'Gagal memuat detail: $e';
    }

    isLoading = false;
    notifyListeners();
  }



  Future<void> ubahStatusItem({
    required int nomorWo,
    required String detailId,
    required StatusItem statusBaru,
    String? catatan,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final success = await _orderServiceDetailService.updateStatusItem(
        detailId: detailId,
        statusBaru: statusBaru,
        catatanTeknisi: catatan,
      );
      if (!success) {
        throw Exception('Gagal menyimpan perubahan ke server.');
      }
      await _cekDanUpdateStatusOrder();
      await muatDetail(nomorWo);
      return;
    } catch (e) {
      errorMessage = 'Gagal memperbarui status: $e';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> tambahPekerjaanBaru({
    required int nomorWo,
    required String orderKerjaId,
    required String namaPekerjaan,
    required int hargaFinal,
  }) async {
    try {
      final item = await _orderServiceDetailService.insertDetailItem(
        nomorWo: nomorWo,
        orderKerjaId: orderKerjaId,
        hargaFinal: hargaFinal,
      );
      if (item == null) throw Exception('Insert gagal');

      // Reassign list agar UI Flutter mendeteksi perubahan state
      daftarDetail = List.from(daftarDetail)..add(item);
      final orderIndex = daftarOrder.indexWhere((o) => o.nomorWo == nomorWo);
      if (orderIndex != -1) {
        final orderLama = daftarOrder[orderIndex];
        daftarOrder[orderIndex] = OrderServiceSummary(
          nomorWo: orderLama.nomorWo,
          customerId: orderLama.customerId,
          totalTagihan: orderLama.totalTagihan + hargaFinal,
          status: orderLama.status,
          kilometer: orderLama.kilometer,
          catatanKeluhan: orderLama.catatanKeluhan,
          tanggalMasuk: orderLama.tanggalMasuk,
          tanggalSelesai: DateTime.now(),
          completedAt: orderLama.completedAt,
          deletedAt: orderLama.deletedAt,
        );

        await _orderServiceService.updateTotalTagihan(
          nomorWo,
          orderLama.totalTagihan + hargaFinal,
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Gagal menambah pekerjaan: $e';
      notifyListeners();
      return false;
    }
  }

  /// Menampilkan popup penambahan pekerjaan baru dan memproses hasilnya (UI Logic)
  Future<void> showTambahPekerjaanSheetUI(BuildContext context, int nomorWo) async {
    final hasil = await TambahPekerjaanSheet.show(context);
    if (hasil == null || !context.mounted) return;
    
    final sukses = await tambahPekerjaanBaru(
      nomorWo      : nomorWo,
      orderKerjaId : hasil['id'] as String,
      namaPekerjaan: hasil['nama'] as String,
      hargaFinal   : hasil['hargaFinal'] as int,
    );
    
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(sukses
          ? '✅ "${hasil['nama']}" berhasil ditambahkan'
          : '⚠️ Gagal menambahkan pekerjaan'),
      backgroundColor: sukses ? AppColors.green : AppColors.urgentBg,
    ));
  }

  Future<bool> ubahHargaPekerjaan(
      int nomorWo, String detailId, int hargaLama, int hargaBaru) async {
    try {
      final success = await _orderServiceDetailService.updateHargaFinal(
        detailId: detailId,
        hargaBaru: hargaBaru,
      );
      if (!success) throw Exception('Update gagal');

      // Update local state
      final detailIndex = daftarDetail.indexWhere((d) => d.id == detailId);
      if (detailIndex != -1) {
        daftarDetail[detailIndex] = OrderServiceDetail(
          id: daftarDetail[detailIndex].id,
          nomorWo: daftarDetail[detailIndex].nomorWo,
          orderKerjaId: daftarDetail[detailIndex].orderKerjaId,
          hargaFinal: hargaBaru,
          status: daftarDetail[detailIndex].status,
          catatanTeknisi: daftarDetail[detailIndex].catatanTeknisi,
          createdAt: daftarDetail[detailIndex].createdAt,
          namaPekerjaan: daftarDetail[detailIndex].namaPekerjaan,
        );
      }

      // Update WO total tagihan
      final orderIndex = daftarOrder.indexWhere((o) => o.nomorWo == nomorWo);
      if (orderIndex != -1) {
        final orderLama = daftarOrder[orderIndex];
        final selisih = hargaBaru - hargaLama;
        final totalBaru = orderLama.totalTagihan + selisih;

        daftarOrder[orderIndex] = orderLama.copyWith(
          tanggalSelesai: DateTime.now(),
        );
        // Kita tidak bisa copyWith totalTagihan karena tidak ada parameter totalTagihan di copyWith OrderServiceSummary.
        // Kita assign ulang saja:
        daftarOrder[orderIndex] = OrderServiceSummary(
          nomorWo: orderLama.nomorWo,
          customerId: orderLama.customerId,
          totalTagihan: totalBaru,
          status: orderLama.status,
          kilometer: orderLama.kilometer,
          catatanKeluhan: orderLama.catatanKeluhan,
          tanggalMasuk: orderLama.tanggalMasuk,
          tanggalSelesai: DateTime.now(),
          completedAt: orderLama.completedAt,
          deletedAt: orderLama.deletedAt,
        );

        await _orderServiceService.updateTotalTagihan(nomorWo, totalBaru);
      }

      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Gagal mengubah harga: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> hapusPekerjaan(
      int nomorWo, String detailId, int hargaFinal) async {
    try {
      final success =
          await _orderServiceDetailService.hapusDetailItem(detailId);
      if (!success) throw Exception('Hapus gagal');

      // Update local state by reassigning list
      final newList = List<OrderServiceDetail>.from(daftarDetail);
      newList.removeWhere((d) => d.id == detailId);
      daftarDetail = newList;

      // Update WO total tagihan
      final orderIndex = daftarOrder.indexWhere((o) => o.nomorWo == nomorWo);
      if (orderIndex != -1) {
        final orderLama = daftarOrder[orderIndex];
        final totalBaru = orderLama.totalTagihan - hargaFinal;

        daftarOrder[orderIndex] = OrderServiceSummary(
          nomorWo: orderLama.nomorWo,
          customerId: orderLama.customerId,
          totalTagihan: totalBaru,
          status: orderLama.status,
          kilometer: orderLama.kilometer,
          catatanKeluhan: orderLama.catatanKeluhan,
          tanggalMasuk: orderLama.tanggalMasuk,
          tanggalSelesai: DateTime.now(),
          completedAt: orderLama.completedAt,
          deletedAt: orderLama.deletedAt,
        );

        await _orderServiceService.updateTotalTagihan(nomorWo, totalBaru);
      }

      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Gagal menghapus pekerjaan: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> finalisasiOrder(int nomorWo, {DateTime? completedAt}) async {
    final selesaiPada = completedAt ?? DateTime.now();
    try {
      final success = await _orderServiceService.updateStatusSelesai(
        nomorWo,
        completedAt: selesaiPada,
      );
      if (!success) throw Exception('Gagal update database');

      // Update local state agar UI langsung ter-refresh jadi Read-Only
      final index = daftarOrder.indexWhere((o) => o.nomorWo == nomorWo);
      if (index != -1) {
        daftarOrder[index] = daftarOrder[index].copyWith(
          status: 'Selesai',
          completedAt: selesaiPada,
          tanggalSelesai: selesaiPada,
        );
      }
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

}
