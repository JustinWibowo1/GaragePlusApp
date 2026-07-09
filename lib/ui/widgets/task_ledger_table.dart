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
            child: Row(
              children: [
                const Expanded(flex: 3, child: _TableHeaderText('Detail Pekerjaan')),
                const Expanded(flex: 1, child: _TableHeaderText('Kategori')),
                const Expanded(flex: 2, child: _TableHeaderText('Status')),
                const Expanded(flex: 2, child: _TableHeaderText('Catatan Teknisi')),
                if (!isHistory)
                  const SizedBox(width: 32), // Spacer for Action menu
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
                  // Task Details & Harga
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
                          'Rp ${NumberFormat('#,###', 'id_ID').format(item.hargaFinal)}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.orangeDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.status == StatusItem.selesai
                              ? 'Completed at ${_formatDate(item.createdAt)}'
                              : 'Added at ${_formatDate(item.createdAt)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Category
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '-',
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
                    flex: 2,
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
                  // Action Menu
                  if (!isHistory)
                    SizedBox(
                      width: 32,
                      child: (item.status == StatusItem.selesai)
                          ? null // Jangan tampilkan tombol edit/delete jika sudah selesai
                          : PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textGrey),
                              tooltip: 'Opsi Pekerjaan',
                              padding: EdgeInsets.zero,
                              onSelected: (value) {
                                if (value == 'edit') {
                                  WorkOrderDialogs.showEditHargaDialog(context, vm, item);
                                } else if (value == 'delete') {
                                  WorkOrderDialogs.showHapusPekerjaanDialog(context, vm, item);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit_outlined, size: 18, color: AppColors.primaryBlue),
                                      SizedBox(width: 8),
                                      Text('Edit Harga'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Hapus Jasa', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
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
