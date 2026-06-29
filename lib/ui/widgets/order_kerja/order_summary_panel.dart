import 'package:flutter/material.dart';
import '../../../app_colors.dart';
import '../../../models/customer_models.dart';
import '../../../viewModel/order_kerja_viewmodel.dart';
import '../../../models/order_service_models.dart';
import '../../../models/service_details_models.dart';
import '../../../services/work_order_filler.dart';
import 'order_kerja_preview_dialog.dart';

class OrderSummaryPanel extends StatelessWidget {
  final OrderKerjaViewModel vm;
  final Customer customer;
  final TextEditingController keluhanController;
  final TextEditingController kilometerController;

  const OrderSummaryPanel({
    Key? key,
    required this.vm,
    required this.customer,
    required this.keluhanController,
    required this.kilometerController,
  }) : super(key: key);

  String _formatRupiah(int value) {
    return value.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 80,
          width: double.infinity,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200)),
          child: const Center(child: Text('Area Teknisi')),
        ),
        const SizedBox(height: 24),
        ListenableBuilder(
          listenable: vm,
          builder: (context, child) {
            final keranjang = vm.keranjangJasa;

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  color: AppColors.navyDarkest,
                  borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ringkasan Order',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  if (keranjang.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Text('Belum ada jasa yang dipilih.',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontStyle: FontStyle.italic)),
                    ),
                  ...keranjang.map((jasa) {
                    final spareparts = vm.sparepartPerPekerjaan[jasa.id] ?? [];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                  child: Text('• ${jasa.nama}',
                                      style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 14))),
                              Text('Rp ${_formatRupiah(jasa.estimasiHarga)}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13)),
                            ],
                          ),
                          ...spareparts.map((sp) => Padding(
                                padding:
                                    const EdgeInsets.only(left: 16, top: 4),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        '↳ ${sp.sparepart.displayName} x${sp.qty}',
                                        style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.6),
                                            fontSize: 12)),
                                    Text('Rp ${_formatRupiah(sp.subtotal)}',
                                        style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.7),
                                            fontSize: 12)),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    );
                  }).toList(),
                  const Divider(color: Colors.white24, height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Estimasi',
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                      Text('Rp ${_formatRupiah(vm.totalEstimasi)}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: keranjang.isEmpty
                          ? null
                          : () => _handlePreviewAndSave(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        disabledBackgroundColor: Colors.white12,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Buat Order Kerja',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _handlePreviewAndSave(BuildContext context) async {
    if (vm.kilometer <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Masukkan kilometer kendaraan terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mempersiapkan preview...')),
    );

    final now = DateTime.now();

    final orderSummary = OrderServiceSummary(
      nomorWo: 0,
      customerId: customer.nomorRangka,
      totalTagihan: vm.totalEstimasi,
      status: 'Menunggu',
      kilometer: vm.kilometer == 0
          ? (int.tryParse(kilometerController.text.replaceAll('.', '')) ?? 0)
          : vm.kilometer,
      catatanKeluhan: keluhanController.text,
      createdAt: now,
      updatedAt: now,
    );

    final details = vm.keranjangJasa.map((jasa) {
      final sp = vm.sparepartPerPekerjaan[jasa.id] ?? [];
      final totalSp = sp.fold<int>(0, (s, e) => s + e.subtotal);
      return OrderServiceDetail(
        id: '',
        nomorWo: 0,
        orderKerjaId: jasa.id,
        hargaFinal: jasa.estimasiHarga + totalSp,
        status: StatusItem.menunggu,
        createdAt: now,
        namaPekerjaan: jasa.nama,
        kodePekerjaan: jasa.kode,
      );
    }).toList();

    try {
      final pdfBytes = await WorkOrderFiller.fill(
        order: orderSummary,
        details: details,
        namaPemilik: customer.namaPemilik,
        nomorPolisi: customer.nomorPolisi,
        telepon: customer.noTelepon ?? '',
        alamat: customer.alamatLengkap,
        merkMobil: customer.jenisMobil,
        typeMobil: customer.tipeMobil,
        tahun: customer.tahun.toString(),
        noRangka: customer.nomorRangka,
        noMesin: customer.nomorMesin,
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => OrderKerjaPreviewDialog(
          pdfBytes: pdfBytes,
          onConfirm: () async {
            return await vm.simpanOrderKerja(
              customerId: customer.nomorRangka,
              catatanKeluhan: keluhanController.text,
            );
          },
        ),
      );

      if (result == true && context.mounted) {
        keluhanController.clear();
        kilometerController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Order berhasil disimpan!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuat PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
