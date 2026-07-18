import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../app_colors.dart';

class FormInvoiceDialog extends StatefulWidget {
  const FormInvoiceDialog({Key? key}) : super(key: key);

  static Future<Map<String, dynamic>?> show(BuildContext context) {
    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const FormInvoiceDialog(),
    );
  }

  @override
  State<FormInvoiceDialog> createState() => _FormInvoiceDialogState();
}

class _FormInvoiceDialogState extends State<FormInvoiceDialog> {
  final _namaController = TextEditingController();
  final _hargaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _formatNumber(String s) {
    if (s.isEmpty) return '';
    final number = int.tryParse(s.replaceAll(RegExp(r'[^0-9]'), ''));
    if (number == null) return '';
    return NumberFormat('#,###', 'id_ID').format(number);
  }

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text('Tambah Invoice Custom'),
      content: SizedBox(
        width: 400, // Memberikan sedikit ruang lega untuk dialog
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _namaController,
                decoration: InputDecoration(
                  labelText: 'Nama Pekerjaan / Tagihan',
                  hintText: 'Misal: Ongkos Kirim Sparepart',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Nama wajib diisi';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _hargaController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Harga',
                  hintText: '0',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixText: 'Rp ',
                ),
                onChanged: (val) {
                  final formatted = _formatNumber(val);
                  _hargaController.value = TextEditingValue(
                    text: formatted,
                    selection: TextSelection.collapsed(offset: formatted.length),
                  );
                },
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Harga wajib diisi';
                  final num = int.tryParse(val.replaceAll(RegExp(r'[^0-9]'), ''));
                  if (num == null || num < 0) return 'Harga tidak valid';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final harga = int.parse(_hargaController.text.replaceAll(RegExp(r'[^0-9]'), ''));
              Navigator.pop(context, {
                'nama': _namaController.text.trim(),
                'harga': harga,
              });
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
