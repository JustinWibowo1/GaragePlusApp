import 'package:flutter/material.dart';
import '../../../models/customer_models.dart';
import '../../../app_colors.dart';

class VehicleInfoCard extends StatelessWidget {
  final Customer customer;

  const VehicleInfoCard({
    Key? key,
    required this.customer,
  }) : super(key: key);

  Widget _buildInfoColumn(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
              fontSize: 10,
              color: AppColors.navy.withOpacity(0.6),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
              fontSize: 14,
              color: AppColors.navyDeep,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5),
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
          Container(
            height: 120,
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16)),
              gradient: LinearGradient(
                  colors: [
                    AppColors.navyDeep,
                    AppColors.navyDark
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text((customer.tipeMobil.isNotEmpty ? customer.tipeMobil : customer.jenisMobil).toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5)),
                    Text(
                        '${customer.namaPemilik} (${customer.noTelepon ?? '-'})',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                        '${customer.tipeMesin} • ${customer.tipeTransmisi}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            letterSpacing: 0.5)),
                    Text(customer.alamatLengkap,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 24, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoColumn(
                    'Nomor Polisi', customer.nomorPolisi),
                _buildInfoColumn(
                    'Nomor Rangka', customer.nomorRangka),
                _buildInfoColumn(
                    'Nomor Mesin', customer.nomorMesin),
                _buildInfoColumn('ODOMETER', '- KM'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
