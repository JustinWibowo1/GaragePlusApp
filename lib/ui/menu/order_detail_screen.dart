import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../../models/order_service_models.dart';
import '../../models/customer_models.dart';
import '../../viewModel/order_detail/order_detail_viewmodel.dart';
import '../../viewModel/order_detail/service_reminder_viewmodel.dart';
import 'order_item_detail_screen.dart';
import '../../component/app_colors.dart';
import '../../component/component_apps.dart';
import '../widgets/order_detail/hero_header.dart';
import '../widgets/order_detail/service_reminder_panel.dart';
import '../widgets/order_detail/service_history_card.dart';

class OrderDetailScreen extends StatefulWidget {
  final Customer customer;

  const OrderDetailScreen({
    Key? key,
    required this.customer,
  }) : super(key: key);

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final OrderDetailViewModel _vm = OrderDetailViewModel();
  final ServiceReminderViewModel _reminderVm = ServiceReminderViewModel();
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _vm.muatOrderByCustomer(
      widget.customer.nomorRangka,
      tipeMesin: widget.customer.tipeMesin,
      tipeTransmisi: widget.customer.tipeTransmisi,
    ).then((_) {
      // Dapatkan max km dari daftar order
      final kmDariOrder = _vm.daftarOrder.isEmpty 
          ? 0 
          : _vm.daftarOrder.map((o) => o.kilometer).reduce(max);
      _reminderVm.muatRemindersDanKm(widget.customer.nomorRangka, kmDariOrder);
    });
    _searchCtrl.addListener(
      () => setState(() => _searchQuery = _searchCtrl.text.toLowerCase()),
    );
  }

  @override
  void dispose() {
    _vm.dispose();
    _reminderVm.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<OrderServiceSummary> get _filteredOrders {
    if (_searchQuery.isEmpty) return _vm.daftarOrder;
    return _vm.daftarOrder
        .where(
          (o) =>
              o.nomorWoDisplay.toLowerCase().contains(_searchQuery) ||
              o.catatanKeluhan.toLowerCase().contains(_searchQuery) ||
              o.status.toLowerCase().contains(_searchQuery),
        )
        .toList();
  }

  void _openDetail(OrderServiceSummary order) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      AppSlideUpRoute(
        page: OrderItemDetailScreen(
          vm: _vm,
          reminderVm: _reminderVm,
          nomorWo: order.nomorWo,
          tanggal: order.tanggalMasuk,
          customer: widget.customer,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: ListenableBuilder(
          listenable: Listenable.merge([_vm, _reminderVm]),
          builder: (context, _) {
            final reminders = _reminderVm.serviceReminders
                .where((r) => r.isOverdue || r.isUrgent)
                .toList();

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: HeroHeader(
                    customer: widget.customer,
                    totalVisit: _vm.daftarOrder.length,
                    kmTerakhir: _reminderVm.kmTerakhir,
                  ),
                ),
                SliverToBoxAdapter(
                  child: RoundedTop(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Service Reminder Panel ───────────────
                        if (reminders.isNotEmpty) ...[
                          ServiceReminderPanel(reminders: reminders),
                          const SizedBox(height: 16),
                        ],
                        AppSearchBar(
                            controller: _searchCtrl,
                            hintText: 'Cari nomor WO atau keluhan...'),
                        const SizedBox(height: 12),
                        const Padding(
                          padding: EdgeInsets.only(left: 4, bottom: 8),
                          child: Text(
                            'RIWAYAT SERVICE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _buildContent(),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_vm.isLoading) {
      return const SliverFillRemaining(
        child: Center(
            child: CircularProgressIndicator(color: AppColors.greenAccent)),
      );
    }

    if (_vm.daftarOrder.isEmpty) {
      return const SliverFillRemaining(
        child: AppEmptyState(
          title: 'Belum ada riwayat service.',
          subtitle: 'Data service akan muncul di sini.',
        ),
      );
    }

    final orders = _filteredOrders;

    if (orders.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off_rounded,
                  size: 48, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text(
                'Tidak ada hasil untuk "$_searchQuery"',
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ServiceCard(
              order: orders[index],
              onTap: () => _openDetail(orders[index]),
            ),
          ),
          childCount: orders.length,
        ),
      ),
    );
  }
}
