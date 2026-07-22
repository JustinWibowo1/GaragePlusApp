import 'package:flutter/material.dart';
import '../../component/app_animations.dart';
import '../../models/service_details_models.dart';
import '../../models/customer_models.dart';
import '../../viewModel/order_detail/order_detail_viewmodel.dart';
import '../../services/pdf_printer_service.dart';
import 'package:intl/intl.dart';
import '../../component/app_colors.dart';
import '../widgets/car_information_card.dart';
import '../widgets/tabel_pekerjaan.dart';
import '../dialogs/work_order_dialogs.dart';
import '../../viewModel/order_detail/invoice_viewmodel.dart';
import '../../viewModel/order_detail/pemeriksaan_viewmodel.dart';
import '../dialogs/status_popup.dart';
import '../../viewModel/order_detail/service_reminder_viewmodel.dart';
import '../widgets/tabel_invoice.dart';

class OrderItemDetailScreen extends StatefulWidget {
  final OrderDetailViewModel vm;
  final ServiceReminderViewModel reminderVm;
  final int nomorWo;
  final DateTime tanggal;
  final Customer customer;

  const OrderItemDetailScreen({
    Key? key,
    required this.vm,
    required this.reminderVm,
    required this.nomorWo,
    required this.tanggal,
    required this.customer,
  }) : super(key: key);

  @override
  State<OrderItemDetailScreen> createState() => _OrderItemDetailScreenState();
}

class _OrderItemDetailScreenState extends State<OrderItemDetailScreen> {
  bool _isCetakLoading = false;
  final _invoiceVm = InvoiceViewModel();
  final _pemeriksaanVm = PemeriksaanViewModel();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.vm.muatDetail(widget.nomorWo);
      _invoiceVm.muatInvoice(widget.nomorWo);
      _pemeriksaanVm.muatPemeriksaan(widget.nomorWo);
    });
  }

  String get _nomorWoDisplay =>
      'WO-${widget.tanggal.year}-${widget.nomorWo.toString().padLeft(4, '0')}';

  String _getOdometer() {
    return '${NumberFormat('#,###').format(widget.reminderVm.kmTerakhir)} km';
  }

  Future<void> _handleCetakWO({bool isFinalisasi = false}) async {
    final order = widget.vm.daftarOrder.firstWhere(
      (o) => o.nomorWo == widget.nomorWo,
    );

    Map<String, String> formResult = {};



    setState(() => _isCetakLoading = true);

    try {
      final pdfBytes = await widget.vm.generatePdfBytes(
        nomorWo: widget.nomorWo,
        customer: widget.customer,
        dataPemeriksaan: _pemeriksaanVm.dataPemeriksaan,
        formResult: formResult,
      );
      
      if (pdfBytes == null) {
        throw Exception('Gagal membuat file PDF');
      }

      if (!context.mounted) return;

      // 2. Tampilkan preview — user bisa cek sebelum konfirmasi
      final dikonfirmasi = await PdfPrinterService.showPreviewWithConfirm(
        context,
        pdfBytes,
        sudahSelesai: order.status == 'Selesai',
      );

      if (!context.mounted) return;

      // 3. Hanya finalisasi jika user menekan "Konfirmasi & Simpan"
      if (dikonfirmasi == true && order.status != 'Selesai') {
        final success = await widget.vm.finalisasiOrder(
          widget.nomorWo,
          completedAt: DateTime.now(), // Waktu keluar dicatat HANYA jika dikonfirmasi
        );
        if (!success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠️ Gagal menyimpan status Selesai'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }
        // Kembali ke halaman sebelumnya setelah dikonfirmasi
        if (context.mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuat PDF: $e'),
          backgroundColor: AppColors.urgentBg,
        ),
      );
    } finally {
      if (mounted) setState(() => _isCetakLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundAlt,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Center(
          child: AppAnimatedBackButton(onTap: () => Navigator.pop(context)),
        ),
      ),
      body: ListenableBuilder(
        listenable: widget.vm,
        builder: (context, _) {
          if (widget.vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final isCompleted =
              widget.vm.progress == 1.0 && widget.vm.totalItem > 0;
          final bool isHistory = () {
            try {
              final order = widget.vm.daftarOrder.firstWhere(
                (o) => o.nomorWo == widget.nomorWo,
              );
              return order.status == 'Selesai';
            } catch (_) {
              return false;
            }
          }();
          final isSemuaItemSelesai = widget.vm.totalItem > 0 &&
              widget.vm.daftarDetail
                  .every((d) => d.status == StatusItem.selesai);

          return Stack(
            children: [
              SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header ──────────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Service Order #$_nomorWoDisplay',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.navy,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isCompleted
                                          ? AppColors.border
                                          : AppColors.blueChipBg,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      isCompleted ? 'COMPLETED' : 'IN PROGRESS',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: isCompleted
                                            ? AppColors.greyCompleted
                                            : AppColors.primaryBlue,
                                      ),
                                    ),
                                  ),
                                  if (isHistory) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.greyCompleted
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                            color: AppColors.greyCompleted),
                                      ),
                                      child: const Text(
                                        'READ-ONLY (HISTORY)',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.greyCompleted,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                widget.customer.namaPemilik,
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.navy),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.directions_car,
                                      size: 16, color: Colors.blue),
                                  const SizedBox(width: 8),
                                  Text(
                                    widget.customer.nomorPolisi,
                                    style: const TextStyle(
                                        fontSize: 15,
                                        color: AppColors.navy,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            OutlinedButton.icon(
                              icon: _isCetakLoading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2))
                                  : const Icon(Icons.print, size: 16),
                              label: const Text('Print PDF'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.navy,
                                side: const BorderSide(color: AppColors.border),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: (widget.vm.daftarDetail.isEmpty ||
                                      _isCetakLoading)
                                  ? null
                                  : () => _handleCetakWO(isFinalisasi: false),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // ── Vehicle Passport Card ───────────────────────────
                    VehiclePassportCard(
                      merkMobil: widget.customer.jenisMobil,
                      typeMobil: widget.customer.tipeMobil,
                      nomorPolisi: widget.customer.nomorPolisi,
                      noRangka: widget.customer.nomorRangka,
                      noMesin: widget.customer.nomorMesin,
                      odometer: _getOdometer(),
                      progress: widget.vm.progress,
                      totalItem: widget.vm.totalItem,
                      isCompleted: isCompleted,
                    ),
                    const SizedBox(height: 40),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Pekerjaan yang harus dilakukan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        if (!isHistory)
                          Row(
                            children: [
                              ElevatedButton.icon(
                                icon: const Icon(Icons.assignment_turned_in_outlined, size: 16),
                                label: const Text('Pemeriksaan Umum'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.primaryBlue,
                                  side: const BorderSide(color: AppColors.primaryBlue),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () async {
                                  final res = await WorkOrderDialogs.showCetakWorkOrderDialog(
                                    context,
                                    prefill: _pemeriksaanVm.dataPemeriksaan,
                                  );
                                  if (res != null && context.mounted) {
                                    // Panggil ViewModel untuk memproses data mentah (MVVM)
                                    final sukses = await _pemeriksaanVm.prosesDanSimpanForm(widget.nomorWo, res);
                                    
                                    if (context.mounted) {
                                      if (sukses) {
                                        await StatusPopup.show(
                                          context,
                                          isSuccess: true,
                                          message: 'Pemeriksaan berhasil disimpan',
                                        );
                                      } else {
                                        await StatusPopup.show(
                                          context,
                                          isSuccess: false,
                                          message: _pemeriksaanVm.errorMessage ?? 'Gagal menyimpan pemeriksaan',
                                        );
                                      }
                                    }
                                  }
                                },
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text('Tambah Pekerjaan / Part'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.navy,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () async {
                                  await widget.vm.showTambahPekerjaanSheetUI(context, widget.nomorWo);
                                  if (context.mounted) {
                                    _invoiceVm.muatInvoice(widget.nomorWo);
                                  }
                                },
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TaskLedgerTable(
                      vm: widget.vm,
                      daftarDetail: widget.vm.daftarDetail,
                      isHistory: isHistory,
                    ),
                    const SizedBox(height: 32),
                    
                    // ── Invoice Section ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Invoice Mobil',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        if (!isHistory)
                          TextButton.icon(
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Tambah Invoice'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primaryBlue,
                            ),
                            onPressed: () => _invoiceVm.showTambahInvoiceDialog(context, widget.nomorWo),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ListenableBuilder(
                      listenable: _invoiceVm,
                      builder: (context, _) {
                        if (_invoiceVm.isLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        return TabelInvoice(
                          vm: _invoiceVm,
                          daftarInvoice: _invoiceVm.daftarInvoice,
                          isHistory: isHistory,
                        );
                      },
                    ),

                    const SizedBox(
                        height: 100), // Ruang ekstra untuk tombol finalisasi
                  ],
                ),
              ),

              // ── Floating Tombol Finalisasi ──────────────────────
              if (isSemuaItemSelesai && !isHistory)
                Positioned(
                  bottom: 24,
                  left: 24,
                  right: 24,
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.green.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _isCetakLoading ? null : () => _handleCetakWO(isFinalisasi: true),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isCetakLoading)
                            const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 3))
                          else
                            const Icon(Icons.check_circle_outline, size: 28),
                          const SizedBox(width: 12),
                          const Text(
                            'FINALISASI & CETAK WO',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
