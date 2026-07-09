import 'package:flutter/material.dart';
import '../../../app_colors.dart';

class ComplaintFormCard extends StatelessWidget {
  final TextEditingController keluhanController;

  const ComplaintFormCard({
    Key? key,
    required this.keluhanController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Catatan Keluhan ──
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 15,
                  offset: const Offset(0, 5))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: const [
                Icon(Icons.edit_note, color: AppColors.navy, size: 24),
                SizedBox(width: 8),
                Text('Catatan / Keluhan Konsumen',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navy)),
              ]),
              const SizedBox(height: 16),
              TextField(
                controller: keluhanController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText:
                      'Dokumentasikan keluhan spesifik atau permintaan khusus dari pelanggan di sini...',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.all(20),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
