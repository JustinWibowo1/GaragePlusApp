import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

class PdfPrinterService {
  static void showPreview(BuildContext context, Uint8List pdfBytes) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Preview PDF')),
          body: PdfPreview(
            build: (_) => pdfBytes,
            canChangeOrientation: false,
            canChangePageFormat: false,
            allowPrinting: true,
            allowSharing: true,
          ),
        ),
      ),
    );
  }

  /// Tampilkan preview PDF dengan tombol Konfirmasi.
  /// Mengembalikan [true] jika user menekan "Konfirmasi & Simpan",
  /// [false] atau [null] jika user kembali / batal.
  static Future<bool?> showPreviewWithConfirm(
    BuildContext context,
    Uint8List pdfBytes, {
    bool sudahSelesai = false,
  }) {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            title: const Text(
              'Preview Work Order',
              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F2042)),
            ),
            iconTheme: const IconThemeData(color: Color(0xFF0F2042)),
          ),
          body: Column(
            children: [
              Expanded(
                child: PdfPreview(
                  build: (_) => pdfBytes,
                  canChangeOrientation: false,
                  canChangePageFormat: false,
                  allowPrinting: true,
                  allowSharing: true,
                  useActions: true,
                ),
              ),
              if (!sudahSelesai)
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        '⚠️ Setelah dikonfirmasi, order akan dikunci sebagai Selesai dan tidak dapat diedit.',
                        style: TextStyle(fontSize: 12, color: Colors.orange),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(_, false),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                side: const BorderSide(color: Color(0xFF0F2042)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Kembali & Edit',
                                style: TextStyle(
                                  color: Color(0xFF0F2042),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.pop(_, true),
                              icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                              label: const Text(
                                'Konfirmasi & Simpan',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> printDirect(Uint8List pdfBytes, String docName) async {
    await Printing.layoutPdf(
      onLayout: (_) => pdfBytes,
      name: docName,
      format: PdfPageFormat.a4,
    );
  }

  static Future<void> sharePdf(Uint8List pdfBytes, String fileName) async {
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: fileName,
    );
  }
}
