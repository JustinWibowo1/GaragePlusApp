import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

void main() {
  test('List PDF Fields', () {
    final file = File('asset/work_order-2.pdf');
    if (!file.existsSync()) {
      print('PDF not found!');
      return;
    }
    
    final PdfDocument document = PdfDocument(inputBytes: file.readAsBytesSync());
    final PdfForm form = document.form;
    
    print('--- DAFTAR FIELD PDF ---');
    for (int i = 0; i < form.fields.count; i++) {
      final field = form.fields[i];
      print('Index: $i => ${field.name}');
    }
    print('------------------------');

    
    document.dispose();
  });
}
