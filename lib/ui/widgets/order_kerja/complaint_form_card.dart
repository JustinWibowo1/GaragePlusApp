import 'package:flutter/material.dart';
import '../../../app_colors.dart';
import '../../../utils/formatters.dart';
import '../../../viewModel/order_kerja_viewmodel.dart';

class ComplaintFormCard extends StatelessWidget {
  final OrderKerjaViewModel vm;
  final TextEditingController keluhanController;
  final TextEditingController kilometerController;

  const ComplaintFormCard({
    Key? key,
    required this.vm,
    required this.keluhanController,
    required this.kilometerController,
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
        const SizedBox(height: 32),

        // ── Input Odometer ──
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
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.speed_rounded, color: AppColors.navy, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Odometer Saat Ini',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Catat kilometer kendaraan saat masuk bengkel untuk keperluan service reminder.',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      controller: kilometerController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        ThousandsSeparatorFormatter(),
                      ],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                      ),
                      decoration: InputDecoration(
                        hintText: '0',
                        hintStyle: TextStyle(
                            color: Colors.grey.shade300,
                            fontSize: 20,
                            fontWeight: FontWeight.w700),
                        suffixText: 'KM',
                        suffixStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.w600),
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                      ),
                      onChanged: (val) {
                        final km = int.tryParse(val.replaceAll('.', '')) ?? 0;
                        vm.setKilometer(km);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Live display
                  ListenableBuilder(
                    listenable: vm,
                    builder: (context, _) {
                      final km = vm.kilometer;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: km > 0 ? AppColors.navy : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.speed_rounded,
                              size: 20,
                              color: km > 0 ? Colors.white : Colors.grey.shade400,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              km > 0 ? '✓ Tercatat' : 'Belum',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color:
                                    km > 0 ? Colors.white : Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
