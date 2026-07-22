import 'package:flutter/material.dart';
import '../../../component/app_colors.dart';
import '../../../models/customer_models.dart';
import '../../../services/work_order_filler.dart';
import '../../../viewModel/order_kerja/order_kerja_viewmodel.dart';
import '../../../models/order_service_models.dart';
import '../../../models/service_details_models.dart';
import '../../dialogs/status_popup.dart';
import '../../../models/order_kerja_models.dart';
import 'order_kerja_preview_dialog.dart';

class OrderSummaryPanel extends StatelessWidget {
  final OrderKerjaViewModel vm;
  final Customer customer;
  final TextEditingController keluhanController;
  final TextEditingController kilometerController;

  const OrderSummaryPanel({
    super.key,
    required this.vm,
    required this.customer,
    required this.keluhanController,
    required this.kilometerController,
  });

  String _formatRupiah(int value) {
    return value.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  void _tampilDialogEditHarga(BuildContext context, OrderKerja jasa) {
    final TextEditingController hargaController = TextEditingController(
      text: (vm.hargaJasaCustom[jasa.id] ?? jasa.estimasiHarga).toString(),
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Harga: ${jasa.nama}'),
          content: TextField(
            controller: hargaController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Harga Jasa (Rp)',
              prefixText: 'Rp ',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                String rawText = hargaController.text;
                // Hanya sisakan angka, titik, dan koma
                String cleanText = rawText.replaceAll(RegExp(r'[^0-9.,]'), '');
                
                // Jika pengguna memakai titik sebagai pemisah ribuan (format Indonesia misal: 1.500.000)
                if (cleanText.contains('.') && cleanText.indexOf('.') != cleanText.lastIndexOf('.')) {
                  cleanText = cleanText.replaceAll('.', '');
                }
                
                // Jika formatnya 1.500 (satu titik dan bukan desimal 3 angka di belakang)
                // Ini sedikit tricky, tapi kita ganti saja koma jadi titik untuk standard double parsing
                if (cleanText.contains(',')) {
                  cleanText = cleanText.replaceAll('.', ''); // hilangkan titik ribuan jika ada
                  cleanText = cleanText.replaceAll(',', '.'); // jadikan koma sebagai desimal
                }

                final doublePrice = double.tryParse(cleanText);
                if (doublePrice != null) {
                  // Dibulatkan ke integer karena tipe datanya int di database
                  vm.setHargaJasaCustom(jasa, doublePrice.round());
                }
                Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListenableBuilder(
          listenable: vm,
          builder: (context, _) {
            final tgl = vm.tanggalMasukManual;
            final jam = vm.jamMasukManual;
            
            String textTgl = tgl != null 
                ? "${tgl.day.toString().padLeft(2, '0')}/${tgl.month.toString().padLeft(2, '0')}/${tgl.year}" 
                : "Tanggal Masuk (Otomatis)";
            String textJam = jam != null 
                ? "${jam.hour.toString().padLeft(2, '0')}:${jam.minute.toString().padLeft(2, '0')}" 
                : "Jam Masuk (Otomatis)";

            return Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Data Masuk Kendaraan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.navy)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: tgl ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              vm.setWaktuMasuk(date, jam);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 16, color: Colors.black54),
                                const SizedBox(width: 8),
                                Expanded(child: Text(textTgl, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: jam ?? TimeOfDay.now(),
                            );
                            if (time != null) {
                              vm.setWaktuMasuk(tgl ?? DateTime.now(), time);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time, size: 16, color: Colors.black54),
                                const SizedBox(width: 8),
                                Expanded(child: Text(textJam, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
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
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text('• ${jasa.nama}',
                                      style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500)),
                                ),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: () => _tampilDialogEditHarga(context, jasa),
                                  child: Row(
                                    children: [
                                      Text('Rp ${_formatRupiah(vm.hargaJasaCustom[jasa.id] ?? jasa.estimasiHarga)}',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13)),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.edit, size: 12, color: Colors.blueAccent),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // ── Tombol Hapus ──
                                SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    iconSize: 14,
                                    hoverColor: Colors.red.withOpacity(0.35),
                                    style: IconButton.styleFrom(
                                      backgroundColor:
                                          Colors.red.withOpacity(0.2),
                                      shape: const CircleBorder(),
                                    ),
                                    icon: const Icon(Icons.close,
                                        color: Colors.redAccent, size: 14),
                                    onPressed: () =>
                                        vm.hapusDariKeranjang(jasa),
                                  ),
                                ),
                              ],
                            ),
                            ...spareparts.map((sp) => Padding(
                                  padding:
                                      const EdgeInsets.only(left: 12, top: 4),
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
      await StatusPopup.show(
        context,
        isSuccess: false,
        message: 'Masukkan kilometer kendaraan terlebih dahulu',
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
      tanggalMasuk: now,
      tanggalSelesai: now,
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
      );
    }).toList();

    final Map<int, String> spTexts = {};
    for (int i = 0; i < vm.keranjangJasa.length; i++) {
      final jasa = vm.keranjangJasa[i];
      final spList = vm.sparepartPerPekerjaan[jasa.id] ?? [];
      if (spList.isNotEmpty) {
        spTexts[i] = spList.map((s) => s.sparepart.nama).join(', ');
      }
    }

    try {
      final pdfBytes = await WorkOrderFiller.fill(
        order: orderSummary,
        details: details,
        sparepartTexts: spTexts,
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
        await StatusPopup.show(
          context,
          isSuccess: true,
          message: 'Order berhasil disimpan!',
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      await StatusPopup.show(
        context,
        isSuccess: false,
        message: 'Gagal membuat PDF: $e',
      );
    }
  }
}
