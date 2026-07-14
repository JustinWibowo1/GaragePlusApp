import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app_colors.dart';
import '../../../component_apps.dart';
import '../../../viewModel/order_kerja_viewmodel.dart';
import 'service_card_item.dart';

class ServiceCatalogList extends StatefulWidget {
  final OrderKerjaViewModel vm;
  final Function(BuildContext, dynamic, List<dynamic>) onServiceSelected;
  /// Dipanggil setelah pekerjaan custom berhasil ditambahkan ke katalog.
  /// Jika NULL (default), widget akan memanggil Navigator.pop untuk menutup sheet.
  /// Jika diisi, widget TIDAK memanggil Navigator.pop — pemangil yang mengatur navigasi.
  final void Function(Map<String, dynamic> hasil)? onCustomAdded;

  const ServiceCatalogList({
    Key? key,
    required this.vm,
    required this.onServiceSelected,
    this.onCustomAdded,
  }) : super(key: key);

  @override
  State<ServiceCatalogList> createState() => _ServiceCatalogListState();
}

class _ServiceCatalogListState extends State<ServiceCatalogList> {
  // ── Dialog tambah pekerjaan custom ────────────────────────────
  Future<void> _tampilDialogTambahCustom() async {
    final namaCtrl = TextEditingController();
    final hargaCtrl = TextEditingController();
    bool isSaving = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.navy.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add_circle_outline,
                    color: AppColors.navy, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Tambah Pekerjaan Baru',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nama Pekerjaan',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.navy)),
                const SizedBox(height: 6),
                TextField(
                  controller: namaCtrl,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText: 'Contoh: Tune Up, Ganti Oli, dll.',
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Estimasi Harga (Rp)',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.navy)),
                const SizedBox(height: 6),
                TextField(
                  controller: hargaCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _ThousandSeparatorFormatter(),
                  ],
                  decoration: InputDecoration(
                    hintText: '0',
                    prefixText: 'Rp ',
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton.icon(
              onPressed: isSaving
                  ? null
                  : () async {
                      final nama = namaCtrl.text.trim();
                      if (nama.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Nama pekerjaan tidak boleh kosong'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      final hargaRaw =
                          hargaCtrl.text.replaceAll('.', '').trim();
                      final harga = int.tryParse(hargaRaw) ?? 0;

                      setDlg(() => isSaving = true);
                      final result =
                          await widget.vm.tambahPekerjaanCustom(
                        nama: nama,
                        harga: harga,
                      );

                      if (result != null && ctx.mounted) {
                        Navigator.pop(ctx); // Tutup dialog custom
                        if (context.mounted) {
                          final payload = {
                            'id'        : result.id,
                            'nama'      : result.nama,
                            'hargaFinal': harga,
                          };
                          if (widget.onCustomAdded != null) {
                            // Dipanggil dari halaman langsung → biarkan pemanggil yang atur
                            widget.onCustomAdded!(payload);
                          } else {
                            // Dipanggil dari dalam TambahPekerjaanSheet → tutup sheet
                            Navigator.pop(context, payload);
                          }
                        }
                      } else {
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Gagal menambahkan pekerjaan'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
              icon: isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.add, color: Colors.white, size: 18),
              label: Text(isSaving ? 'Menyimpan...' : 'Tambahkan',
                  style: const TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );

    namaCtrl.dispose();
    hargaCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: const [
              SizedBox(width: 8),
              Text('Daftar Order Kerja',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy)),
            ]),
            SizedBox(
              width: 250,
              child: AppSearchBar(
                hintText: 'Cari jasa/layanan...',
                onChanged: widget.vm.cariPekerjaan,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListenableBuilder(
          listenable: widget.vm,
          builder: (context, child) {
            if (widget.vm.isLoading) {
              return const Center(
                  child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator()));
            }
            if (widget.vm.errorMessage != null) {
              return Center(
                  child: Text(
                      widget.vm.errorMessage!,
                      style:
                          const TextStyle(color: Colors.red)));
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Filter Kategori + Tombol Tambah Custom ──
                Row(
                  children: [
                    Expanded(
                      child: ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context).copyWith(
                          dragDevices: {
                            PointerDeviceKind.touch,
                            PointerDeviceKind.mouse,
                          },
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: widget.vm.daftarKategori.map((kategori) {
                              final isSelected =
                                  widget.vm.kategoriTerpilih == kategori;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ChoiceChip(
                                  label: Text(kategori == 'Semua'
                                      ? 'Semua Kategori'
                                      : kategori),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    if (selected) {
                                      widget.vm.setKategori(kategori);
                                    }
                                  },
                                  selectedColor: AppColors.navy,
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.navy,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(
                                      color: isSelected
                                          ? AppColors.navy
                                          : Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // ── Tombol + Tambah Pekerjaan Custom ──
                    Tooltip(
                      message: 'Tambah pekerjaan yang tidak ada di katalog',
                      child: InkWell(
                        onTap: _tampilDialogTambahCustom,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.navy,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add, color: Colors.white, size: 16),
                              SizedBox(width: 4),
                              Text('Pekerjaan Baru',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Daftar Jasa ──
                if (widget.vm.daftarKerjaTampil.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        Icon(Icons.search_off,
                            size: 48, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        const Text('Pekerjaan tidak ditemukan.',
                            style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: _tampilDialogTambahCustom,
                          icon: const Icon(Icons.add_circle_outline, size: 18),
                          label: const Text('Tambah pekerjaan baru'),
                          style: TextButton.styleFrom(
                              foregroundColor: AppColors.navy),
                        ),
                      ],
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 300,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      mainAxisExtent: 130,
                    ),
                    itemCount: widget.vm.daftarKerjaTampil.length,
                    itemBuilder: (context, index) {
                      final jasa = widget.vm.daftarKerjaTampil[index];
                      final isSelected =
                          widget.vm.keranjangJasa.contains(jasa);
                      final sparepartTerpilih =
                          widget.vm.sparepartPerPekerjaan[jasa.id] ?? [];

                      return ServiceCardItem(
                        jasa: jasa,
                        isSelected: isSelected,
                        selectedSpareparts: sparepartTerpilih,
                        onTap: () {
                          widget.onServiceSelected(
                              context, jasa, sparepartTerpilih);
                        },
                      );
                    },
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// Formatter untuk otomatis menambah titik ribuan pada input harga
class _ThousandSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    final digits = newValue.text.replaceAll('.', '');
    final intVal = int.tryParse(digits);
    if (intVal == null) return oldValue;
    final formatted = intVal
        .toString()
        .replaceAllMapped(
            RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
