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
