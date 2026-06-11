import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../models/order_service_models.dart';
import '../models/service_details_models.dart';

class WorkOrderFiller {
  static const _bulan = [
    '',
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static String _tgl(DateTime d) => '${d.day} ${_bulan[d.month]} ${d.year}';
  static String _jam(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  static Future<Uint8List> debugFillFieldNames() async {
    final ByteData data = await rootBundle.load('asset/work_order.pdf');
    final PdfDocument document =
        PdfDocument(inputBytes: data.buffer.asUint8List());
    final PdfForm form = document.form;

    for (int i = 0; i < form.fields.count; i++) {
      final field = form.fields[i];
      if (field is PdfTextBoxField) {
        field.text = '[$i]${field.name}';
      }
    }

    form.flattenAllFields();
    final List<int> saved = await document.save();
    document.dispose();
    return Uint8List.fromList(saved);
  }

  static Future<Uint8List> fill({
    required OrderServiceSummary order,
    required List<OrderServiceDetail> details,
    required String namaPemilik,
    required String nomorPolisi,
    // Data kendaraan
    String telepon = '',
    String alamat = '',
    String merkMobil = '',
    String typeMobil = '',
    String tahun = '',
    String noRangka = '',
    String noMesin = '',
    // Pemeriksaan battery
    String batteryAwal = '',
    String batteryStater = '',
    String batteryPengisian = '',
    String batteryStatus = 'Normal',
    // Oli & cairan
    String oliMesin = 'cukup',
    String oliMatik = 'X',
    String coolant = 'cukup',
    String oliRemKopling = 'cukup',
    // Tekanan ban
    String tekananDepan = '',
    String tekananBelakang = '',
    String tekananCadangan = '',
    // Lain-lain
    String torsiMur = '',
    String serviceKm = '',
    String serviceBulan = '',
    String catatanTambahan = '',
  }) async {
    // ── 1. Load template PDF ──────────────────────────────────────────
    final ByteData data = await rootBundle.load('asset/work_order.pdf');
    final PdfDocument document =
        PdfDocument(inputBytes: data.buffer.asUint8List());
    final PdfForm form = document.form;

    // ── 2. Siapkan nilai-nilai ────────────────────────────────────────
    final km =
        '${order.kilometer.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} km';

    // Daftar pekerjaan bernomor
    final pekerjaanText = details.isEmpty
        ? '-'
        : details.asMap().entries.map((e) => '${e.key + 1}. ${e.value.namaPekerjaan ?? '-'}').join('\n');

    final pekerjaanTextDenganCatatan = details.isEmpty
        ? '-'
        : details.asMap().entries.map((e) {
            final nama = e.value.namaPekerjaan ?? '-';
            final cat = e.value.catatanTeknisi;
            if (cat != null && cat.trim().isNotEmpty) {
              return '${e.key + 1}. $nama (${cat.trim()})';
            }
            return '${e.key + 1}. $nama';
          }).join('\n');

    // Ringkasan oli & cairan dalam satu baris
    final oliText = [
      'Oli Mesin: $oliMesin',
      'Matik: $oliMatik',
      'Coolant: $coolant',
      'Rem/Kopling: $oliRemKopling',
    ].join('  |  ');

    // Kolom terakhir: gabungkan sisa data pemeriksaan
    final lastField = [
      if (torsiMur.isNotEmpty) 'Torsi: $torsiMur kg-m',
      if (serviceKm.isNotEmpty || serviceBulan.isNotEmpty)
        'Service berikut: $serviceKm km / $serviceBulan bln',
      if (catatanTambahan.isNotEmpty) catatanTambahan,
    ].join('  |  ');

    // ── 3. DEBUG: Lihat nilai sebelum mapping ──────────────────────────
    debugPrint('=== WorkOrderFiller DEBUG ===');
    debugPrint('namaPemilik   : $namaPemilik');
    debugPrint('nomorPolisi   : $nomorPolisi');
    debugPrint('telepon       : $telepon');
    debugPrint('alamat        : $alamat');
    debugPrint('merkMobil     : $merkMobil');
    debugPrint('typeMobil     : $typeMobil');
    debugPrint('tahun         : $tahun');
    debugPrint('noRangka      : $noRangka');
    debugPrint('noMesin       : $noMesin');
    debugPrint('km            : $km');
    debugPrint('WO Number     : ${order.nomorWoDisplay}');
    debugPrint('Tgl Masuk     : ${_tgl(order.createdAt)}');
    debugPrint('Keluhan       : ${order.catatanKeluhan}');
    debugPrint('Pekerjaan     : $pekerjaanText');
    debugPrint('=============================');

    // ── 4. Mapping index → nilai (sesuai urutan field di PDF) ─────────
    final Map<int, String> indexToValue = {
      23: order.nomorWoDisplay, // Text4  → WO Number
      0: namaPemilik, // Text6  → Nama Pemilik
      24: telepon, // Text7  → Telepon
      22: alamat, // Text8  → Alamat
      1: merkMobil, // Text9  → Merk Mobil
      4: typeMobil, // Text10 → Type
      7: tahun, // Text11 → Tahun
      9: nomorPolisi, // Text12 → No. Polisi
      2: noRangka, // Text13 → No. Rangka
      5: noMesin, // Text14 → No. Mesin
      10: km, // Text15 → KM
      3: _tgl(order.createdAt), // Text16 → Tgl Masuk
      6: _jam(order.createdAt), // Text17 → Jam Masuk
      8: order.completedAt != null // Text18 → Tgl Selesai
          ? _tgl(order.completedAt!)
          : '',
      11: order.completedAt != null // Text19 → Jam Selesai
          ? _jam(order.completedAt!)
          : '',
      12: order.catatanKeluhan, // [12] Text17 → Keluhan Pemilik
      13: pekerjaanText, // [13] Text18 → Order Kerja (tanpa catatan)
      14: pekerjaanTextDenganCatatan,
      15: lastField, // [14] Pekerjaan + Catatan

      // ── Pemeriksaan Battery (index 16-18) ────────────────────────────
      16: batteryAwal, // [14] Text19 → Battery Awal (V)
      17: batteryStater, // [15] Text20 → Battery Stater (V)
      18: batteryPengisian, // [16] Text21 → Battery Pengisian (V)

      // ── Tekanan Ban (index 19-21) ─────────────────────────────────────
      19: tekananDepan, // [19] Text24 → Tekanan Depan (psi)
      20: tekananBelakang, // [20] Text25 → Tekanan Belakang (psi)
      21: tekananCadangan, // [21] Text26 → Cadangan/Torsi/Service/Catatan
    };

    // ── 4. Isi field berdasarkan index ────────────────────────────────
    for (int i = 0; i < form.fields.count; i++) {
      final val = indexToValue[i] ?? '';
      if (val.isNotEmpty) {
        _setFieldValue(form.fields[i], val);
      }
    }

    // ── 5. Hapus border semua field agar kotak tidak terlihat ─────────
    for (int i = 0; i < form.fields.count; i++) {
      final field = form.fields[i];
      if (field is PdfTextBoxField) {
        field.borderColor = PdfColor(255, 255, 255, 0); // transparan
        field.backColor = PdfColor(255, 255, 255, 0); // transparan
      }
    }

    // ── 6. Flatten & save ─────────────────────────────────────────────
    form.flattenAllFields();
    final List<int> saved = await document.save();
    document.dispose();
    return Uint8List.fromList(saved);
  }

  static void _setFieldValue(PdfField field, String value) {
    if (field is PdfTextBoxField) {
      field.text = value;
    } else if (field is PdfComboBoxField) {
      try {
        field.selectedValue = value;
      } catch (_) {}
    } else if (field is PdfListBoxField) {
      try {
        field.selectedValues = [value];
      } catch (_) {}
    } else if (field is PdfRadioButtonListField) {
      try {
        field.selectedValue = value;
      } catch (_) {}
    } else if (field is PdfCheckBoxField) {
      field.isChecked =
          value.toLowerCase() == 'true' || value == '1' || value == 'ya';
    }
  }
}
