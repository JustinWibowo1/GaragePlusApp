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
    final ByteData data = await rootBundle.load('asset/work_order-2.pdf');
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
    final ByteData data = await rootBundle.load('asset/work_order-2.pdf');
    final PdfDocument document =
        PdfDocument(inputBytes: data.buffer.asUint8List());
    final PdfForm form = document.form;
    final km =
        '${order.kilometer.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} km';

    // Hanya pekerjaan yang sudah diselesaikan mekanik
    final selesaiDetails = details
        .where((d) => d.status == StatusItem.selesai)
        .toList();

    final pekerjaanText = details.isEmpty
        ? '-'
        : details.asMap().entries.map((e) => '${e.key + 1}. ${e.value.namaPekerjaan ?? '-'}').join('\n');

    final pekerjaanTextDenganCatatan = selesaiDetails.isEmpty
        ? '-'
        : selesaiDetails.asMap().entries.map((e) {
            final cat = e.value.catatanTeknisi?.trim() ?? '-';
            return '${e.key + 1}. $cat';
          }).join('\n');

    // Ringkasan oli & cairan dalam satu baris
    // final oliText = [
    //   'Oli Mesin: $oliMesin',
    //   'Matik: $oliMatik',
    //   'Coolant: $coolant',
    //   'Rem/Kopling: $oliRemKopling',
    // ].join('  |  ');

    // Kolom terakhir: gabungkan sisa data pemeriksaan
    // final lastField = [
    //   if (torsiMur.isNotEmpty) 'Torsi: $torsiMur kg-m',
    //   if (serviceKm.isNotEmpty || serviceBulan.isNotEmpty)
    //     'Service berikut: $serviceKm km / $serviceBulan bln',
    //   if (catatanTambahan.isNotEmpty) catatanTambahan,
    // ].join('  |  ');

    // ── 4. Mapping index → nilai (sesuai urutan field di PDF) ─────────
    final Map<int, String> indexToValue = {
      16: order.nomorWoDisplay, 
      5: namaPemilik,
      13: telepon, 
      6: alamat, 
      7: merkMobil, 
      10: typeMobil, 
      14: tahun, 
      17: nomorPolisi, 
      8: noRangka, 
      11: noMesin,
      19: km, 
      9: _tgl(order.createdAt),
      12: _jam(order.createdAt),
      15: order.completedAt != null 
          ? _tgl(order.completedAt!)
          : '',
      18: order.completedAt != null
          ? _jam(order.completedAt!)
          : '',
      2: order.catatanKeluhan,
      3: pekerjaanText, 
      4: pekerjaanTextDenganCatatan,

      20: batteryAwal, 
      21: batteryStater, 
      22: batteryPengisian,
      23: tekananDepan, 
      24: tekananBelakang, 
      25: tekananCadangan,
    };

    for (int i = 0; i < form.fields.count; i++) {
      final val = indexToValue[i] ?? '';
      if (val.isNotEmpty) {
        _setFieldValue(form.fields[i], val);
      }
    }

    for (int i = 0; i < form.fields.count; i++) {
      final field = form.fields[i];
      if (field is PdfTextBoxField) {
        field.borderColor = PdfColor(255, 255, 255, 0);
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
      field.font = PdfStandardFont(PdfFontFamily.helvetica, 9);
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
