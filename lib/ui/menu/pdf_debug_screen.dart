import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../services/work_order_filler.dart';
import '../../services/estimasi_filler.dart';

class PdfDebugScreen extends StatelessWidget {
  final bool isEstimasi;

  const PdfDebugScreen({super.key, this.isEstimasi = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEstimasi ? 'Debug: PDF Estimasi' : 'Debug: PDF WO'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: PdfPreview(
        allowPrinting: true,
        allowSharing: true,
        canChangeOrientation: false,
        canChangePageFormat: false,
        build: (format) async {
          if (isEstimasi) {
            return await EstimasiFiller.debugFieldNames();
          } else {
            return await WorkOrderFiller.debugFillFieldNames();
          }
        },
      ),
    );
  }
}
