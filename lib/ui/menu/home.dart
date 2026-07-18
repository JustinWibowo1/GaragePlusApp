import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../component/app_animations.dart';
import '../../component/app_colors.dart';
import '../../viewModel/dashboard_viewmodel.dart';
import '../../models/service_logistic_models.dart';
import 'add_car.dart';
import 'pdf_debug_screen.dart';
import 'service_screen.dart';
import '../menu_sidebar.dart';
import 'notification_screen.dart';
import '../../viewModel/notification_viewmodel.dart';


class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final DashboardViewModel _vm = DashboardViewModel();
  final NotificationViewModel _notifVm = NotificationViewModel();

  @override
  void initState() {
    super.initState();
    _vm.muatServiceLogistics();
    _notifVm.muatSemuaNotifikasi();
  }

  @override
  void dispose() {
    _vm.dispose();
    _notifVm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          const CustomSidebar(),
          Expanded(
            child: Container(
              color: const Color(0xFFF8F9FB),
              child: Column(
                children: [
                  _buildTopHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListenableBuilder(
                            listenable: _vm,
                            builder: (context, _) => Row(
                              children: [
                                Expanded(
                                    child: _buildStatCard(
                                        'TOTAL KENDARAAN', 
                                        '${_vm.serviceLogistics.length}', 
                                        'aktif')),
                                const SizedBox(width: 24),
                                Expanded(
                                    child: _buildStatCard(
                                        'MENUNGGU', 
                                        '${_vm.serviceLogistics.where((e) => e.status == 'Menunggu').length}', 
                                        'antrean')),
                                const SizedBox(width: 24),
                                Expanded(
                                    child: _buildStatCard(
                                        'DIKERJAKAN', 
                                        '${_vm.serviceLogistics.where((e) => e.status == 'Dikerjakan').length}', 
                                        'proses')),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                  flex: 2,
                                  child: _buildMainBanner(context)),
                              const SizedBox(width: 24),
                              Expanded(
                                  flex: 1,
                                  child: _buildEditRecordsCard(context)),
                            ],
                          ),
                          const SizedBox(height: 32),
                          _buildServiceLogisticsTable(),
                        ],
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

  // ── Header ────────────────────────────────────
  Widget _buildTopHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      color: const Color(0xFFF8F9FB),
      child: Row(
        children: [
          Text(
            DateFormat('EEEE, MMM d').format(DateTime.now()),
            style: TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          // ── Tombol Debug PDF Estimasi ──
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: AppColors.textGrey, size: 24),
            tooltip: 'Debug PDF Estimasi',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (ctx) => const PdfDebugScreen(isEstimasi: true)),
              );
            },
          ),
          const SizedBox(width: 8),

          // ── Tombol Notifikasi dengan badge ──
          ListenableBuilder(
            listenable: _notifVm,
            builder: (context, _) {
              final count = _notifVm.totalBadgeCount;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded,
                        color: AppColors.navy, size: 26),
                    tooltip: 'Notifikasi Service',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationScreen(),
                        ),
                      ).then((_) => _notifVm.muatSemuaNotifikasi());
                    },
                  ),
                  if (count > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            count > 9 ? '9+' : '$count',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 4),

          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: 'Log Out',
            onPressed: () async =>
                await Supabase.instance.client.auth.signOut(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String unit,
      {String? subtitle}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Color(0xFF0F2042))),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w300,
                      color: Color(0xFF0F2042))),
              const SizedBox(width: 8),
              Text(unit,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 16),
            Text(subtitle,
                style:
                    TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          ]
        ],
      ),
    );
  }

  Widget _buildMainBanner(BuildContext context) {
    return AppPressableMotionCard(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const AddCarScreen())),
      child: Container(
        height: 220,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
              colors: [Color(0xFF0C1938), Color(0xFF142850)],
              begin: Alignment.bottomRight,
              end: Alignment.topLeft),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.deepOrange.shade800,
                    shape: BoxShape.circle),
                child:
                    const Icon(Icons.add, color: Colors.white, size: 20)),
            const SizedBox(height: 16),
            const Text('Add Customer / Car',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 8),
            Text(
                'Tambahkan Mobil Pelanggan baru',
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                    height: 1.5)),
          ],
        ),
      ),
    );
  }

  // ── Edit Records ──────────────────────────────
  Widget _buildEditRecordsCard(BuildContext context) {
    return AppPressableMotionCard(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const ServicesScreen())),
      child: Container(
        height: 220,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.edit_note_rounded,
                color: Color(0xFF0F2042), size: 32),
            const SizedBox(height: 16),
            const Text('Edit Data',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F2042))),
            const SizedBox(height: 8),
            Text(
                'Edit data Pelanggan',
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.5)),
          ],
        ),
      ),
    );
  }

  // ── Service Logistics Table ───────────────────
  Widget _buildServiceLogisticsTable() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Service Logistics',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F2042))),
                  const SizedBox(height: 4),
                  Text('Real-time status of the workshop floor',
                      style: TextStyle(color: Colors.grey.shade500)),
                ],
              ),
              OutlinedButton.icon(
                onPressed: _vm.muatServiceLogistics,
                icon: const Icon(Icons.refresh,
                    size: 18, color: Colors.black87),
                label: const Text('Refresh',
                    style: TextStyle(color: Colors.black87)),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // ✅ ListenableBuilder — lebih efisien dari addListener+setState
          ListenableBuilder(
            listenable: _vm,
            builder: (context, _) {
              if (_vm.isLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (_vm.errorMessage != null) {
                return Center(
                  child: Text(
                    _vm.errorMessage!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                );
              }

              if (_vm.serviceLogistics.isEmpty) {
                return const Center(
                  child: Text(
                    'Tidak ada order service yang sedang berjalan.',
                    style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic),
                  ),
                );
              }

              return _buildServiceLogisticsRows();
            },
          ),
        ],
      ),
    );
  }

  // ── Rows ──────────────────────────────────────
  Widget _buildServiceLogisticsRows() {
    return Column(
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FB),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: const [
              Expanded(flex: 2, child: _TableHeader('Vehicle')),
              Expanded(flex: 2, child: _TableHeader('Owner')),
              Expanded(flex: 3, child: _TableHeader('Order Detail')),
              Expanded(flex: 2, child: _TableHeader('Progress')),
              Expanded(flex: 1, child: _TableHeader('Status')),
              Expanded(flex: 1, child: _TableHeader('Date')),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // ✅ Pakai _vm.serviceLogistics
        ..._vm.serviceLogistics.map(
          (item) => _ServiceLogisticsRow(item: item),
        ),
      ],
    );
  }
}

class _ServiceLogisticsRow extends StatelessWidget {
  final ServiceLogisticsItem item;

  const _ServiceLogisticsRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final statusColor =
        item.status == 'Dikerjakan' ? Colors.blue : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border:
            Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: _TableCell(
              title   : item.licensePlate,
              subtitle: item.vehicleName.isEmpty ? '-' : item.vehicleName,
            ),
          ),
          Expanded(
            flex: 2,
            child: _TableCell(
              title   : item.ownerName,
              subtitle: 'Rp ${_formatHarga(item.totalBill)}',
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              item.serviceNames.isEmpty
                  ? '-'
                  : item.serviceNames.join(', '),
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF0F2042),
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value          : item.progress,
                      minHeight      : 8,
                      backgroundColor: Colors.grey.shade200,
                      valueColor     : AlwaysStoppedAnimation<Color>(
                          statusColor),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${item.completedItems}/${item.totalItems}',
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color        : statusColor.withOpacity(0.1),
                  borderRadius : BorderRadius.circular(20),
                  border       : Border.all(
                      color: statusColor.withOpacity(0.35)),
                ),
                child: Text(
                  item.status,
                  style: TextStyle(
                    color      : statusColor,
                    fontSize   : 11,
                    fontWeight : FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              DateFormat('dd MMM').format(item.tanggalMasuk),
              style: TextStyle(
                  fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatHarga(int harga) {
    return harga.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }
}

class _TableHeader extends StatelessWidget {
  final String label;
  const _TableHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize   : 11,
        fontWeight : FontWeight.bold,
        color      : Colors.grey.shade500,
      ),
    );
  }
}

// ── Widget: Table Cell ─────────────────────────
class _TableCell extends StatelessWidget {
  final String title;
  final String subtitle;
  const _TableCell({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize   : 13,
            fontWeight : FontWeight.bold,
            color      : Color(0xFF0F2042),
          ),
          maxLines : 1,
          overflow : TextOverflow.ellipsis,
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          maxLines : 1,
          overflow : TextOverflow.ellipsis,
        ),
      ],
    );
  }
}