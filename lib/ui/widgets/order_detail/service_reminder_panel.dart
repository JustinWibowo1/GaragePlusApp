import 'package:flutter/material.dart';
import '../../../models/order_kerja_models.dart';

class ServiceReminderPanel extends StatefulWidget {
  final List<ServiceReminderItem> reminders;
  const ServiceReminderPanel({Key? key, required this.reminders}) : super(key: key);

  @override
  State<ServiceReminderPanel> createState() => _ServiceReminderPanelState();
}

class _ServiceReminderPanelState extends State<ServiceReminderPanel> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final overdueCount = widget.reminders.where((r) => r.isOverdue).length;
    final urgentCount =
        widget.reminders.where((r) => r.isUrgent && !r.isOverdue).length;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F0),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFD080), width: 1),
      ),
      child: Column(
        children: [
          // ── Header ─────────────────────────────────────
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9800).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.warning_amber_rounded,
                        size: 16, color: Color(0xFFFF9800)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SERVICE PERLU PERHATIAN',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFBF6000),
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _buildSummaryText(overdueCount, urgentCount),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF8A5200),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: const Color(0xFFBF6000),
                  ),
                ],
              ),
            ),
          ),

          // ── List ───────────────────────────────────────
          if (_expanded) ...[
            Container(height: 0.5, color: const Color(0xFFFFD080)),
            ...widget.reminders.map((r) => ReminderRow(item: r)),
          ],
        ],
      ),
    );
  }

  String _buildSummaryText(int overdue, int urgent) {
    final parts = <String>[];
    if (overdue > 0) parts.add('$overdue sudah lewat jadwal');
    if (urgent > 0) parts.add('$urgent hampir jatuh tempo');
    return parts.join(' • ');
  }
}

class ReminderRow extends StatelessWidget {
  final ServiceReminderItem item;
  const ReminderRow({Key? key, required this.item}) : super(key: key);

  String _formatCurrency(int amount) => amount
      .toString()
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  @override
  Widget build(BuildContext context) {
    final isOverdue = item.isOverdue;

    final Color labelColor =
        isOverdue ? const Color(0xFFD32F2F) : const Color(0xFFE65100);
    final Color bgColor =
        isOverdue ? const Color(0xFFFFEBEE) : const Color(0xFFFFF3E0);
    final String badgeText = isOverdue ? 'OVERDUE' : 'SEGERA';
    final String desc;
    if (isOverdue) {
      if (item.sisaHari != null && item.sisaHari! <= 0) {
        desc = 'Terlewat ${item.sisaHari!.abs()} hari dari jadwal';
      } else if (item.sisaKm != null && item.sisaKm! <= 0) {
        desc = 'Lewat ${_formatCurrency(item.sisaKm!.abs())} km dari jadwal';
      } else {
        desc = 'Terlewat jadwal servis';
      }
    } else {
      List<String> sisa = [];
      if (item.sisaKm != null) sisa.add('${_formatCurrency(item.sisaKm!)} km');
      if (item.sisaHari != null) sisa.add('${item.sisaHari} hari');
      desc = 'Sisa: ' + sisa.join(' atau ');
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFFFF0CC), width: 0.5)),
      ),
      child: Row(
        children: [
          // Icon
          Icon(
            isOverdue ? Icons.error_outline : Icons.schedule_rounded,
            size: 16,
            color: labelColor,
          ),
          const SizedBox(width: 10),
          // Name + desc
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.nama,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isOverdue
                        ? const Color(0xFFB71C1C)
                        : const Color(0xFF6D4C00),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 11,
                    color: isOverdue
                        ? const Color(0xFFE57373)
                        : const Color(0xFFBF8000),
                  ),
                ),
              ],
            ),
          ),
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: labelColor.withOpacity(0.35)),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: labelColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
