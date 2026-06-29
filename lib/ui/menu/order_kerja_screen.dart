import 'package:flutter/material.dart';
import '../../models/order_kerja_models.dart';
import '../../models/customer_models.dart';
import '../../viewModel/order_kerja_viewmodel.dart';
import '../../app_colors.dart';
import '../widgets/order_kerja/vehicle_info_card.dart';
import '../widgets/order_kerja/complaint_form_card.dart';
import '../widgets/order_kerja/service_catalog_list.dart';
import '../widgets/order_kerja/order_summary_panel.dart';

class OrderKerjaScreen extends StatefulWidget {
  final Customer customer;

  const OrderKerjaScreen({
    Key? key,
    required this.customer,
  }) : super(key: key);

  @override
  State<OrderKerjaScreen> createState() => _OrderKerjaScreenState();
}

class _OrderKerjaScreenState extends State<OrderKerjaScreen> {
  final OrderKerjaViewModel _orderKerjaViewModel = OrderKerjaViewModel();
  final TextEditingController _keluhanController = TextEditingController();
  final TextEditingController _kilometerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _orderKerjaViewModel.muatKerjaUntukMobil(
      mesin: widget.customer.tipeMesin,
      transmisi: widget.customer.tipeTransmisi,
    );
    // Pre-fill kilometer dari odometer terakhir yang sudah tersimpan
    if (widget.customer.odometerTerakhir > 0) {
      final formatted = widget.customer.odometerTerakhir.toString().replaceAllMapped(
            RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]}.',
          );
      _kilometerController.text = formatted;
      _orderKerjaViewModel.setKilometer(widget.customer.odometerTerakhir);
    }
  }

  @override
  void dispose() {
    _orderKerjaViewModel.dispose();
    _keluhanController.dispose();
    _kilometerController.dispose();
    super.dispose();
  }

  String _formatRupiah(int value) {
    return value.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
  }

  /// Dialog pilih sparepart berdasarkan kategori pekerjaan
  Future<void> _tampilDialogPilihSparepart(OrderKerja jasa) async {
    // Muat sparepart sesuai kategori pekerjaan
    await _orderKerjaViewModel.muatSparepartUntukPekerjaan(jasa);

    // Track sparepart yang dipilih (temporary)
    final Map<String, SparepartEntry> tempSelected = {};

    // Jika sudah ada pilihan sebelumnya, load ke temp
    final existing = _orderKerjaViewModel.sparepartPerPekerjaan[jasa.id];
    if (existing != null) {
      for (final entry in existing) {
        tempSelected[entry.sparepart.id] = SparepartEntry(
          sparepart: entry.sparepart,
          qty: entry.qty,
        );
      }
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Pilih Sparepart',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                'Untuk: ${jasa.nama}',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                children: [
                  if (jasa.kategoriSparepart != null)
                    Chip(
                      label: Text(jasa.kategoriSparepart!,
                          style: const TextStyle(fontSize: 11)),
                      backgroundColor: Colors.blue.shade50,
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ],
          ),
          content: SizedBox(
            width: 450,
            height: 450,
            child: ListenableBuilder(
              listenable: _orderKerjaViewModel,
              builder: (context, _) {
                if (_orderKerjaViewModel.isLoadingSparepart) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (_orderKerjaViewModel.daftarSparepart.isEmpty) {
                  return const Center(
                      child: Text('Tidak ada sparepart tersedia.'));
                }
                return Column(
                  children: [
                    // Search
                    TextField(
                      onChanged: (val) {
                        // Filter client-side dari daftar yang sudah dimuat
                        setDialogState(() {});
                      },
                      decoration: InputDecoration(
                        hintText: 'Cari sparepart...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.separated(
                        itemCount: _orderKerjaViewModel.daftarSparepart.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final sp =
                              _orderKerjaViewModel.daftarSparepart[index];
                          final isSelected = tempSelected.containsKey(sp.id);
                          final entry = tempSelected[sp.id];

                          return ListTile(
                            selected: isSelected,
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.blue.shade100
                                    : Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.inventory_2,
                                color: AppColors.navy,
                                size: 20,
                              ),
                            ),
                            title: Text(sp.displayName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13)),
                            subtitle: Text(
                              'Rp ${_formatRupiah(sp.hargaJual)}${sp.spesifikasi != null ? ' • ${sp.spesifikasi}' : ''} • ${sp.kategori}',
                              style: TextStyle(
                                  color: Colors.grey[500], fontSize: 11),
                            ),
                            trailing: isSelected
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                            Icons.remove_circle_outline,
                                            size: 20),
                                        onPressed: () {
                                          setDialogState(() {
                                            if (entry!.qty > 1) {
                                              entry.qty--;
                                            } else {
                                              tempSelected.remove(sp.id);
                                            }
                                          });
                                        },
                                      ),
                                      Text('${entry?.qty ?? 1}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      IconButton(
                                        icon: const Icon(
                                            Icons.add_circle_outline,
                                            size: 20),
                                        onPressed: () {
                                          setDialogState(() {
                                            entry!.qty++;
                                          });
                                        },
                                      ),
                                    ],
                                  )
                                : null,
                            onTap: () {
                              setDialogState(() {
                                if (isSelected) {
                                  tempSelected.remove(sp.id);
                                } else {
                                  tempSelected[sp.id] =
                                      SparepartEntry(sparepart: sp);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                    if (tempSelected.isNotEmpty) ...[
                      const Divider(),
                      Text(
                        '${tempSelected.length} item dipilih — Rp ${_formatRupiah(tempSelected.values.fold<int>(0, (sum, e) => sum + e.subtotal))}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                _orderKerjaViewModel.tambahKeKeranjangDenganSparepart(
                  jasa,
                  tempSelected.values.toList(),
                );
                Navigator.pop(context);
              },
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.blue[700]),
              child: const Text('Konfirmasi',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _handleServiceSelection(BuildContext context, dynamic jasaDynamic, List<dynamic> sparepartTerpilih) {
    OrderKerja jasa = jasaDynamic as OrderKerja;
    final isSelected = _orderKerjaViewModel.isJasaDipilih(jasa);
    if (isSelected) {
      _orderKerjaViewModel.hapusDariKeranjang(jasa);
    } else if (jasa.requiresSparepart) {
      _tampilDialogPilihSparepart(jasa);
    } else {
      _orderKerjaViewModel.toggleKeranjang(jasa);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text('Garage Plus',
            style:
                TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 7,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Order Kerja',
                        style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.navy)),
                    const SizedBox(height: 24),

                    VehicleInfoCard(customer: widget.customer),
                    const SizedBox(height: 32),

                    ComplaintFormCard(
                      vm: _orderKerjaViewModel,
                      keluhanController: _keluhanController,
                      kilometerController: _kilometerController,
                    ),
                    const SizedBox(height: 32),

                    ServiceCatalogList(
                      vm: _orderKerjaViewModel,
                      onServiceSelected: _handleServiceSelection,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 32),

            // ── Sidebar Ringkasan ──
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                child: OrderSummaryPanel(
                  vm: _orderKerjaViewModel,
                  customer: widget.customer,
                  keluhanController: _keluhanController,
                  kilometerController: _kilometerController,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
