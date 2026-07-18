import 'package:flutter/material.dart';
import '../../app_animations.dart';
import '../../models/service_details_models.dart';
import '../../models/customer_models.dart';
import '../../models/pemeriksaan_wo_models.dart';
import '../../viewModel/order_detail_viewmodel.dart';
import '../../services/pdf_printer_service.dart';
import '../../services/work_order_filler.dart';
import 'package:intl/intl.dart';
import '../../app_colors.dart';
import '../widgets/car_information_card.dart';
import '../widgets/tabel_pekerjaan.dart';
import '../dialogs/work_order_dialogs.dart';
import '../../viewModel/invoice_viewmodel.dart';
import '../widgets/tabel_invoice.dart';

class OrderItemDetailScreen extends StatefulWidget {
  final OrderDetailViewModel vm;
  final int nomorWo;
  final DateTime tanggal;
  final Customer customer;

  const OrderItemDetailScreen({
    Key? key,
    required this.vm,
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.vm.muatDetail(widget.nomorWo);
      _invoiceVm.muatInvoice(widget.nomorWo);
    });
  }

  String get _nomorWoDisplay =>
      'WO-${widget.tanggal.year}-${widget.nomorWo.toString().padLeft(4, '0')}';

  String _getOdometer() {
    return '${NumberFormat('#,###').format(widget.vm.kmTerakhir)} km';
  }

  Future<void> _handleCetakWO({bool isFinalisasi = false}) async {
    final order = widget.vm.daftarOrder.firstWhere(
      (o) => o.nomorWo == widget.nomorWo,
    );

    Map<String, String> formResult = {};

    if (isFinalisasi) {
      final res = await WorkOrderDialogs.showCetakWorkOrderDialog(
        context,
        prefill: widget.vm.dataPemeriksaan, // auto-fill dari data sebelumnya
      );
      if (res == null || !context.mounted) return;
      formResult = res;

      // Simpan data pemeriksaan ke database
      final pemeriksaanBaru = PemeriksaanWO(
        id             : widget.vm.dataPemeriksaan?.id ?? '',
        nomorWo        : widget.nomorWo,
        batteryAwal    : double.tryParse(formResult['batteryAwal'] ?? ''),
        batteryStater  : double.tryParse(formResult['batteryStater'] ?? ''),
        batteryPengisian: double.tryParse(formResult['batteryPengisian'] ?? ''),
        batteryStatus  : formResult['batteryStatus'],
        oliMesin       : formResult['oliMesin'],
        oliMatik       : formResult['oliMatik'],
        coolant        : formResult['coolant'],
        oliRemKopling  : formResult['oliRemKopling'],
        tekananDepan   : int.tryParse(formResult['tekananDepan'] ?? ''),
        tekananBelakang: int.tryParse(formResult['tekananBelakang'] ?? ''),
        tekananCadangan: int.tryParse(formResult['tekananCadangan'] ?? ''),
        torsiMur       : formResult['torsiMur'],
        serviceBerikutKm   : int.tryParse(formResult['serviceKm']?.replaceAll('.', '') ?? ''),
        serviceBerikutBulan: DateTime.tryParse(formResult['serviceBulan'] ?? ''),
        catatanTambahan: formResult['catatanTambahan'],
        namaMekanik    : formResult['namaMekanik'],
        namaForeman    : formResult['namaForeman'],
        createdAt      : widget.vm.dataPemeriksaan?.createdAt ?? DateTime.now(),
        updatedAt      : DateTime.now(),
      );
      await widget.vm.simpanPemeriksaan(pemeriksaanBaru);
    }

    setState(() => _isCetakLoading = true);

    try {
      final details = widget.vm.daftarDetail;
      final orderPreview = order;

      // dataPemeriksaan dari DB selalu menjadi fallback:
      // - Saat isFinalisasi: formResult jadi sumber utama, DB sebagai isian default jika form kosong
      // - Saat print biasa / history: formResult kosong {}, sehingga semua data dari DB
      final p = widget.vm.dataPemeriksaan;

      final Map<int, String> spTexts = {};
      for (int i = 0; i < details.length; i++) {
        final detail = details[i];
        final spList = widget.vm.sparepartMap[detail.id] ?? [];
        if (spList.isNotEmpty) {
          spTexts[i] = spList.map((s) => s.namaItemSnapshot).join(', ');
        }
      }

      final pdfBytes = await WorkOrderFiller.fill(
        order: orderPreview,
        details: details,
        sparepartTexts: spTexts,
        namaPemilik: widget.customer.namaPemilik,
        nomorPolisi: widget.customer.nomorPolisi,
        telepon: widget.customer.noTelepon ?? '',
        alamat: widget.customer.alamatLengkap,
        merkMobil: widget.customer.jenisMobil,
        typeMobil: widget.customer.tipeMobil,
        tahun: widget.customer.tahun.toString(),
        noRangka: widget.customer.nomorRangka,
        noMesin: widget.customer.nomorMesin,
        batteryAwal      : formResult['batteryAwal']      ?? p?.batteryAwal?.toString()      ?? '',
        batteryStater    : formResult['batteryStater']    ?? p?.batteryStater?.toString()    ?? '',
        batteryPengisian : formResult['batteryPengisian'] ?? p?.batteryPengisian?.toString() ?? '',
        batteryStatus    : formResult['batteryStatus']    ?? p?.batteryStatus                ?? 'Normal',
        oliMesin         : formResult['oliMesin']         ?? p?.oliMesin                     ?? 'Cukup',
        oliMatik         : formResult['oliMatik']         ?? p?.oliMatik                     ?? 'X',
        coolant          : formResult['coolant']          ?? p?.coolant                      ?? 'Cukup',
        oliRemKopling    : formResult['oliRemKopling']    ?? p?.oliRemKopling                ?? 'Cukup',
        tekananDepan     : formResult['tekananDepan']     ?? p?.tekananDepan?.toString()     ?? '',
        tekananBelakang  : formResult['tekananBelakang']  ?? p?.tekananBelakang?.toString()  ?? '',
        tekananCadangan  : formResult['tekananCadangan']  ?? p?.tekananCadangan?.toString()  ?? '',
        torsiMur         : formResult['torsiMur']         ?? p?.torsiMur?.toString()         ?? '',
        serviceKm        : formResult['serviceKm']        ?? p?.serviceBerikutKm?.toString() ?? '',
        serviceBulan     : (formResult['serviceBulan'] ?? (p?.serviceBerikutBulan != null ? "${p!.serviceBerikutBulan!.year}-${p.serviceBerikutBulan!.month.toString().padLeft(2, '0')}-${p.serviceBerikutBulan!.day.toString().padLeft(2, '0')}" : '')).replaceAll('-', '/'),
        catatanTambahan  : formResult['catatanTambahan']  ?? p?.catatanTambahan              ?? '',
        namaMekanik      : formResult['namaMekanik']      ?? p?.namaMekanik                  ?? '',
        namaForeman      : formResult['namaForeman']      ?? p?.namaForeman                  ?? '',
      );

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
                            onPressed: () => widget.vm.showTambahPekerjaanSheetUI(context, widget.nomorWo),
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
