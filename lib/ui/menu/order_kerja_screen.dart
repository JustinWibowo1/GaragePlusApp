import 'package:flutter/material.dart';
import '../../models/order_kerja_models.dart';
import '../../viewModel/order_kerja_viewmodel.dart';
import '../../app_colors.dart';
import '../../component_apps.dart';

class OrderKerjaScreen extends StatefulWidget {
  final String customerId; // nomor_rangka
  final String nomorPolisi;
  final String namaMobil;
  final String nomorRangka;
  final String mesinMobil;
  final String transmisiMobil;
  final String namaPemilik;
  final String nomorTelepon;
  final String alamat;
  final String nomorMesin;
  final int    odometerTerakhir; // ← dari tabel customer

  const OrderKerjaScreen({
    Key? key,
    required this.customerId,
    required this.nomorPolisi,
    required this.namaMobil,
    required this.nomorRangka,
    required this.mesinMobil,
    required this.transmisiMobil,
    required this.namaPemilik,
    required this.nomorTelepon,
    required this.alamat,
    required this.nomorMesin,
    this.odometerTerakhir = 0,
  }) : super(key: key);

  @override
  State<OrderKerjaScreen> createState() => _OrderKerjaScreenState();
}

class _OrderKerjaScreenState extends State<OrderKerjaScreen> {
  final OrderKerjaViewModel _orderKerjaViewModel = OrderKerjaViewModel();
  final TextEditingController _keluhanController    = TextEditingController();
  final TextEditingController _kilometerController  = TextEditingController();

  @override
  void initState() {
    super.initState();
    _orderKerjaViewModel.muatKerjaUntukMobil(
      mesin     : widget.mesinMobil,
      transmisi : widget.transmisiMobil,
    );
    // Pre-fill kilometer dari odometer terakhir yang sudah tersimpan
    if (widget.odometerTerakhir > 0) {
      _kilometerController.text = widget.odometerTerakhir.toString();
      _orderKerjaViewModel.setKilometer(widget.odometerTerakhir);
    }
  }

  @override
  void dispose() {
    _keluhanController.dispose();
    _kilometerController.dispose();
    super.dispose();
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                children: jasa.kategoriSparepart.map((k) => Chip(
                  label: Text(k.kategoriNama, style: const TextStyle(fontSize: 11)),
                  backgroundColor: Colors.blue.shade50,
                  visualDensity: VisualDensity.compact,
                )).toList(),
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
                  return const Center(child: Text('Tidak ada sparepart tersedia.'));
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
                          final sp = _orderKerjaViewModel.daftarSparepart[index];
                          final isSelected = tempSelected.containsKey(sp.id);
                          final entry = tempSelected[sp.id];

                          return ListTile(
                            selected: isSelected,
                            leading: Container(
                              width: 40, height: 40,
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
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            subtitle: Text(
                              'Rp ${_formatRupiah(sp.hargaJual)} • Stok: ${sp.stok} • ${sp.kategoriNama ?? ""}',
                              style: TextStyle(color: Colors.grey[500], fontSize: 11),
                            ),
                            trailing: isSelected
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle_outline, size: 20),
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
                                          style: const TextStyle(fontWeight: FontWeight.bold)),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle_outline, size: 20),
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
                                  tempSelected[sp.id] = SparepartEntry(sparepart: sp);
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
                        '${tempSelected.length} item dipilih — Rp ${_formatRupiah(
                          tempSelected.values.fold<int>(0, (sum, e) => sum + e.subtotal)
                        )}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[700]),
              child: const Text('Konfirmasi', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  String _formatRupiah(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }

  Widget _buildInfoColumn(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
          style: const TextStyle(
              fontSize: 10, color: Colors.grey,
              fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        const SizedBox(height: 6),
        Text(value,
          style: const TextStyle(
              fontSize: 15, color: AppColors.navy,
              fontWeight: FontWeight.w800, letterSpacing: 0.5),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text('Garage Plus',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
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
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.navy)),
                    const SizedBox(height: 24),

                    // ── Card Info Mobil ──
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 120, width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                              gradient: const LinearGradient(
                                  colors: [AppColors.navyDeep, AppColors.navyDark],
                                  begin: Alignment.topLeft, end: Alignment.bottomRight),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(widget.namaMobil.toUpperCase(),
                                        style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                                    Text('${widget.namaPemilik} (${widget.nomorTelepon})',
                                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text('${widget.mesinMobil} • ${widget.transmisiMobil}',
                                        style: const TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 0.5)),
                                    Text(widget.alamat,
                                        style: const TextStyle(color: Colors.white, fontSize: 14)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildInfoColumn('Nomor Polisi', widget.nomorPolisi),
                                _buildInfoColumn('Nomor Rangka', widget.nomorRangka),
                                _buildInfoColumn('Nomor Mesin', widget.nomorMesin),
                                _buildInfoColumn('ODOMETER', '- KM'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Catatan Keluhan ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: const [
                            Icon(Icons.edit_note, color: AppColors.navy, size: 24),
                            SizedBox(width: 8),
                            Text('Catatan Keluhan Konsumen',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.navy)),
                          ]),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _keluhanController,
                            maxLines: 5,
                            decoration: InputDecoration(
                              hintText: 'Dokumentasikan keluhan spesifik atau permintaan khusus dari pelanggan di sini...',
                              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                              filled: true, fillColor: Colors.grey[50],
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.all(20),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Input Odometer ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.speed_rounded,
                                  color: AppColors.navy, size: 24),
                              SizedBox(width: 8),
                              Text(
                                'Odometer Saat Ini',
                                style: TextStyle(
                                  fontSize  : 18,
                                  fontWeight: FontWeight.bold,
                                  color     : AppColors.navy,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Catat kilometer kendaraan saat masuk bengkel untuk keperluan service reminder.',
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey.shade500),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: TextField(
                                  controller   : _kilometerController,
                                  keyboardType : TextInputType.number,
                                  style: const TextStyle(
                                    fontSize  : 20,
                                    fontWeight: FontWeight.w700,
                                    color     : AppColors.navy,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '0',
                                    hintStyle: TextStyle(
                                        color: Colors.grey.shade300,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700),
                                    suffixText: 'KM',
                                    suffixStyle: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontWeight: FontWeight.w600),
                                    filled: true,
                                    fillColor: AppColors.backgroundSection,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: AppColors.navy, width: 1.5),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 16),
                                  ),
                                  onChanged: (val) {
                                    final km = int.tryParse(
                                            val.replaceAll('.', '')) ??
                                        0;
                                    _orderKerjaViewModel.setKilometer(km);
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Live display
                              ListenableBuilder(
                                listenable: _orderKerjaViewModel,
                                builder: (context, _) {
                                  final km = _orderKerjaViewModel.kilometer;
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: km > 0
                                          ? AppColors.navy
                                          : AppColors.backgroundInput,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.speed_rounded,
                                          size : 20,
                                          color: km > 0
                                              ? Colors.white
                                              : Colors.grey.shade400,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          km > 0 ? '✓ Tercatat' : 'Belum',
                                          style: TextStyle(
                                            fontSize  : 11,
                                            fontWeight: FontWeight.w700,
                                            color     : km > 0
                                                ? Colors.white
                                                : Colors.grey.shade400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Service Catalog ──

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(children: const [
                              Icon(Icons.category, color: AppColors.navy, size: 20),
                              SizedBox(width: 8),
                              Text('Service Catalog',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.navy)),
                            ]),
                            SizedBox(
                              width: 250,
                              child: AppSearchBar(
                                hintText: 'Cari jasa/layanan...',
                                onChanged: _orderKerjaViewModel.cariPekerjaan,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ListenableBuilder(
                          listenable: _orderKerjaViewModel,
                          builder: (context, child) {
                            if (_orderKerjaViewModel.isLoading) {
                              return const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator()));
                            }
                            if (_orderKerjaViewModel.errorMessage != null) {
                              return Center(child: Text(_orderKerjaViewModel.errorMessage!, style: const TextStyle(color: Colors.red)));
                            }
                            if (_orderKerjaViewModel.daftarKerjaTampil.isEmpty) {
                              return Container(
                                width: double.infinity, padding: const EdgeInsets.all(32),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                                child: const Center(child: Text('Pekerjaan tidak ditemukan.')),
                              );
                            }
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 2.5,
                              ),
                              itemCount: _orderKerjaViewModel.daftarKerjaTampil.length,
                              itemBuilder: (context, index) {
                                final jasa = _orderKerjaViewModel.daftarKerjaTampil[index];
                                final isSelected = _orderKerjaViewModel.isJasaDipilih(jasa);
                                return ServiceCardItem(
                                    jasa: jasa,
                                    isSelected: isSelected,
                                    onTap: () {
                                      if (isSelected) {
                                        _orderKerjaViewModel.hapusDariKeranjang(jasa);
                                      } else if (jasa.requiresSparepart) {
                                        _tampilDialogPilihSparepart(jasa);
                                      } else {
                                        _orderKerjaViewModel.toggleKeranjang(jasa);
                                      }
                                    });
                              },
                            );
                          },
                        ),
                      ],
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
                child: Column(
                  children: [
                    Container(
                      height: 80, width: double.infinity,
                      decoration: BoxDecoration(
                          color: Colors.white, borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200)),
                      child: const Center(child: Text('Area Teknisi')),
                    ),
                    const SizedBox(height: 24),
                    ListenableBuilder(
                      listenable: _orderKerjaViewModel,
                      builder: (context, child) {
                        final keranjang = _orderKerjaViewModel.keranjangJasa;

                        return Container(
                          width: double.infinity, padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                              color: AppColors.navyDarkest, borderRadius: BorderRadius.circular(16)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Ringkasan Order',
                                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 24),
                              if (keranjang.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 24),
                                  child: Text('Belum ada jasa yang dipilih.',
                                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontStyle: FontStyle.italic)),
                                ),
                              ...keranjang.map((jasa) {
                                final spareparts = _orderKerjaViewModel.sparepartPerPekerjaan[jasa.id] ?? [];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(child: Text('• ${jasa.nama}',
                                              style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14))),
                                          Text('Rp ${_formatRupiah(jasa.estimasiHarga)}',
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                        ],
                                      ),
                                      ...spareparts.map((sp) => Padding(
                                        padding: const EdgeInsets.only(left: 16, top: 4),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('↳ ${sp.sparepart.displayName} x${sp.qty}',
                                                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                                            Text('Rp ${_formatRupiah(sp.subtotal)}',
                                                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
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
                                  Text('Rp ${_formatRupiah(_orderKerjaViewModel.totalEstimasi)}',
                                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity, height: 50,
                                child: ElevatedButton(
                                  onPressed: keranjang.isEmpty ? null : () async {
                                    // Validasi kilometer
                                    if (_orderKerjaViewModel.kilometer <= 0) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('⚠️ Masukkan kilometer kendaraan terlebih dahulu'),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                      return;
                                    }
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Menyimpan pesanan...')),
                                    );
                                    bool sukses = await _orderKerjaViewModel.simpanOrderKerja(
                                      customerId     : widget.customerId,
                                      catatanKeluhan : _keluhanController.text,
                                    );
                                    if (sukses) {
                                      _keluhanController.clear();
                                      _kilometerController.clear();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content        : Text('✅ Order berhasil disimpan!'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content        : Text('❌ Gagal menyimpan order.'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue[600],
                                    disabledBackgroundColor: Colors.white.withOpacity(0.1),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const Text('Simpan Order',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ServiceCardItem extends StatefulWidget {
  final OrderKerja jasa;
  final bool isSelected;
  final VoidCallback onTap;

  const ServiceCardItem({Key? key, required this.jasa, required this.isSelected, required this.onTap}) : super(key: key);

  @override
  State<ServiceCardItem> createState() => _ServiceCardItemState();
}

class _ServiceCardItemState extends State<ServiceCardItem> {
  bool isHovered = false;

  String _formatRupiah(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isActive = isHovered || widget.isSelected;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.isSelected ? Colors.blue.shade50.withOpacity(0.5) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isSelected ? Colors.blue.shade600 : (isHovered ? Colors.blue.shade300 : Colors.grey.shade200),
          width: widget.isSelected ? 2 : 1,
        ),
        boxShadow: isHovered
            ? [BoxShadow(color: Colors.blue.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MouseRegion(
                cursor: SystemMouseCursors.click,
                onEnter: (_) => setState(() => isHovered = true),
                onExit: (_) => setState(() => isHovered = false),
                child: GestureDetector(
                  onTap: widget.onTap,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isActive ? Colors.blue[800] : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      widget.isSelected ? Icons.check : (isHovered ? Icons.add : Icons.build),
                      color: isActive ? Colors.white : Colors.blue[800],
                      size: 20,
                    ),
                  ),
                ),
              ),
              Text('Rp ${_formatRupiah(widget.jasa.estimasiHarga)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            ],
          ),
          const Spacer(),
          Text(widget.jasa.nama,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.navy),
            maxLines: 2, overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(widget.jasa.kode, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              if (widget.jasa.requiresSparepart) ...[
                const SizedBox(width: 8),
                Icon(Icons.inventory_2, size: 12, color: Colors.orange[400]),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
