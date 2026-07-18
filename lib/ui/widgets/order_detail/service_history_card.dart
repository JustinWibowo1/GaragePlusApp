import 'package:flutter/material.dart';
import '../../../component/app_colors.dart';
import '../../../component/component_apps.dart';
import '../../../models/order_service_models.dart';

const List<String> _kMonths = [
  '',
  'JAN',
  'FEB',
  'MAR',
  'APR',
  'MEI',
  'JUN',
  'JUL',
  'AGU',
  'SEP',
  'OKT',
  'NOV',
  'DES'
];

String _formatCurrency(int amount) => amount
    .toString()
    .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

class RoundedTop extends StatelessWidget {
  final Widget child;
  const RoundedTop({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: child,
    );
  }
}

class ServiceCard extends StatefulWidget {
  final OrderServiceSummary order;
  final VoidCallback onTap;

  const ServiceCard({Key? key, required this.order, required this.onTap}) : super(key: key);

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 120),
  );

  late final Animation<double> _scale = Tween<double>(begin: 1.0, end: 0.97)
      .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

  bool _isHovered = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    AppStatusColors.of(order.status);
    final pending = AppStatusColors.isPending(order.status);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () async {
          await _ctrl.forward();
          await _ctrl.reverse();
          widget.onTap();
        },
        onTapDown: (_) => _ctrl.forward(),
        onTapCancel: () => _ctrl.reverse(),
        child: ScaleTransition(
          scale: _scale,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isHovered ? const Color(0xFFCCCCCC) : AppColors.greyBg,
              ),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      )
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DateColumn(date: order.tanggalMasuk, pending: pending),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  order.nomorWoDisplay,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.blueLink,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                AppStatusBadge(status: order.status),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(
                              order.catatanKeluhan.isNotEmpty
                                  ? order.catatanKeluhan
                                  : '-',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.navy,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 10),
                            const Divider(height: 1, color: AppColors.greyBg),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                KmChip(km: order.kilometer),
                                Text(
                                  'Rp ${_formatCurrency(order.totalTagihan)}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.navy,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Icon(Icons.chevron_right_rounded,
                            size: 18, color: Colors.grey.shade300),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DateColumn extends StatelessWidget {
  final DateTime date;
  final bool pending;

  const DateColumn({Key? key, required this.date, required this.pending}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      color: AppColors.backgroundSection,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            date.day.toString().padLeft(2, '0'),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.navy,
              height: 1.0,
            ),
          ),
          Text(
            _kMonths[date.month],
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.navy,
              letterSpacing: 0.4,
            ),
          ),
          Text(
            '${date.year}',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}

class KmChip extends StatelessWidget {
  final int km;
  const KmChip({Key? key, required this.km}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.speed_outlined, size: 13, color: Colors.grey.shade400),
        const SizedBox(width: 4),
        Text(
          '${_formatCurrency(km)} KM',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
        ),
      ],
    );
  }
}
