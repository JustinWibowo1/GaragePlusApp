import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

class OrderKerjaPreviewDialog extends StatefulWidget {
  final Uint8List pdfBytes;
  final Future<bool> Function() onConfirm;

  const OrderKerjaPreviewDialog({
    Key? key,
    required this.pdfBytes,
    required this.onConfirm,
  }) : super(key: key);

  @override
  State<OrderKerjaPreviewDialog> createState() => _OrderKerjaPreviewDialogState();
}

class _OrderKerjaPreviewDialogState extends State<OrderKerjaPreviewDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: size.width * 0.9,
        height: size.height * 0.9,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Preview Order Kerja', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () {
                  if (!_isLoading) Navigator.pop(context);
                }),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: PdfPreview(
                  build: (_) => widget.pdfBytes,
                  canChangeOrientation: false,
                  canChangePageFormat: false,
                  allowPrinting: false,
                  allowSharing: false,
                  canDebug: false,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : () async {
                    setState(() => _isLoading = true);
                    final success = await widget.onConfirm();
                    if (success && mounted) {
                      Navigator.pop(context, true);
                    } else if (mounted) {
                      setState(() => _isLoading = false);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  icon: _isLoading
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.check),
                  label: Text(_isLoading ? 'Menyimpan...' : 'Konfirmasi & Simpan', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
