import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../app_colors.dart';
import '../../models/service_details_models.dart';
import '../../viewModel/order_detail_viewmodel.dart';
import '../dialogs/work_order_dialogs.dart';

class TaskLedgerTable extends StatelessWidget {
  final OrderDetailViewModel vm;
  final List<OrderServiceDetail> daftarDetail;
  final bool isHistory;

  const TaskLedgerTable({
    Key? key,
    required this.vm,
    required this.daftarDetail,
    required this.isHistory,
  }) : super(key: key);

  String _formatDate(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              color: AppColors.backgroundAlt,
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: const Row(
              children: [
                Expanded(flex: 3, child: _TableHeaderText('Detail Pekerjaan')),
                Expanded(flex: 2, child: _TableHeaderText('Kategori')),
                Expanded(flex: 2, child: _TableHeaderText('Status')),
                Expanded(flex: 3, child: _TableHeaderText('Catatan Teknisi')),
              ],
            ),
          ),
          // Table Rows
          if (daftarDetail.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text('Tidak ada task detail.',
                    style: TextStyle(color: AppColors.textGrey)),
              ),
            ),
          ...daftarDetail.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == daftarDetail.length - 1;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                border: isLast
                    ? null
                    : const Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task Details
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.namaPekerjaan ?? '-',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.navy,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.status == StatusItem.selesai
                              ? 'Completed at ${_formatDate(item.createdAt)}'
                              : 'Added at ${_formatDate(item.createdAt)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Category
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.kodePekerjaan ?? 'General',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: isHistory
                            ? null
                            : () => WorkOrderDialogs.showUbahStatusDialog(context, vm, item),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: item.status == StatusItem.selesai
                                ? AppColors.primaryBlue
                                : (item.status == StatusItem.dikerjakan
                                    ? AppColors.amber
                                    : AppColors.textGrey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.status == StatusItem.selesai
                                ? 'COMPLETED'
                                : item.status.label.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Technical Notes
                  Expanded(
                    flex: 3,
                    child: Text(
                      (item.catatanTeknisi == null || item.catatanTeknisi!.isEmpty)
                          ? '-'
                          : item.catatanTeknisi!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textDark,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _TableHeaderText extends StatelessWidget {
  final String text;
  const _TableHeaderText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: AppColors.textGrey,
        letterSpacing: 1.2,
      ),
    );
  }
}
