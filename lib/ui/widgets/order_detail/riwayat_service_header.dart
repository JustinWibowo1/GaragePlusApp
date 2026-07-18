import 'package:flutter/material.dart';
import '../../../component/app_colors.dart';
import '../../../models/customer_models.dart';
import '../../../component/component_apps.dart';

class RiwayatService extends StatelessWidget {
  final Customer customer;
  final int totalVisit;
  final int kmTerakhir;

  const RiwayatService({
    Key? key,
    required this.customer,
    required this.totalVisit,
    required this.kmTerakhir,
  }) : super(key: key);

  String _formatCurrency(int amount) => amount
      .toString()
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      color: AppColors.navy,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, top + 16, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBackRow(context),
            const SizedBox(height: 20),
            _buildOwnerBlock(),
            const SizedBox(height: 20),
            _buildStatsRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackRow(BuildContext context) {
    return Row(
      children: [
        AppAnimatedBackButton(onTap: () => Navigator.pop(context)),
        const SizedBox(width: 10),
        const Text(
          'Riwayat Service',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildOwnerBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          customer.namaPemilik,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        MetaChip(
            icon: Icons.directions_car_outlined,
            label: 'Nomor Polisi:  ${customer.nomorPolisi}'),
        if (customer.jenisMobil.isNotEmpty) ...[
          const SizedBox(height: 6),
          MetaChip(
              icon: Icons.directions_car,
              label: '${customer.jenisMobil} ${customer.tipeMobil}'),
        ],
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            label: 'TOTAL KUNJUNGAN',
            value: totalVisit == 0 ? '-' : '$totalVisit',
            subtitle: 'kali service',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StatCard(
            label: 'KM TERAKHIR',
            value: kmTerakhir == 0 ? '-' : _formatCurrency(kmTerakhir),
            subtitle: 'kilometer',
          ),
        ),
      ],
    );
  }
}

class MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const MetaChip({Key? key, required this.icon, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: Colors.white.withOpacity(0.4)),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.55),
          ),
        ),
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;

  const StatCard({
    Key? key,
    required this.label,
    required this.value,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.12), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Colors.white.withOpacity(0.4),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withOpacity(0.35),
            ),
          ),
        ],
      ),
    );
  }
}
