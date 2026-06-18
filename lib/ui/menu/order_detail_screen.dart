import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/order_service_models.dart';
import '../../models/order_kerja_models.dart';
import '../../viewModel/order_detail_viewmodel.dart';
import 'order_item_detail_screen.dart';
import '../../app_colors.dart';
import '../../component_apps.dart';

const _kMonths = [
  '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des',
];

String _formatCurrency(int amount) => amount
    .toString()
    .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');


class OrderDetailScreen extends StatefulWidget {
  final String customerId;
  final String nomorPolisi;
  final String namaPemilik;
  final String telepon;
  final String alamat;
  final String merkMobil;
  final String typeMobil;
  final String tahun;
  final String noRangka;
  final String noMesin;
  final String tipeMesin;     // untuk filter reminder
  final String tipeTransmisi; // untuk filter reminder

  const OrderDetailScreen({
    Key? key,
    required this.customerId,
    required this.nomorPolisi,
    required this.namaPemilik,
    this.telepon       = '',
    this.alamat        = '',
    this.merkMobil     = '',
    this.typeMobil     = '',
    this.tahun         = '',
    this.noRangka      = '',
    this.noMesin       = '',
    this.tipeMesin     = '',
    this.tipeTransmisi = '',
  }) : super(key: key);

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final OrderDetailViewModel _vm          = OrderDetailViewModel();
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _vm.muatOrderByCustomer(
      widget.customerId,
      tipeMesin     : widget.tipeMesin,
      tipeTransmisi : widget.tipeTransmisi,
    );
    _searchCtrl.addListener(
      () => setState(() => _searchQuery = _searchCtrl.text.toLowerCase()),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<OrderServiceSummary> get _filteredOrders {
    if (_searchQuery.isEmpty) return _vm.daftarOrder;
    return _vm.daftarOrder.where((o) =>
      o.nomorWoDisplay.toLowerCase().contains(_searchQuery) ||
      o.catatanKeluhan.toLowerCase().contains(_searchQuery) ||
      o.status.toLowerCase().contains(_searchQuery),
    ).toList();
  }

  void _openDetail(OrderServiceSummary order) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      AppSlideUpRoute(
        page: OrderItemDetailScreen(
          vm          : _vm,
          nomorWo     : order.nomorWo,
          nomorPolisi : widget.nomorPolisi,
          namaPemilik : widget.namaPemilik,
          tanggal     : order.createdAt,
          telepon     : widget.telepon,
          alamat      : widget.alamat,
          merkMobil   : widget.merkMobil,
          typeMobil   : widget.typeMobil,
          tahun       : widget.tahun,
          noRangka    : widget.noRangka,
          noMesin     : widget.noMesin,
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
          listenable: _vm,
          builder: (context, _) {
            final reminders = _vm.serviceReminders
                .where((r) => r.isOverdue || r.isUrgent)
                .toList();

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _HeroHeader(
                    widget    : widget,
                    totalVisit: _vm.daftarOrder.length,
                    kmTerakhir: _vm.kmTerakhir,
                  ),
                ),
                SliverToBoxAdapter(
                  child: _RoundedTop(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Service Reminder Panel ───────────────
                        if (reminders.isNotEmpty) ...[
                          _ServiceReminderPanel(reminders: reminders),
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
                              fontSize     : 10,
                              fontWeight   : FontWeight.w700,
                              color        : Colors.grey,
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
                style:
                    const TextStyle(color: Colors.grey, fontSize: 14),
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
            child: _ServiceCard(
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

// ─────────────────────────────────────────────────────────────
//  Hero header
// ─────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  final OrderDetailScreen widget;
  final int totalVisit;
  final int kmTerakhir;

  const _HeroHeader({
    required this.widget,
    required this.totalVisit,
    required this.kmTerakhir,
  });

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
            fontSize     : 20,
            fontWeight   : FontWeight.w700,
            color        : Colors.white,
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
          widget.namaPemilik,
          style: const TextStyle(
            fontSize  : 26,
            fontWeight: FontWeight.w700,
            color     : Colors.white,
            height    : 1.1,
          ),
        ),
        const SizedBox(height: 8),
        _MetaChip(
            icon : Icons.directions_car_outlined,
            label: 'Nomor Polisi:  ${widget.nomorPolisi}'),
        if (widget.merkMobil.isNotEmpty) ...[
          const SizedBox(height: 4),
          _MetaChip(
              icon : Icons.build_outlined,
              label: '${widget.merkMobil} ${widget.typeMobil}'),
        ],
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label   : 'TOTAL KUNJUNGAN',
            value   : totalVisit == 0 ? '-' : '$totalVisit',
            subtitle: 'kali service',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label   : 'KM TERAKHIR',
            value   : kmTerakhir == 0 ? '-' : _formatCurrency(kmTerakhir),
            subtitle: 'kilometer',
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Service Reminder Panel
// ─────────────────────────────────────────────────────────────

class _ServiceReminderPanel extends StatefulWidget {
  final List<ServiceReminderItem> reminders;
  const _ServiceReminderPanel({required this.reminders});

  @override
  State<_ServiceReminderPanel> createState() => _ServiceReminderPanelState();
}

class _ServiceReminderPanelState extends State<_ServiceReminderPanel> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final overdueCount = widget.reminders.where((r) => r.isOverdue).length;
    final urgentCount  = widget.reminders.where((r) => r.isUrgent && !r.isOverdue).length;

    return Container(
      decoration: BoxDecoration(
        color       : const Color(0xFFFFF8F0),
        borderRadius: BorderRadius.circular(14),
        border      : Border.all(color: const Color(0xFFFFD080), width: 1),
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
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color       : const Color(0xFFFF9800).withOpacity(0.15),
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
                            fontSize     : 10,
                            fontWeight   : FontWeight.w800,
                            color        : Color(0xFFBF6000),
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _buildSummaryText(overdueCount, urgentCount),
                          style: const TextStyle(
                            fontSize  : 12,
                            fontWeight: FontWeight.w500,
                            color     : Color(0xFF8A5200),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size : 20,
                    color: const Color(0xFFBF6000),
                  ),
                ],
              ),
            ),
          ),

          // ── List ───────────────────────────────────────
          if (_expanded) ...[
            Container(height: 0.5, color: const Color(0xFFFFD080)),
            ...widget.reminders.map((r) => _ReminderRow(item: r)),
          ],
        ],
      ),
    );
  }

  String _buildSummaryText(int overdue, int urgent) {
    final parts = <String>[];
    if (overdue > 0) parts.add('$overdue sudah lewat jadwal');
    if (urgent  > 0) parts.add('$urgent hampir jatuh tempo');
    return parts.join(' • ');
  }
}

class _ReminderRow extends StatelessWidget {
  final ServiceReminderItem item;
  const _ReminderRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final isOverdue = item.isOverdue;

    final Color labelColor = isOverdue
        ? const Color(0xFFD32F2F)
        : const Color(0xFFE65100);
    final Color bgColor = isOverdue
        ? const Color(0xFFFFEBEE)
        : const Color(0xFFFFF3E0);
    final String badgeText = isOverdue
        ? 'OVERDUE'
        : 'SEGERA';
    final String desc = isOverdue
        ? 'Lewat ${_formatCurrency(item.sisaKm.abs())} km dari jadwal'
        : 'Sisa ${_formatCurrency(item.sisaKm)} km';

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
            size : 16,
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
                    fontSize  : 13,
                    fontWeight: FontWeight.w600,
                    color     : isOverdue
                        ? const Color(0xFFB71C1C)
                        : const Color(0xFF6D4C00),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 11,
                    color   : isOverdue
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
              color       : bgColor,
              borderRadius: BorderRadius.circular(6),
              border      : Border.all(color: labelColor.withOpacity(0.35)),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                fontSize     : 9,
                fontWeight   : FontWeight.w800,
                color        : labelColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Rounded top transition
// ─────────────────────────────────────────────────────────────

class _RoundedTop extends StatelessWidget {
  final Widget child;
  const _RoundedTop({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color       : AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Service card
// ─────────────────────────────────────────────────────────────

class _ServiceCard extends StatefulWidget {
  final OrderServiceSummary order;
  final VoidCallback onTap;

  const _ServiceCard({required this.order, required this.onTap});

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync   : this,
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
    final order   = widget.order;
    AppStatusColors.of(order.status);
    final pending = AppStatusColors.isPending(order.status);

    return MouseRegion(
      cursor  : SystemMouseCursors.click,
      onEnter : (_) => setState(() => _isHovered = true),
      onExit  : (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () async {
          await _ctrl.forward();
          await _ctrl.reverse();
          widget.onTap();
        },
        onTapDown  : (_) => _ctrl.forward(),
        onTapCancel: ()  => _ctrl.reverse(),
        child: ScaleTransition(
          scale: _scale,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve   : Curves.easeOut,
            decoration: BoxDecoration(
              color       : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border      : Border.all(
                color: _isHovered
                    ? const Color(0xFFCCCCCC)
                    : AppColors.greyBg,
              ),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color     : Colors.black.withOpacity(0.10),
                        blurRadius: 16,
                        offset    : const Offset(0, 6),
                      )
                    ]
                  : [
                      BoxShadow(
                        color     : Colors.black.withOpacity(0.03),
                        blurRadius: 4,
                        offset    : const Offset(0, 2),
                      )
                    ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _DateColumn(date: order.createdAt, pending: pending),
                    Expanded(
                      child: Padding(
                        padding:
                            const EdgeInsets.fromLTRB(12, 12, 14, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  order.nomorWoDisplay,
                                  style: const TextStyle(
                                    fontSize     : 11,
                                    fontWeight   : FontWeight.w700,
                                    color        : AppColors.blueLink,
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
                                fontSize  : 13,
                                fontWeight: FontWeight.w600,
                                color     : AppColors.navy,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 10),
                            const Divider(
                                height: 1, color: AppColors.greyBg),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                _KmChip(km: order.kilometer),
                                Text(
                                  'Rp ${_formatCurrency(order.totalTagihan)}',
                                  style: const TextStyle(
                                    fontSize  : 13,
                                    fontWeight: FontWeight.w700,
                                    color     : AppColors.navy,
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

// ─────────────────────────────────────────────────────────────
//  Card sub-widgets
// ─────────────────────────────────────────────────────────────

class _DateColumn extends StatelessWidget {
  final DateTime date;
  final bool pending;

  const _DateColumn({required this.date, required this.pending});

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
              fontSize  : 20,
              fontWeight: FontWeight.w700,
              color     : AppColors.navy,
              height    : 1.0,
            ),
          ),
          Text(
            _kMonths[date.month],
            style: const TextStyle(
              fontSize     : 10,
              fontWeight   : FontWeight.w700,
              color        : AppColors.navy,
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

class _KmChip extends StatelessWidget {
  final int km;
  const _KmChip({required this.km});

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

// ─────────────────────────────────────────────────────────────
//  Header sub-widgets
// ─────────────────────────────────────────────────────────────

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

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
            color   : Colors.white.withOpacity(0.55),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;

  const _StatCard({
    required this.label,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color       : Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border      : Border.all(
            color: Colors.white.withOpacity(0.12), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize     : 9,
              fontWeight   : FontWeight.w700,
              color        : Colors.white.withOpacity(0.4),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize  : 24,
              fontWeight: FontWeight.w700,
              color     : Colors.white,
              height    : 1.0,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color   : Colors.white.withOpacity(0.35),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  EOF
// ─────────────────────────────────────────────────────────────