import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../app_colors.dart';
import '../../../models/order_kerja_models.dart';
import '../../../viewModel/order_kerja_viewmodel.dart';
import 'service_catalog_list.dart';

class TambahPekerjaanSheet extends StatefulWidget {
  const TambahPekerjaanSheet({Key? key}) : super(key: key);

  static Future<Map<String, dynamic>?> show(BuildContext context) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const TambahPekerjaanSheet(),
    );
  }

  @override
  State<TambahPekerjaanSheet> createState() => _TambahPekerjaanSheetState();
}

class _TambahPekerjaanSheetState extends State<TambahPekerjaanSheet> {
  final _hargaController = TextEditingController();
  OrderKerja? _dipilih;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderKerjaViewModel>().loadKerja();
    });
  }

  @override
  void dispose() {
    _hargaController.dispose();
    super.dispose();
  }

  void _handlePilih(BuildContext ctx, dynamic jasa, List<dynamic> _) {
    final item = jasa as OrderKerja;
    setState(() {
      if (_dipilih?.id == item.id) {
        _dipilih = null;
        _hargaController.text = '';
      } else {
        _dipilih = item;
        _hargaController.text = _formatRupiah(item.estimasiHarga);
      }
    });
  }

  void _konfirmasi() {
    if (_dipilih == null) return;
    final harga = int.tryParse(_hargaController.text.replaceAll('.', '')) ??
        _dipilih!.estimasiHarga;
    Navigator.pop(context, {
      'id': _dipilih!.id,
      'nama': _dipilih!.nama,
      'hargaFinal': harga,
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;

    return Container(
      height: screenH * 0.88,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // ── Handle bar ─────────────────────────────────────
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          // ── Header ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                const Text(
                  '+ Tambah Pekerjaan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppColors.navy),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // ── Katalog pekerjaan (pakai ServiceCatalogList) ───
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Consumer<OrderKerjaViewModel>(
                builder: (context, vm, _) {
                  return ServiceCatalogList(
                    vm: vm,
                    onServiceSelected: _handlePilih,
                  );
                },
              ),
            ),
          ),
          // ── Panel konfirmasi (muncul jika ada yang dipilih) ─
          if (_dipilih != null)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _dipilih!.nama,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text(
                        'Harga Final (Rp): ',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _hargaController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            CurrencyInputFormatter()
                          ],
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            filled: true,
                            fillColor: const Color(0xFFF5F6FA),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _konfirmasi,
                    icon: const Icon(Icons.add_task, color: Colors.white),
                    label: const Text(
                      'Tambahkan ke Work Order',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navy,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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

String _formatRupiah(int v) => v.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    final intValue = int.tryParse(newValue.text.replaceAll(RegExp(r'[^0-9]'), ''));
    if (intValue == null) return newValue;
    final newString = intValue.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return TextEditingValue(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}
