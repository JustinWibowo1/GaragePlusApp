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

  static String _tgl(DateTime d) {
    final local = d.toLocal();
    return '${local.day} ${_bulan[local.month]} ${local.year}';
  }

  static String _jam(DateTime d) {
    final local = d.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

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

  static Future<Uint8List> debugEstimasiFieldNames() async {
    final ByteData data = await rootBundle.load('asset/estimasi unt aplikasi.pdf-2.pdf');
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
    final selesaiDetails =
        details.where((d) => d.status == StatusItem.selesai).toList();

    final pekerjaanText = details.isEmpty
        ? ''
        : details
            .asMap()
            .entries
            .map((e) => '${e.key + 1}. ${e.value.namaPekerjaan ?? ''}')
            .join('\n');

    final pekerjaanTextDenganCatatan = selesaiDetails.isEmpty
        ? ''
        : selesaiDetails.asMap().entries.map((e) {
            final cat = e.value.catatanTeknisi?.trim() ?? '';
            return '${e.key + 1}. $cat';
          }).join('\n');

    // Menggabungkan oli & cairan
    // oliMatik 'X' berarti tidak ada/tidak berlaku, jangan dicetak
    // final oliText = [
    //   if (oliMesin.isNotEmpty) 'Oli: $oliMesin',
    //   if (oliMatik.isNotEmpty && oliMatik != 'X') 'Matik: $oliMatik',
    //   if (coolant.isNotEmpty) 'Coolant: $coolant',
    //   if (oliRemKopling.isNotEmpty) 'Rem/Kopl: $oliRemKopling',
    // ].join(' | ');el

    // Menggabungkan info torsi & service berikut
    final lastField = [
      if (torsiMur.isNotEmpty) 'Torsi: $torsiMur kg-m',
      if (serviceKm.isNotEmpty || serviceBulan.isNotEmpty)
        'Service berikut: $serviceKm km / $serviceBulan bln',
    ].join(' | ');

    // Gabungkan batteryStatus ke dalam string batteryAwal
    // final batteryAwalFull = [
    //   if (batteryAwal.isNotEmpty) batteryAwal,
    //   if (batteryStatus.isNotEmpty && batteryStatus != 'Normal') '($batteryStatus)',
    // ].join(' ');
    // final batteryAwalDisplay = batteryAwalFull.isEmpty
    //     ? (batteryStatus != 'Normal' ? batteryStatus : '')
    //     : batteryAwalFull;

    // ── 4. Mapping index → nilai sesuai daftar nama field PDF ─────────
    final Map<int, String> indexToValue = {
      // 0: oliText,                        // TextFormField 5 (Oli & cairan)
      1: lastField,                      // TextFormField 6 (Info tambahan)
      2: order.catatanKeluhan,           // KeluhanPemilik
      3: pekerjaanText,                  // OrderKerja
      4: pekerjaanTextDenganCatatan,     // PekerjaanYangDilakukan
      5: namaPemilik,                    // NamaPemilik
      6: alamat,                         // Alamat
      7: merkMobil,                      // MerkMobil
      8: noRangka,                       // NomorRangka
      9: _tgl(order.createdAt),          // TanggalMasuk
      10: typeMobil,                     // TipeMobil
      11: noMesin,                       // NomorMesin
      12: _jam(order.createdAt),         // JamMasuk
      13: telepon,                       // NomorTelepon
      14: tahun,                         // TahunMobil
      15: order.completedAt != null ? _tgl(order.completedAt!) : '', // TanggalSelesai
      16: order.nomorWoDisplay,          // NomorWO
      17: nomorPolisi,                   // NomorPolisi
      18: order.completedAt != null ? _jam(order.completedAt!) : '', // TextFormField 26 (JamSelesai)
      19: km,                            // KilometerMobil
      // 20: batteryAwalDisplay,             // BatteryAwal (+ status jika tidak Normal)
      // 21: batteryStater,                 // BatteryStarter
      // 22: batteryPengisian,              // BatteryPengisian
      // 23: tekananDepan,                  // TekananDepan
      // 24: tekananBelakang,               // TekananBelakang
      // 25: tekananCadangan,               // TekananCadangan
      // 26: catatanTambahan,               // CatatanTambahan
    };

    // Step 1: Isi semua field teks dengan nilai yang sesuai
    final font = PdfStandardFont(PdfFontFamily.helvetica, 9);
    for (int i = 0; i < form.fields.count; i++) {
      final val = indexToValue[i] ?? '';
      final field = form.fields[i];

      if (val.isNotEmpty) {
        if (field is PdfTextBoxField) {
          field.font = font;
          field.text = val;
        } else {
          _setFieldValue(field, val);
        }
      }
      
      // Hilangkan kotak hitam dengan membuat field transparan
      if (field is PdfTextBoxField) {
        field.borderColor = PdfColor(255, 255, 255, 0);
        field.backColor = PdfColor(255, 255, 255, 0);
      }
    }

    // Step 2: Flatten — ratakan semua form field menjadi teks statis
    // Terbukti bekerja pada template work_order-2.pdf (lihat debugFillFieldNames)
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
