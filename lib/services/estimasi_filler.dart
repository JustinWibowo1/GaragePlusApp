import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../models/order_service_models.dart';
import '../models/service_details_models.dart';

class EstimasiFiller {
  static const _bulan = [
    '',
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  static String _tgl(DateTime d) {
    final local = d.toLocal();
    return '${local.day} ${_bulan[local.month]} ${local.year}';
  }

  static String _rupiah(int amount) {
    return NumberFormat('#,###', 'id_ID').format(amount).replaceAll(',', '.');
  }

  // ── Debug: Tampilkan index & nama semua field di estimasi_biaya.pdf ──────
  /// Gunakan fungsi ini untuk mengetahui index masing-masing field PDF.
  /// Hasilnya berupa PDF yang setiap field berisi "[index]NamaField".
  static Future<Uint8List> debugFieldNames() async {
    final ByteData data = await rootBundle.load('asset/estimasi_biaya.pdf');
    final PdfDocument document =
        PdfDocument(inputBytes: data.buffer.asUint8List());
    final PdfForm form = document.form;

    for (int i = 0; i < form.fields.count; i++) {
      final field = form.fields[i];
      if (field is PdfTextBoxField) {
        field.text = '[$i] ${field.name}';
      } else if (field is PdfComboBoxField) {
        // Isi dengan label index saja agar terlihat
        try { field.selectedValue = field.items[0].value; } catch (_) {}
      }
    }

    form.flattenAllFields();
    final List<int> saved = await document.save();
    document.dispose();
    return Uint8List.fromList(saved);
  }

  // ── Isi Estimasi Biaya ────────────────────────────────────────────────────
  /// Mengisi template PDF estimasi_biaya.pdf dengan data order dan detail pekerjaan.
  ///
  /// Jalankan [debugFieldNames] terlebih dahulu untuk mengetahui index field
  /// yang benar, lalu sesuaikan mapping [indexToValue] di bawah.
  static Future<Uint8List> fill({
    required OrderServiceSummary order,
    required List<OrderServiceDetail> details,
    // Data pelanggan
    required String namaPemilik,
    required String nomorPolisi,
    String telepon = '',
    String alamat = '',
    // Data kendaraan
    String merkMobil = '',
    String typeMobil = '',
    String tahun = '',
    String noRangka = '',
    String noMesin = '',
    // Estimasi tambahan
    String catatanEstimasi = '',
    String namaSA = '',          // Service Advisor
  }) async {
    final ByteData data = await rootBundle.load('asset/estimasi_biaya.pdf');
    final PdfDocument document =
        PdfDocument(inputBytes: data.buffer.asUint8List());
    final PdfForm form = document.form;

    // ── Format data ────────────────────────────────────────────────────────
    final km = '${NumberFormat('#,###', 'id_ID').format(order.kilometer).replaceAll(',', '.')} km';

    // Daftar pekerjaan + harga (semua item, bukan hanya yang selesai)
    final pekerjaanRows = details.asMap().entries.map((e) {
      final no   = e.key + 1;
      final item = e.value;
      final nama = item.namaPekerjaan ?? '-';
      final hrg  = 'Rp ${_rupiah(item.hargaFinal)}';
      return '$no. $nama — $hrg';
    }).join('\n');

    // Total semua harga
    final totalHarga = details.fold<int>(0, (sum, d) => sum + d.hargaFinal);
    final totalText  = 'Rp ${_rupiah(totalHarga)}';

    // ── Mapping index → nilai ───────────────────────────────────────────────
    // ⚠️  SESUAIKAN index di bawah ini setelah menjalankan debugFieldNames()
    // dan melihat hasil PDF debug untuk mengetahui posisi tiap field.
    final Map<int, String> indexToValue = {
      0: order.nomorWoDisplay,   // Nomor WO / Estimasi
      1: _tgl(order.createdAt),  // Tanggal
      2: namaPemilik,            // Nama Pemilik
      3: telepon,                // No. Telepon
      4: alamat,                 // Alamat
      5: merkMobil,              // Merk Mobil
      6: typeMobil,              // Tipe Mobil
      7: tahun,                  // Tahun
      8: nomorPolisi,            // Nomor Polisi
      9: noRangka,               // Nomor Rangka
      10: noMesin,               // Nomor Mesin
      11: km,                    // Kilometer
      12: order.catatanKeluhan,  // Keluhan Pemilik
      13: pekerjaanRows,         // Daftar Pekerjaan & Harga
      14: totalText,             // Total Estimasi
      15: catatanEstimasi,       // Catatan Tambahan
      16: namaSA,                // Service Advisor
    };

    // ── Isi semua field ────────────────────────────────────────────────────
    final font = PdfStandardFont(PdfFontFamily.helvetica, 9);
    for (int i = 0; i < form.fields.count; i++) {
      final val   = indexToValue[i] ?? '';
      final field = form.fields[i];

      if (val.isNotEmpty) {
        if (field is PdfTextBoxField) {
          field.font = font;
          field.text = val;
        } else {
          _setFieldValue(field, val);
        }
      }

      // Hilangkan border hitam agar tampil rapi
      if (field is PdfTextBoxField) {
        field.borderColor = PdfColor(255, 255, 255, 0);
        field.backColor   = PdfColor(255, 255, 255, 0);
      }
    }

    form.flattenAllFields();

    final List<int> saved = await document.save();
    document.dispose();
    return Uint8List.fromList(saved);
  }

  // ── Helper ─────────────────────────────────────────────────────────────
  static void _setFieldValue(PdfField field, String value) {
    if (field is PdfTextBoxField) {
      field.font = PdfStandardFont(PdfFontFamily.helvetica, 9);
      field.text = value;
    } else if (field is PdfComboBoxField) {
      try { field.selectedValue = value; } catch (_) {}
    } else if (field is PdfListBoxField) {
      try { field.selectedValues = [value]; } catch (_) {}
    } else if (field is PdfRadioButtonListField) {
      try { field.selectedValue = value; } catch (_) {}
    } else if (field is PdfCheckBoxField) {
      field.isChecked =
          value.toLowerCase() == 'true' || value == '1' || value == 'ya';
    }
  }
}
