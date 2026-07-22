import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../component/app_colors.dart';
import '../../models/invoice_models.dart';
import '../../viewModel/order_detail/invoice_viewmodel.dart';
import '../dialogs/status_popup.dart';

class TabelInvoice extends StatelessWidget {
  final InvoiceViewModel vm;
  final List<InvoiceItem> daftarInvoice;
  final bool isHistory;

  const TabelInvoice({
    Key? key,
    required this.vm,
    required this.daftarInvoice,
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
                const Expanded(flex: 3, child: _TableHeaderText('Nama Pekerjaan')),
                const Expanded(flex: 2, child: _TableHeaderText('Waktu Ditambahkan')),
                const Expanded(flex: 2, child: _TableHeaderText('Harga')),
                if (!isHistory)
                  const SizedBox(width: 32), // Spacer for Action menu
              ],
            ),
          ),
          // Table Rows
          if (daftarInvoice.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text('Tidak ada tagihan custom.',
                    style: TextStyle(color: AppColors.textGrey)),
              ),
            ),
          ...daftarInvoice.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == daftarInvoice.length - 1;

            return Container(
              key: ValueKey(item.id),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                border: isLast
                    ? null
                    : const Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama Pekerjaan
                  Expanded(
                    flex: 3,
                    child: Text(
                      item.namaPekerjaan,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.navy,
                      ),
                    ),
                  ),
                  // Waktu
                  Expanded(
                    flex: 2,
                    child: Text(
                      _formatDate(item.createdAt),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  // Harga
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Rp ${NumberFormat('#,###', 'id_ID').format(item.harga)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.orangeDark,
                      ),
                    ),
                  ),
                  // Action Menu
                  if (!isHistory)
                    SizedBox(
                      width: 32,
                      child: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textGrey),
                        tooltip: '', // Kosongkan tooltip untuk mencegah crash saat unmount
                        padding: EdgeInsets.zero,
                        onSelected: (value) async {
                          if (value == 'edit') {
                            await vm.showEditInvoiceDialog(context, item);
                          } else if (value == 'delete') {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Hapus Tagihan?'),
                                content: Text('Yakin ingin menghapus ${item.namaPekerjaan}?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Batal'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              final sukses = await vm.hapusInvoice(item.id);
                              if (context.mounted) {
                                await StatusPopup.show(
                                  context,
                                  isSuccess: sukses,
                                  message: sukses ? 'Berhasil dihapus' : 'Gagal menghapus',
                                );
                              }
                            }
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined, size: 18, color: AppColors.primaryBlue),
                                SizedBox(width: 8),
                                Text('Edit', style: TextStyle(color: AppColors.primaryBlue)),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Hapus', style: TextStyle(color: Colors.red)),
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
          // Subtotal Row
          if (daftarInvoice.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: AppColors.backgroundAlt,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  const Expanded(
                    flex: 5,
                    child: Text(
                      'SUBTOTAL INVOICE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(width: 16), // Jarak ke kolom harga
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Rp ${NumberFormat('#,###', 'id_ID').format(daftarInvoice.fold<int>(0, (sum, item) => sum + item.harga))}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.orangeDark,
                      ),
                    ),
                  ),
                  if (!isHistory)
                    const SizedBox(width: 32),
                ],
              ),
            ),
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
