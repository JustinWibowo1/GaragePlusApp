import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import '../../services/work_order_filler.dart';

class PdfDebugScreen extends StatelessWidget {
  final bool isEstimasi;

  const PdfDebugScreen({
    Key? key,
    this.isEstimasi = true, // Default ke PDF Estimasi
  }) : super(key: key);

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
            return await WorkOrderFiller.debugEstimasiFieldNames();
          } else {
            return await WorkOrderFiller.debugFillFieldNames();
          }
        },
      ),
    );
  }
}
