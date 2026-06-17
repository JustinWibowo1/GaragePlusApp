import 'package:flutter/material.dart';
import '../../app_animations.dart';
import '../../models/service_details_models.dart';
import '../../viewModel/order_detail_viewmodel.dart';
import '../../services/pdf_printer_service.dart';
import '../../services/work_order_filler.dart';
import 'package:intl/intl.dart';
import '../../app_colors.dart';

class OrderItemDetailScreen extends StatefulWidget {
  final OrderDetailViewModel vm;
  final int nomorWo;
  final String nomorPolisi;
  final String namaPemilik;
  final DateTime tanggal;
  final String telepon;
  final String alamat;
  final String merkMobil;
  final String typeMobil;
  final String tahun;
  final String noRangka;
  final String noMesin;

  const OrderItemDetailScreen({
    Key? key,
    required this.vm,
    required this.nomorWo,
    required this.nomorPolisi,
    required this.namaPemilik,
    required this.tanggal,
    this.telepon = '',
    this.alamat = '',
    this.merkMobil = '',
    this.typeMobil = '',
    this.tahun = '',
    this.noRangka = '',
    this.noMesin = '',
  }) : super(key: key);

  @override
  State<OrderItemDetailScreen> createState() => _OrderItemDetailScreenState();
}

class _OrderItemDetailScreenState extends State<OrderItemDetailScreen> {
  bool _isCetakLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.vm.muatDetail(widget.nomorWo);
    });
  }

  String _formatDate(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  String get _nomorWoDisplay =>
      'WO-${widget.tanggal.year}-${widget.nomorWo.toString().padLeft(4, '0')}';

  String _getOdometer() {
    return '${NumberFormat('#,###').format(widget.vm.kmTerakhir)} km';
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

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Customer: ${widget.namaPemilik}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          icon: const Icon(Icons.bug_report, size: 16),
                          label: const Text('Debug PDF'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.redAccent),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () async {
                            final bytes = await WorkOrderFiller.debugFillFieldNames();
                            if (!context.mounted) return;
                            PdfPrinterService.showPreview(context, bytes);
                          },
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          icon: _isCetakLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2))
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
                              : () => _showCetakWorkOrderDialog(context),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // ── Vehicle Passport Card ───────────────────────────
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Detail Kendaraan',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textGrey,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${widget.merkMobil} ${widget.typeMobil}'
                                        .trim()
                                        .isEmpty
                                    ? widget.nomorPolisi
                                    : '${widget.merkMobil} ${widget.typeMobil}',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryBlue,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                      child: _buildInfoItem(
                                          'Nomor Rangka',
                                          widget.noRangka.isEmpty
                                              ? '-'
                                              : widget.noRangka)),
                                  Expanded(
                                      child: _buildInfoItem(
                                          'Nomor Mesin',
                                          widget.noMesin.isEmpty
                                              ? '-'
                                              : widget.noMesin)),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                      child: _buildInfoItem(
                                          'Nomor Polisi', widget.nomorPolisi)),
                                  Expanded(
                                      child: _buildInfoItem(
                                          'Kilometer', _getOdometer())),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Divider
                      Container(width: 1, height: 180, color: AppColors.border),
                      // Health Status
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 120,
                                height: 120,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    CircularProgressIndicator(
                                      value: widget.vm.totalItem == 0
                                          ? 0
                                          : widget.vm.progress,
                                      strokeWidth: 10,
                                      backgroundColor: AppColors.chipBg,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        isCompleted
                                            ? AppColors.green
                                            : AppColors.primaryBlue,
                                      ),
                                    ),
                                    Center(
                                      child: Text(
                                        '${(widget.vm.progress * 100).toInt()}%',
                                        style: const TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.navy,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Progress Pekerjaan',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.navy,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isCompleted
                                      ? AppColors.greenBg
                                      : AppColors.urgentBg,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  isCompleted ? 'Selesai' : 'Dalam pengerjaan',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: isCompleted
                                        ? AppColors.greenBadgeDark
                                        : AppColors.urgentText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // ── Professional Task Ledger ─────────────────────────
                const Text(
                  'Pekerjaan yang harus dilakukan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      // Table Header
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        decoration: const BoxDecoration(
                          color: AppColors.backgroundAlt,
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(8)),
                          border: Border(
                              bottom: BorderSide(color: AppColors.border)),
                        ),
                        child: const Row(
                          children: [
                            Expanded(
                                flex: 3,
                                child: _TableHeaderText('Detail Pekerjaan')),
                            Expanded(
                                flex: 2, child: _TableHeaderText('Kategori')),
                            Expanded(
                                flex: 2, child: _TableHeaderText('Status')),
                            Expanded(
                                flex: 3,
                                child: _TableHeaderText('Catatan Teknisi')),
                          ],
                        ),
                      ),
                      // Table Rows
                      if (widget.vm.daftarDetail.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(
                            child: Text('Tidak ada task detail.',
                                style: TextStyle(color: AppColors.textGrey)),
                          ),
                        ),
                      ...widget.vm.daftarDetail.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        final isLast =
                            index == widget.vm.daftarDetail.length - 1;

                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                          decoration: BoxDecoration(
                            border: isLast
                                ? null
                                : const Border(
                                    bottom:
                                        BorderSide(color: AppColors.border)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Task Details
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.namaPekerjaan ?? '-',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.navy,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.status == StatusItem.selesai
                                          ? 'Completed at ${_formatDate(item.createdAt)}'
                                          : 'Added at ${_formatDate(item.createdAt)}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Category
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.kodePekerjaan ?? 'General',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Status
                              Expanded(
                                flex: 2,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: GestureDetector(
                                    onTap: () =>
                                        _showUbahStatusDialog(context, item),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: item.status == StatusItem.selesai
                                            ? AppColors.primaryBlue
                                            : (item.status ==
                                                    StatusItem.dikerjakan
                                                ? AppColors.amber
                                                : AppColors.textGrey),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        item.status == StatusItem.selesai
                                            ? 'COMPLETED'
                                            : item.status.label.toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Technical Notes
                              Expanded(
                                flex: 3,
                                child: Text(
                                  (item.catatanTeknisi == null ||
                                          item.catatanTeknisi!.isEmpty)
                                      ? '-'
                                      : item.catatanTeknisi!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textDark,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: AppColors.textGrey,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }

  void _showUbahStatusDialog(BuildContext context, OrderServiceDetail item) {
    final catatanController =
        TextEditingController(text: item.catatanTeknisi ?? '');
    final statusBaru = item.status == StatusItem.menunggu
        ? StatusItem.dikerjakan
        : StatusItem.selesai;

    final isSelesai = statusBaru == StatusItem.selesai;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) {
          final catatanKosong = catatanController.text.trim().isEmpty;
          final tombolDisabled = isSelesai && catatanKosong;

          return AlertDialog(
            backgroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Text('${statusBaru.emoji} Tandai ${statusBaru.label}?'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.namaPekerjaan ?? '',
                    style: const TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                if (isSelesai) ...[
                  const Text(
                    'Apa yang dikerjakan mekanik? *',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                TextField(
                  controller: catatanController,
                  maxLines: 3,
                  onChanged: (_) => setS(() {}),
                  decoration: InputDecoration(
                    hintText: isSelesai
                        ? 'Contoh: Ganti oli mesin 4L Shell Helix, filter oli diganti...'
                        : 'Technical notes (opsional)...',
                    hintStyle: const TextStyle(fontSize: 12),
                    filled: true,
                    fillColor: AppColors.backgroundAlt,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: isSelesai && catatanKosong
                          ? const BorderSide(color: Colors.red, width: 1.5)
                          : BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: isSelesai && catatanKosong
                          ? const BorderSide(color: Colors.red, width: 1.5)
                          : BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: isSelesai && catatanKosong
                            ? Colors.red
                            : AppColors.primaryBlue,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                if (isSelesai && catatanKosong) ...[
                  const SizedBox(height: 6),
                  const Text(
                    '⚠️ Wajib diisi sebelum menandai selesai',
                    style: TextStyle(fontSize: 11, color: Colors.red),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal')),
              ElevatedButton(
                onPressed: tombolDisabled
                    ? null
                    : () {
                        widget.vm.ubahStatusItem(
                            detailId: item.id,
                            statusBaru: statusBaru,
                            catatan: catatanController.text.trim());
                        Navigator.pop(context);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: tombolDisabled
                      ? Colors.grey.shade300
                      : AppColors.primaryBlue,
                  foregroundColor:
                      tombolDisabled ? Colors.grey : Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('Tandai ${statusBaru.label}'),
              ),
            ],
          );
        },
      ),
    );
  }


  // ── Dialog input data pemeriksaan sebelum cetak WO ──────────────────
  Future<void> _showCetakWorkOrderDialog(BuildContext context) async {
    final cBatteryAwal = TextEditingController();
    final cBatteryStater = TextEditingController();
    final cBatteryPengisian = TextEditingController();
    final cTekananDepan = TextEditingController();
    final cTekananBelakang = TextEditingController();
    final cTekananCadangan = TextEditingController();
    final cTorsiMur = TextEditingController();
    final cServiceKm = TextEditingController();
    final cServiceBulan = TextEditingController();
    final cCatatan = TextEditingController();

    String batteryStatus = 'Normal';
    String oliMesin = 'cukup';
    String oliMatik = 'X';
    String coolant = 'cukup';
    String oliRemKopling = 'cukup';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.description_outlined, color: AppColors.greenDark),
              SizedBox(width: 8),
              Text('Data Pemeriksaan WO',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Battery ──────────────────────────────
                  _dialogSection('🔋 Battery'),
                  Row(
                    children: [
                      Expanded(
                          child: _dialogTextField(cBatteryAwal, 'Awal (V)')),
                      const SizedBox(width: 8),
                      Expanded(
                          child:
                              _dialogTextField(cBatteryStater, 'Stater (V)')),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _dialogTextField(
                              cBatteryPengisian, 'Pengisian (V)')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _dialogDropdown(
                    'Status Battery',
                    batteryStatus,
                    ['Normal', 'kurang baik', 'waktunya diganti'],
                    (v) => setS(() => batteryStatus = v!),
                  ),
                  const SizedBox(height: 12),

                  // ── Oli & Cairan ─────────────────────────
                  _dialogSection('🛢️ Oli & Cairan'),
                  _dialogDropdown(
                      'Oli Mesin',
                      oliMesin,
                      ['cukup', 'kurang', 'minimal', 'X'],
                      (v) => setS(() => oliMesin = v!)),
                  const SizedBox(height: 6),
                  _dialogDropdown(
                      'Oli Matik',
                      oliMatik,
                      ['cukup', 'kurang', 'minimal', 'X'],
                      (v) => setS(() => oliMatik = v!)),
                  const SizedBox(height: 6),
                  _dialogDropdown(
                      'Coolant',
                      coolant,
                      ['cukup', 'kurang', 'minimal'],
                      (v) => setS(() => coolant = v!)),
                  const SizedBox(height: 6),
                  _dialogDropdown(
                      'Oli Rem & Kopling',
                      oliRemKopling,
                      ['cukup', 'kurang', 'minimal'],
                      (v) => setS(() => oliRemKopling = v!)),
                  const SizedBox(height: 12),

                  // ── Tekanan Ban ──────────────────────────
                  _dialogSection('🚗 Tekanan Ban (psi)'),
                  Row(
                    children: [
                      Expanded(child: _dialogTextField(cTekananDepan, 'Depan')),
                      const SizedBox(width: 8),
                      Expanded(
                          child:
                              _dialogTextField(cTekananBelakang, 'Belakang')),
                      const SizedBox(width: 8),
                      Expanded(
                          child:
                              _dialogTextField(cTekananCadangan, 'Cadangan')),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Torsi & Service Berikut ──────────────
                  _dialogSection('🔧 Lain-lain'),
                  _dialogTextField(cTorsiMur, 'Torsi Mur (kg-m)'),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                          child: _dialogTextField(
                              cServiceKm, 'Service berikut KM')),
                      const SizedBox(width: 8),
                      Expanded(child: _dialogTextField(cServiceBulan, 'Bulan')),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _dialogTextField(cCatatan, 'Catatan / Saran Tambahan',
                      maxLines: 3),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.print, size: 16),
              label: const Text('Cetak WO'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.greenDark,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Navigator.pop(ctx, true),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true || !context.mounted) return;

    setState(() => _isCetakLoading = true);

    try {
      final order = widget.vm.daftarOrder.firstWhere(
        (o) => o.nomorWo == widget.nomorWo,
      );
      final details = widget.vm.daftarDetail;

      final pdfBytes = await WorkOrderFiller.fill(
        order: order,
        details: details,
        namaPemilik: widget.namaPemilik,
        nomorPolisi: widget.nomorPolisi,
        telepon: widget.telepon,
        alamat: widget.alamat,
        merkMobil: widget.merkMobil,
        typeMobil: widget.typeMobil,
        tahun: widget.tahun,
        noRangka: widget.noRangka,
        noMesin: widget.noMesin,
        batteryAwal: cBatteryAwal.text,
        batteryStater: cBatteryStater.text,
        batteryPengisian: cBatteryPengisian.text,
        batteryStatus: batteryStatus,
        oliMesin: oliMesin,
        oliMatik: oliMatik,
        coolant: coolant,
        oliRemKopling: oliRemKopling,
        tekananDepan: cTekananDepan.text,
        tekananBelakang: cTekananBelakang.text,
        tekananCadangan: cTekananCadangan.text,
        torsiMur: cTorsiMur.text,
        serviceKm: cServiceKm.text,
        serviceBulan: cServiceBulan.text,
        catatanTambahan: cCatatan.text,
      );

      if (!context.mounted) return;
      PdfPrinterService.showPreview(context, pdfBytes);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuat Work Order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isCetakLoading = false);
    }
  }

  static Widget _dialogSection(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: AppColors.greenDark,
            )),
      );

  static Widget _dialogTextField(
    TextEditingController ctrl,
    String hint, {
    int maxLines = 1,
  }) =>
      TextField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType:
            maxLines == 1 ? TextInputType.text : TextInputType.multiline,
        decoration: InputDecoration(
          hintText: hint,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      );

  static Widget _dialogDropdown(
    String label,
    String value,
    List<String> options,
    void Function(String?) onChanged,
  ) =>
      Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: value,
              isDense: true,
              decoration: InputDecoration(
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              items: options
                  .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      );
}

class _TableHeaderText extends StatelessWidget {
  final String text;
  const _TableHeaderText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: AppColors.textGrey,
        letterSpacing: 1.0,
      ),
    );
  }
}
