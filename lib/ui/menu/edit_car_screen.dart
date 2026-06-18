import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../app_animations.dart';
import '../../viewModel/menu_sidebar_viewmodel.dart';
import '../../viewModel/car_viewmodel.dart';
import '../../app_colors.dart';

class EditCarScreen extends StatefulWidget {
  final Map<String, dynamic>? carData;
  const EditCarScreen({super.key, this.carData});

  @override
  State<EditCarScreen> createState() => _EditCarScreenState();
}

class _EditCarScreenState extends State<EditCarScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CarViewModel>(context, listen: false)
          .initForm(data: widget.carData);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _onSave() async {
    final vm          = Provider.of<CarViewModel>(context, listen: false);
    final nomorRangka = widget.carData?['nomor_rangka']?.toString() ?? '';

    final success = await vm.submitEditCar(nomorRangka);

    if (!mounted) return;
    if (success) {
      _snack('Data mobil berhasil diperbarui');
      Provider.of<NavigationViewModel>(context, listen: false)
          .goToGarageList();
      Navigator.pop(context);
    } else {
      _snack(vm.errorMessage ?? 'Gagal memperbarui data mobil');
    }
  }

  void _snack(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg)));

  // ── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            _TopBar(onBack: () => Navigator.pop(context)),
            Expanded(
              child: Consumer<CarViewModel>(
                builder: (context, vm, _) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(32, 28, 32, 48),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _HeroSection(carData: widget.carData),
                        const SizedBox(height: 28),
                        _TwoColumnLayout(
                          left: Column(
                            children: [
                              const _FormCard(
                                icon : Icons.settings_outlined,
                                title: 'Spesifikasi Teknis',
                                child: _TechnicalSpecsForm(),
                              ),
                              const SizedBox(height: 20),
                              const _FormCard(
                                icon : Icons.person_outline,
                                title: 'Identitas Pemilik',
                                child: _OwnerForm(),
                              ),
                            ],
                          ),
                          right: _ActionPanel(onSave: _onSave),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Top bar
// ─────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final VoidCallback onBack;
  const _TopBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.navy,
      padding: EdgeInsets.fromLTRB(
          24, MediaQuery.of(context).padding.top + 14, 24, 14),
      child: Row(
        children: [
          AppAnimatedBackButton(onTap: onBack),
          const SizedBox(width: 14),
          const Text(
            'Garage Plus',
            style: TextStyle(
              color       : Colors.white,
              fontSize    : 18,
              fontWeight  : FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          Container(
            margin : const EdgeInsets.only(left: 10),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color       : Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(6),
              border      : Border.all(
                  color: Colors.white.withOpacity(0.15), width: 0.5),
            ),
            child: const Text(
              'VEHICLE EDITOR',
              style: TextStyle(
                color        : Color(0xFF90CAF9),
                fontSize     : 9,
                fontWeight   : FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const Spacer(),
          Container(
            width: 260, height: 36,
            decoration: BoxDecoration(
              color       : Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(10),
              border      : Border.all(
                  color: Colors.white.withOpacity(0.12), width: 0.5),
            ),
            child: Row(
              children: [
                const SizedBox(width: 10),
                Icon(Icons.search, size: 16,
                    color: Colors.white.withOpacity(0.4)),
                const SizedBox(width: 8),
                Text(
                  'Cari kendaraan atau VIN...',
                  style: TextStyle(
                    fontSize: 12,
                    color   : Colors.white.withOpacity(0.35),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}




// ─────────────────────────────────────────────────────────────
//  Hero section
// ─────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  final Map<String, dynamic>? carData;

  const _HeroSection({
    required this.carData,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.read<CarViewModel>();
    final carName =
        (carData?['tipe_mobil'] ?? carData?['jenis_mobil'] ?? 'Unknown Vehicle')
            .toString()
            .toUpperCase();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color       : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border      : Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ACTIVE RECORD',
                            style: TextStyle(
                              fontSize     : 9,
                              fontWeight   : FontWeight.w700,
                              color        : AppColors.textGrey,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(carName,
                            style: const TextStyle(
                              fontSize  : 26,
                              fontWeight: FontWeight.w800,
                              color     : AppColors.navy,
                              height    : 1.1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Inventory Master Record — Edit Mode',
                            style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color       : const Color(0xFFEBF5FF),
                        borderRadius: BorderRadius.circular(10),
                        border      : Border.all(
                            color: const Color(0xFFB3D4F5), width: 0.5),
                      ),
                      child: const Column(
                        children: [
                          Text('STATUS',
                              style: TextStyle(
                                fontSize     : 9,
                                fontWeight   : FontWeight.w700,
                                color        : Color(0xFF5B8FC7),
                                letterSpacing: 0.8,
                              )),
                          SizedBox(height: 4),
                          Text('IN SERVICE',
                              style: TextStyle(
                                fontSize  : 13,
                                fontWeight: FontWeight.w700,
                                color     : Color(0xFF0C3A6B),
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _InlineField(
                        label     : 'LICENSE PLATE',
                        controller: vm.polisiCtrl,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _InlineField(
                        label     : 'VIN IDENTIFICATION',
                        controller: vm.rangkaCtrl,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const _InlineField({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
              fontSize     : 9,
              fontWeight   : FontWeight.w700,
              color        : AppColors.textGrey,
              letterSpacing: 0.8,
            )),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          style: const TextStyle(
            fontSize  : 17,
            fontWeight: FontWeight.w700,
            color     : AppColors.navy,
          ),
          decoration: InputDecoration(
            isDense       : true,
            contentPadding: const EdgeInsets.symmetric(vertical: 6),
            enabledBorder : UnderlineInputBorder(
                borderSide:
                    BorderSide(color: Colors.blue.shade100, width: 1.5)),
            focusedBorder : const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.navy, width: 2)),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Two column layout
// ─────────────────────────────────────────────────────────────

class _TwoColumnLayout extends StatelessWidget {
  final Widget left;
  final Widget right;

  const _TwoColumnLayout({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: left),
        const SizedBox(width: 20),
        SizedBox(width: 280, child: right),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Form card shell
// ─────────────────────────────────────────────────────────────

class _FormCard extends StatelessWidget {
  final IconData icon;
  final String   title;
  final Widget   child;

  const _FormCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color       : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border      : Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color       : const Color(0xFFF0F2F8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: AppColors.navy),
              ),
              const SizedBox(width: 12),
              Text(title,
                  style: const TextStyle(
                    fontSize  : 15,
                    fontWeight: FontWeight.w700,
                    color     : AppColors.navy,
                  )),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 16, bottom: 24),
            height: 0.5,
            color : AppColors.border,
          ),
          child,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Technical specs form
// ─────────────────────────────────────────────────────────────

class _TechnicalSpecsForm extends StatelessWidget {
  const _TechnicalSpecsForm();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CarViewModel>();
    return Column(
      children: [
        _FieldRow(children: [
          _InputField(label: 'Merek / Jenis', ctrl: vm.jenisCtrl),
          _InputField(label: 'Model / Tipe',  ctrl: vm.typeCtrl),
        ]),
        const SizedBox(height: 20),
        _FieldRow(children: [
          _InputField(label: 'Tahun Produksi', ctrl: vm.tahunCtrl,
              keyboardType: TextInputType.number),
          _InputField(label: 'No. Rangka', ctrl: vm.rangkaCtrl),
        ]),
        const SizedBox(height: 20),
        _FieldRow(children: [
          _DropdownField(
            label    : 'Tipe Mesin',
            value    : vm.tipeMesin,
            items    : CarViewModel.mesinOpts,
            onChanged: (v) => vm.setTipeMesin(v),
          ),
          _DropdownField(
            label    : 'Tipe Transmisi',
            value    : vm.tipeTransmisi,
            items    : CarViewModel.transmisiOpts,
            onChanged: (v) => vm.setTipeTransmisi(v),
          ),
        ]),
        const SizedBox(height: 20),
        _InputField(label: 'No. Mesin', ctrl: vm.mesinCtrl),
      ],
    );
  }
}

class _OwnerForm extends StatelessWidget {
  const _OwnerForm();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CarViewModel>();
    return Column(
      children: [
        // ── Sapaan + Nama Pemilik ──
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dropdown sapaan
              SizedBox(
                width: 110,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('SAPAAN',
                        style: TextStyle(
                          fontSize     : 10,
                          fontWeight   : FontWeight.w700,
                          color        : AppColors.textGrey,
                          letterSpacing: 0.4,
                        )),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: vm.sapaan,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded,
                          size: 18, color: AppColors.textGrey),
                      style: const TextStyle(
                        fontSize  : 14,
                        fontWeight: FontWeight.w500,
                        color     : AppColors.navy,
                      ),
                      decoration: const InputDecoration(
                        isDense       : true,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12, vertical: 11),
                        filled      : true,
                        fillColor   : Color(0xFFF8F9FC),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide  : BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide  : BorderSide(color: AppColors.navy, width: 1.5),
                        ),
                      ),
                      items: CarViewModel.sapaanOpts
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (v) { if (v != null) vm.setSapaan(v); },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Nama pemilik
              Expanded(
                child: _InputField(label: 'Nama Pemilik', ctrl: vm.ownerCtrl),
              ),
            ],
          ),
        ),

        // ── Telepon + Kota ──
        _FieldRow(children: [
          _InputField(label: 'No. Telepon', ctrl: vm.teleponCtrl,
              keyboardType: TextInputType.phone),
          _InputField(label: 'Kota', ctrl: vm.kotaCtrl),
        ]),
        const SizedBox(height: 20),

        // ── Nama Perusahaan (opsional) ──
        _InputField(label: 'Nama Perusahaan (opsional)', ctrl: vm.perusahaanCtrl),
        const SizedBox(height: 20),

        // ── Alamat (opsional) ──
        _InputField(label: 'Alamat Lengkap (opsional)', ctrl: vm.alamatCtrl, maxLines: 2),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Action panel (right column)
// ─────────────────────────────────────────────────────────────

class _ActionPanel extends StatelessWidget {
  final VoidCallback onSave;
  const _ActionPanel({required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Consumer<CarViewModel>(
      builder: (context, vm, _) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color       : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border      : Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    color       : const Color(0xFFF0F2F8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.bolt_outlined,
                      size: 18, color: AppColors.navy),
                ),
                const SizedBox(width: 12),
                const Text('Tindakan',
                    style: TextStyle(
                      fontSize  : 15,
                      fontWeight: FontWeight.w700,
                      color     : AppColors.navy,
                    )),
              ],
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              height: 0.5,
              color : AppColors.border,
            ),

            _SummaryChip(
              icon : Icons.directions_car_outlined,
              label: 'Mode',
              value: 'Edit Aktif',
            ),
            const SizedBox(height: 8),
            _SummaryChip(
              icon      : Icons.verified_user_outlined,
              label     : 'Audit Log',
              value     : 'Aktif',
              valueColor: AppColors.greenAccent,
            ),
            const SizedBox(height: 20),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: vm.isLoading ? null : onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor        : AppColors.navy,
                  foregroundColor        : Colors.white,
                  disabledBackgroundColor: const Color(0xFFB0BAC9),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: vm.isLoading
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save_outlined, size: 18),
                          SizedBox(width: 8),
                          Text('Simpan Perubahan',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize  : 14,
                              )),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 10),

            // Discard button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textGrey,
                  side : const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Batalkan',
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              ),
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color       : const Color(0xFFFAFBFC),
                borderRadius: BorderRadius.circular(10),
                border      : Border.all(color: AppColors.border),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 14, color: AppColors.textGrey),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Semua perubahan tercatat dalam audit log sistem.',
                      style: TextStyle(
                        fontSize: 11,
                        color   : AppColors.textGrey,
                        height  : 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   value;
  final Color    valueColor;

  const _SummaryChip({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor = AppColors.navy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color       : const Color(0xFFF8F9FC),
        borderRadius: BorderRadius.circular(10),
        border      : Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textGrey),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                fontSize  : 12,
                fontWeight: FontWeight.w600,
                color     : valueColor,
              )),
        ],
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  final List<Widget> children;
  const _FieldRow({required this.children});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: children
          .expand((w) => [Expanded(child: w), const SizedBox(width: 20)])
          .toList()
        ..removeLast(),
    );
  }
}

class _InputField extends StatelessWidget {
  final String                label;
  final TextEditingController ctrl;
  final TextInputType         keyboardType;
  final int                   maxLines;

  const _InputField({
    required this.label,
    required this.ctrl,
    this.keyboardType = TextInputType.text,
    this.maxLines     = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
              fontSize     : 10,
              fontWeight   : FontWeight.w700,
              color        : AppColors.textGrey,
              letterSpacing: 0.4,
            )),
        const SizedBox(height: 6),
        TextFormField(
          controller  : ctrl,
          maxLines    : maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(
            fontSize  : 14,
            fontWeight: FontWeight.w500,
            color     : AppColors.navy,
          ),
          decoration: InputDecoration(
            isDense       : true,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 11),
            filled      : true,
            fillColor   : const Color(0xFFF8F9FC),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide  : const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide  : const BorderSide(color: AppColors.navy, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String            label;
  final String?           value;
  final List<String>      items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
              fontSize     : 10,
              fontWeight   : FontWeight.w700,
              color        : AppColors.textGrey,
              letterSpacing: 0.4,
            )),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          icon : const Icon(Icons.keyboard_arrow_down_rounded,
              size: 18, color: AppColors.textGrey),
          style: const TextStyle(
            fontSize  : 14,
            fontWeight: FontWeight.w500,
            color     : AppColors.navy,
          ),
          decoration: InputDecoration(
            isDense       : true,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 11),
            filled      : true,
            fillColor   : const Color(0xFFF8F9FC),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide  : const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide  : const BorderSide(color: AppColors.navy, width: 1.5),
            ),
          ),
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
