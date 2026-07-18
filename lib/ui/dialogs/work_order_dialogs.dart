import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../component/app_colors.dart';
import '../../models/service_details_models.dart';
import '../../models/pemeriksaan_wo_models.dart';
import '../../viewModel/order_detail/order_detail_viewmodel.dart';
import '../../utils/formatters.dart';

class WorkOrderDialogs {
  // ── Dialog Ubah Status Pekerjaan ─────────────────────────────────────
  static Future<void> showUbahStatusDialog(BuildContext context,
      OrderDetailViewModel vm, OrderServiceDetail item) async {
    final catatanController =
        TextEditingController(text: item.catatanTeknisi ?? '');
    final statusBaru = item.status == StatusItem.menunggu
        ? StatusItem.dikerjakan
        : StatusItem.selesai;

    final isSelesai = statusBaru == StatusItem.selesai;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) {
          final catatanKosong = catatanController.text.trim().isEmpty;
          final tombolDisabled = isSelesai && catatanKosong;

          return AlertDialog(
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            title: Text('${statusBaru.emoji} Tandai ${statusBaru.label}?'),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.namaPekerjaan ?? '',
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w600)),
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
                    TextField(
                      controller: catatanController,
                      maxLines: 3,
                      onChanged: (v) => setS(() {}),
                      decoration: InputDecoration(
                        hintText:
                            'Misal: Baut oli aus, diakali dengan seal tape...',
                        hintStyle: TextStyle(
                            color: Colors.grey.shade400, fontSize: 13),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: AppColors.primaryBlue),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal',
                    style: TextStyle(color: Colors.black)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isSelesai ? AppColors.green : AppColors.amber,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                onPressed: tombolDisabled
                    ? null
                    : () {
                        Navigator.pop(ctx, {
                          'status': statusBaru,
                          'catatan': catatanController.text,
                        });
                      },
                child: Text(
                  'Ya, ${statusBaru.label}',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
      ),
    );

    if (result != null && context.mounted) {
      await vm.ubahStatusItem(
        nomorWo: item.nomorWo,
        detailId: item.id,
        statusBaru: result['status'],
        catatan: result['catatan'],
      );
    }
  }

  // ── Dialog Edit Harga ───────────────────────────────────────────────
  static Future<void> showEditHargaDialog(
      BuildContext context, OrderDetailViewModel vm, OrderServiceDetail item) async {
    final hargaAwal = item.hargaFinal.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    final hargaController = TextEditingController(text: hargaAwal);

    final result = await showDialog<int>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Edit Harga Final'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.namaPekerjaan ?? 'Pekerjaan',
                  style: const TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              const Text(
                'Harga Baru (Rp)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: hargaController,
                keyboardType: TextInputType.number,
                inputFormatters: [ThousandsSeparatorFormatter()],
                decoration: InputDecoration(
                  prefixText: 'Rp ',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primaryBlue),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              onPressed: () {
                final hargaBaru = int.tryParse(hargaController.text.replaceAll('.', '')) ?? 0;
                Navigator.pop(ctx, hargaBaru);
              },
              child: const Text(
                'Simpan',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (result != null && context.mounted) {
      await vm.ubahHargaPekerjaan(item.nomorWo, item.id, item.hargaFinal, result);
    }
  }

  // ── Dialog Hapus Pekerjaan ──────────────────────────────────────────
  static Future<void> showHapusPekerjaanDialog(
      BuildContext context, OrderDetailViewModel vm, OrderServiceDetail item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Hapus Pekerjaan?'),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${item.namaPekerjaan ?? 'pekerjaan ini'}"?\n\n'
          'Tindakan ini tidak dapat dibatalkan.',
          style: const TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await vm.hapusPekerjaan(item.nomorWo, item.id, item.hargaFinal);
    }
  }

  // ── Dialog input data pemeriksaan sebelum cetak WO ──────────────────
  /// [prefill]: data pemeriksaan sebelumnya dari DB (untuk auto-fill kolom).
  static Future<Map<String, String>?> showCetakWorkOrderDialog(
    BuildContext context, {
    PemeriksaanWO? prefill,
  }) async {
    final cBatteryAwal     = TextEditingController(text: prefill?.batteryAwal?.toString() ?? '');
    final cBatteryStater   = TextEditingController(text: prefill?.batteryStater?.toString() ?? '');
    final cBatteryPengisian= TextEditingController(text: prefill?.batteryPengisian?.toString() ?? '');
    final cTekananDepan    = TextEditingController(text: prefill?.tekananDepan?.toString() ?? '');
    final cTekananBelakang = TextEditingController(text: prefill?.tekananBelakang?.toString() ?? '');
    final cTekananCadangan = TextEditingController(text: prefill?.tekananCadangan?.toString() ?? '');
    final cTorsiMur        = TextEditingController(text: prefill?.torsiMur ?? '');
    final cServiceKm       = TextEditingController(
      text: prefill?.serviceBerikutKm != null 
          ? prefill!.serviceBerikutKm.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')
          : '',
    );
    
    String prefillBulan = '';
    if (prefill?.serviceBerikutBulan != null) {
      prefillBulan = "${prefill!.serviceBerikutBulan!.year}-${prefill.serviceBerikutBulan!.month.toString().padLeft(2, '0')}-${prefill.serviceBerikutBulan!.day.toString().padLeft(2, '0')}";
    }
    final cServiceBulan    = TextEditingController(text: prefillBulan);

    final cCatatan         = TextEditingController(text: prefill?.catatanTambahan ?? '');
    final cNamaMekanik     = TextEditingController(text: prefill?.namaMekanik ?? '');
    final cNamaForeman     = TextEditingController(text: prefill?.namaForeman ?? '');

    String batteryStatus = prefill?.batteryStatus ?? 'Normal';
    String oliMesin      = prefill?.oliMesin      ?? 'Cukup';
    String oliMatik      = prefill?.oliMatik      ?? 'Cukup';
    String coolant       = prefill?.coolant       ?? 'Cukup';
    String oliRemKopling = prefill?.oliRemKopling ?? 'Cukup';

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                      Expanded(child: _dialogTextField(cBatteryAwal, 'Awal (V)')),
                      const SizedBox(width: 8),
                      Expanded(child: _dialogTextField(cBatteryStater, 'Stater (V)')),
                      const SizedBox(width: 8),
                      Expanded(child: _dialogTextField(cBatteryPengisian, 'Pengisian (V)')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _dialogDropdown(
                    'Status Battery',
                    batteryStatus,
                    ['Normal', 'Kurang baik', 'Waktunya diganti'],
                    (v) => setS(() => batteryStatus = v!),
                  ),
                  const SizedBox(height: 12),

                  // ── Oli & Cairan ─────────────────────────
                  _dialogSection('🛢️ Oli & Cairan'),
                  _dialogDropdown('Oli Mesin', oliMesin, ['Cukup', 'Kurang', 'Minimal', 'X'],
                      (v) => setS(() => oliMesin = v!)),
                  const SizedBox(height: 6),
                  _dialogDropdown('Oli Matik', oliMatik, ['Cukup', 'Kurang', 'Minimal', 'X'],
                      (v) => setS(() => oliMatik = v!)),
                  const SizedBox(height: 6),
                  _dialogDropdown('Coolant', coolant, ['Cukup', 'Kurang', 'Minimal'],
                      (v) => setS(() => coolant = v!)),
                  const SizedBox(height: 6),
                  _dialogDropdown('Oli Rem & Kopling', oliRemKopling, ['Cukup', 'Kurang', 'Minimal'],
                      (v) => setS(() => oliRemKopling = v!)),
                  const SizedBox(height: 12),

                  // ── Tekanan Ban ──────────────────────────
                  _dialogSection('🚗 Tekanan Ban (psi)'),
                  Row(
                    children: [
                      Expanded(child: _dialogTextField(cTekananDepan, 'Depan')),
                      const SizedBox(width: 8),
                      Expanded(child: _dialogTextField(cTekananBelakang, 'Belakang')),
                      const SizedBox(width: 8),
                      Expanded(child: _dialogTextField(cTekananCadangan, 'Cadangan')),
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
                          cServiceKm,
                          'Service berikut KM',
                          keyboardType: TextInputType.number,
                          inputFormatters: [ThousandsSeparatorFormatter()],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: StatefulBuilder(
                          builder: (context, setStateBuilder) {
                            return InkWell(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: prefill?.serviceBerikutBulan ?? DateTime.now(),
                                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                                );
                                if (date != null) {
                                  cServiceBulan.text = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                                  setStateBuilder(() {});
                                }
                              },
                              child: IgnorePointer(
                                child: _dialogTextField(
                                  cServiceBulan,
                                  'Tgl Service (YYYY-MM-DD)',
                                ),
                              ),
                            );
                          }
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _dialogTextField(cCatatan, 'Catatan / Saran Tambahan', maxLines: 3),
                  const SizedBox(height: 12),
                  _dialogSection('👤 Personel'),
                  Row(
                    children: [
                      Expanded(child: _dialogTextField(cNamaMekanik, 'Nama Mekanik')),
                      const SizedBox(width: 8),
                      Expanded(child: _dialogTextField(cNamaForeman, 'Nama Foreman')),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, null),
              child: const Text('Batal'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.print, size: 16),
              label: const Text('Cetak WO'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.greenDark,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.pop(ctx, {
                  'batteryAwal': cBatteryAwal.text,
                  'batteryStater': cBatteryStater.text,
                  'batteryPengisian': cBatteryPengisian.text,
                  'batteryStatus': batteryStatus,
                  'oliMesin': oliMesin,
                  'oliMatik': oliMatik,
                  'coolant': coolant,
                  'oliRemKopling': oliRemKopling,
                  'tekananDepan': cTekananDepan.text,
                  'tekananBelakang': cTekananBelakang.text,
                  'tekananCadangan': cTekananCadangan.text,
                  'torsiMur': cTorsiMur.text,
                  'serviceKm': cServiceKm.text,
                  'serviceBulan': cServiceBulan.text,
                  'catatanTambahan': cCatatan.text,
                  'namaMekanik': cNamaMekanik.text,
                  'namaForeman': cNamaForeman.text,
                });
              },
            ),
          ],
        ),
      ),
    );

    return result;
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
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) =>
      TextField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboardType ?? (maxLines == 1 ? TextInputType.text : TextInputType.multiline),
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          hintText: hint,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
            child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: value,
              isDense: true,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
              items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      );
}

