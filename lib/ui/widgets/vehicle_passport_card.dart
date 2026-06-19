import 'package:flutter/material.dart';
import '../../app_colors.dart';

class VehiclePassportCard extends StatelessWidget {
  final String merkMobil;
  final String typeMobil;
  final String nomorPolisi;
  final String noRangka;
  final String noMesin;
  final String odometer;
  final double progress;
  final int totalItem;
  final bool isCompleted;

  const VehiclePassportCard({
    Key? key,
    required this.merkMobil,
    required this.typeMobil,
    required this.nomorPolisi,
    required this.noRangka,
    required this.noMesin,
    required this.odometer,
    required this.progress,
    required this.totalItem,
    required this.isCompleted,
  }) : super(key: key);

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: AppColors.textGrey,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Detail Kendaraan',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textGrey,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$merkMobil $typeMobil'.trim().isEmpty
                        ? nomorPolisi
                        : '$merkMobil $typeMobil',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryBlue,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                          child: _buildInfoItem(
                              'Nomor Rangka',
                              noRangka.isEmpty ? '-' : noRangka)),
                      Expanded(
                          child: _buildInfoItem(
                              'Nomor Mesin',
                              noMesin.isEmpty ? '-' : noMesin)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                          child: _buildInfoItem('Nomor Polisi', nomorPolisi)),
                      Expanded(
                          child: _buildInfoItem('Kilometer', odometer)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Divider
          Container(width: 1, height: 180, color: AppColors.border),
          // Health Status
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: totalItem == 0 ? 0 : progress,
                          strokeWidth: 10,
                          backgroundColor: AppColors.chipBg,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isCompleted ? AppColors.green : AppColors.primaryBlue,
                          ),
                        ),
                        Center(
                          child: Text(
                            '${(progress * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: AppColors.navy,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Progress Pekerjaan',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isCompleted ? AppColors.greenBg : AppColors.urgentBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isCompleted ? 'Selesai' : 'Dalam pengerjaan',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: isCompleted
                            ? AppColors.greenBadgeDark
                            : AppColors.urgentText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
