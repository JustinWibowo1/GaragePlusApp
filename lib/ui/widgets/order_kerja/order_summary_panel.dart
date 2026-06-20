import 'package:flutter/material.dart';
import '../../../app_colors.dart';
import '../../../models/customer_models.dart';
import '../../../viewModel/order_kerja_viewmodel.dart';

class OrderSummaryPanel extends StatelessWidget {
  final OrderKerjaViewModel vm;
  final Customer customer;
  final TextEditingController keluhanController;
  final TextEditingController kilometerController;

  const OrderSummaryPanel({
    Key? key,
    required this.vm,
    required this.customer,
    required this.keluhanController,
    required this.kilometerController,
  }) : super(key: key);

  String _formatRupiah(int value) {
    return value.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 80,
          width: double.infinity,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200)),
          child: const Center(child: Text('Area Teknisi')),
        ),
        const SizedBox(height: 24),
        ListenableBuilder(
          listenable: vm,
          builder: (context, child) {
            final keranjang = vm.keranjangJasa;

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  color: AppColors.navyDarkest,
                  borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ringkasan Order',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  if (keranjang.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Text('Belum ada jasa yang dipilih.',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontStyle: FontStyle.italic)),
                    ),
                  ...keranjang.map((jasa) {
                    final spareparts = vm.sparepartPerPekerjaan[jasa.id] ?? [];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                  child: Text('• ${jasa.nama}',
                                      style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 14))),
                              Text('Rp ${_formatRupiah(jasa.estimasiHarga)}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13)),
                            ],
                          ),
                          ...spareparts.map((sp) => Padding(
                                padding:
                                    const EdgeInsets.only(left: 16, top: 4),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        '↳ ${sp.sparepart.displayName} x${sp.qty}',
                                        style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.6),
                                            fontSize: 12)),
                                    Text('Rp ${_formatRupiah(sp.subtotal)}',
                                        style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.7),
                                            fontSize: 12)),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    );
                  }).toList(),
                  const Divider(color: Colors.white24, height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Estimasi',
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                      Text('Rp ${_formatRupiah(vm.totalEstimasi)}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: keranjang.isEmpty
                          ? null
                          : () async {
                              // Validasi kilometer
                              if (vm.kilometer <= 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        '⚠️ Masukkan kilometer kendaraan terlebih dahulu'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Menyimpan pesanan...')),
                              );
                              bool sukses = await vm.simpanOrderKerja(
                                customerId: customer.nomorRangka,
                                catatanKeluhan: keluhanController.text,
                              );
                              if (sukses) {
                                keluhanController.clear();
                                kilometerController.clear();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('✅ Order berhasil disimpan!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('❌ Gagal menyimpan order.'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        disabledBackgroundColor: Colors.white12,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Buat Order Kerja',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
