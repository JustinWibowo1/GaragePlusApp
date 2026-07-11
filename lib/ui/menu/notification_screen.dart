import 'package:flutter/material.dart';
import '../../app_colors.dart';
import '../../viewModel/notification_viewmodel.dart';
import '../../models/customer_models.dart';
import '../../models/order_kerja_models.dart';
import '../widgets/order_detail/service_reminder_panel.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  final NotificationViewModel _vm = NotificationViewModel();
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _vm.muatSemuaNotifikasi();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _vm.dispose();
    super.dispose();
  }

  String _formatDate(DateTime dt) {
    const bulan = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${dt.day} ${bulan[dt.month]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.navy, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: AppColors.navy, size: 22),
            tooltip: 'Refresh',
            onPressed: () => _vm.muatSemuaNotifikasi(),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.navy,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.navy,
          indicatorWeight: 2.5,
          labelStyle: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 13),
          unselectedLabelStyle: const TextStyle(fontSize: 13),
          tabs: [
            ListenableBuilder(
              listenable: _vm,
              builder: (_, __) => Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Follow-Up'),
                    if (_vm.followUpItems.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      _Badge(
                          count: _vm.followUpItems.length,
                          color: Colors.blue.shade600),
                    ],
                  ],
                ),
              ),
            ),
            ListenableBuilder(
              listenable: _vm,
              builder: (_, __) => Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Reminder Service'),
                    if (_vm.overdueCount > 0) ...[
                      const SizedBox(width: 6),
                      _Badge(
                          count: _vm.overdueCount, color: AppColors.red),
                    ] else if (_vm.urgentCount > 0) ...[
                      const SizedBox(width: 6),
                      _Badge(
                          count: _vm.urgentCount,
                          color: AppColors.orangeDark),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: _vm,
        builder: (context, _) {
          if (_vm.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.navy),
                  SizedBox(height: 16),
                  Text('Memuat notifikasi...',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          if (_vm.errorMessage != null) {
            return _buildError();
          }
          return TabBarView(
            controller: _tabController,
            children: [
              _buildFollowUpTab(),
              _buildReminderTab(),
            ],
          );
        },
      ),
    );
  }

  // ── Error State ───────────────────────────────────────────────
  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
          const SizedBox(height: 12),
          Text(_vm.errorMessage!,
              style: TextStyle(color: Colors.red.shade400, fontSize: 14),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _vm.muatSemuaNotifikasi,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  TAB 1: Follow-Up
  // ─────────────────────────────────────────────────────────────
  Widget _buildFollowUpTab() {
    if (_vm.followUpItems.isEmpty) {
      return _buildEmptyState(
        icon: Icons.check_circle_outline_rounded,
        iconColor: Colors.blue.shade400,
        bgColor: Colors.blue.shade50,
        title: 'Tidak ada follow-up hari ini',
        subtitle: 'Pelanggan yang butuh dihubungi 7 hari setelah servis\nakan muncul di sini.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: _vm.followUpItems.length,
      itemBuilder: (context, index) =>
          _buildFollowUpCard(_vm.followUpItems[index]),
    );
  }

  Widget _buildFollowUpCard(FollowUpItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: Colors.blue.shade500, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Row: Nama + Badge ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.phone_callback_rounded,
                      size: 22, color: Colors.blue.shade600),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.namaPemilik,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.navy,
                          )),
                      const SizedBox(height: 3),
                      Text(
                        '${item.nomorPolisi}  •  ${item.jenisMobil} ${item.tipeMobil}',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.phone_rounded,
                          size: 12, color: Colors.blue.shade600),
                      const SizedBox(width: 4),
                      Text(
                        'FOLLOW UP',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.blue.shade700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Container(height: 1, color: const Color(0xFFF0F0F0)),
            const SizedBox(height: 12),

            // ── Row: Detail WO ──
            Row(
              children: [
                _InfoChip(
                  icon: Icons.receipt_long_outlined,
                  label: item.nomorWoDisplay,
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  icon: Icons.event_available_rounded,
                  label: 'Selesai ${_formatDate(item.tanggalSelesai)}',
                ),
              ],
            ),

            if (item.catatanKeluhan.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.notes_rounded,
                      size: 13, color: Colors.grey.shade400),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      item.catatanKeluhan,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 12),
            // ── Nomor Rangka ──
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.backgroundSection,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.tag_rounded,
                      size: 12, color: AppColors.textGrey),
                  const SizedBox(width: 4),
                  Text(
                    item.nomorRangka,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textGrey,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // ── Tombol Done ──
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                label: const Text('Tandai Selesai'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue.shade600,
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                onPressed: () => _vm.markFollowUpDone(item.nomorWo),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  TAB 2: Reminder Service
  // ─────────────────────────────────────────────────────────────
  Widget _buildReminderTab() {
    if (_vm.groupedByCustomer.isEmpty) {
      return _buildEmptyState(
        icon: Icons.check_circle_outline_rounded,
        iconColor: AppColors.greenAccent,
        bgColor: AppColors.greenBg,
        title: 'Semua kendaraan baik-baik saja!',
        subtitle: 'Tidak ada jadwal servis yang perlu diperhatikan.',
      );
    }

    return Column(
      children: [
        _buildReminderSummaryBar(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: _vm.groupedByCustomer.length,
            itemBuilder: (context, index) {
              final entry =
                  _vm.groupedByCustomer.entries.elementAt(index);
              return _buildCustomerReminderCard(entry.key, entry.value);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReminderSummaryBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          if (_vm.overdueCount > 0) ...[
            _buildChip(
              label: '${_vm.overdueCount} Overdue',
              color: AppColors.red,
              bgColor: AppColors.overdueBg,
              icon: Icons.error_rounded,
            ),
            const SizedBox(width: 10),
          ],
          if (_vm.urgentCount > 0)
            _buildChip(
              label: '${_vm.urgentCount} Segera',
              color: AppColors.orangeDark,
              bgColor: AppColors.urgentBg,
              icon: Icons.warning_amber_rounded,
            ),
          const Spacer(),
          Text(
            '${_vm.groupedByCustomer.length} kendaraan',
            style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(
      {required String label,
      required Color color,
      required Color bgColor,
      required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: bgColor, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color)),
        ],
      ),
    );
  }

  Widget _buildCustomerReminderCard(
      Customer customer, List<ServiceReminderItem> reminders) {
    final hasOverdue = reminders.any((r) => r.isOverdue);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasOverdue
              ? const Color(0xFFFFD080)
              : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header pelanggan ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: hasOverdue
                  ? const Color(0xFFFFF8F0)
                  : AppColors.backgroundSection,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: hasOverdue
                        ? const Color(0xFFFFD080)
                        : AppColors.border,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.directions_car_rounded,
                      size: 22,
                      color: hasOverdue
                          ? const Color(0xFFBF6000)
                          : AppColors.navy),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(customer.namaPemilik,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.navy)),
                      const SizedBox(height: 3),
                      Text(
                        '${customer.nomorPolisi}  •  ${customer.jenisMobil} ${customer.tipeMobil}',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSection,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.tag_rounded,
                          size: 12, color: AppColors.textGrey),
                      const SizedBox(width: 4),
                      Text(customer.nomorRangka,
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textGrey,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3)),
                    ],
                  ),
                ),
                // ── Tombol Done di header Reminder ──
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _vm.markReminderDone(customer.nomorRangka),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_rounded, size: 14, color: Colors.green.shade600),
                        const SizedBox(width: 4),
                        Text('Done', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.green.shade700)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── ReminderRow (komponen lama) ──
          ...reminders.map((r) => ReminderRow(item: r)),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  Empty State
  // ─────────────────────────────────────────────────────────────
  Widget _buildEmptyState({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, size: 40, color: iconColor),
          ),
          const SizedBox(height: 20),
          Text(title,
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy)),
          const SizedBox(height: 8),
          Text(subtitle,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Helper Widgets
// ─────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final int count;
  final Color color;
  const _Badge({required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
      child: Text('$count',
          style: const TextStyle(
              color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: AppColors.backgroundSection,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textGrey),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textGrey,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
