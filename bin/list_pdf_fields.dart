import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';

void main() {
  final file = File('asset/work_order-2.pdf');
  if (!file.existsSync()) {
    print('PDF not found!');
    return;
  }
  
  final PdfDocument document = PdfDocument(inputBytes: file.readAsBytesSync());
  final PdfForm form = document.form;
  
  print('Total Fields: ${form.fields.count}');
  for (int i = 0; i < form.fields.count; i++) {
    final field = form.fields[i];
    print('Index: $i | Name: ${field.name} | Type: ${field.runtimeType}');
  }
  
  document.dispose();
}
