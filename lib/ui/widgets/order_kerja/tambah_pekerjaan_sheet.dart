import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app_colors.dart';
import '../../../models/order_kerja_models.dart';
import '../../../services/order_kerja_services.dart';

/// Bottom sheet untuk menambah pekerjaan ke WO yang sedang berjalan.
/// Mengembalikan Map berisi {id, nama, kode, hargaFinal} jika dipilih.
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
  final _service = OrderKerjaServices();
  final _searchController = TextEditingController();
  final _hargaController = TextEditingController();

  List<OrderKerja> _semuaKatalog = [];
  List<OrderKerja> _filtered = [];
  OrderKerja? _dipilih;
  bool _isLoading = true;
  String _selectedKategori = 'Semua';

  static const _kategoriList = [
    'Semua', 'MSN', 'REM', 'PLM', 'TRN', 'BDY', 'ELK', 'SUS',
  ];

  @override
  void initState() {
    super.initState();
    _muat();
  }

  Future<void> _muat() async {
    final data = await _service.fetchSemuaKerja();
    setState(() {
      _semuaKatalog = data.where((e) => e.isActive).toList();
      _filtered = _semuaKatalog;
      _isLoading = false;
    });
  }

  void _filter() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      _filtered = _semuaKatalog.where((e) {
        final cocokKategori =
            _selectedKategori == 'Semua' || e.kategoriPerbaikan == _selectedKategori;
        final cocokSearch =
            q.isEmpty || e.nama.toLowerCase().contains(q) || e.kode.toLowerCase().contains(q);
        return cocokKategori && cocokSearch;
      }).toList();
    });
  }

  void _pilih(OrderKerja item) {
    setState(() {
      _dipilih = item;
      _hargaController.text = item.estimasiHarga.toString();
    });
  }

  void _konfirmasi() {
    if (_dipilih == null) return;
    final harga = int.tryParse(_hargaController.text) ?? _dipilih!.estimasiHarga;
    Navigator.pop(context, {
      'id'        : _dipilih!.id,
      'nama'      : _dipilih!.nama,
      'kode'      : _dipilih!.kode,
      'hargaFinal': harga,
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _hargaController.dispose();
    super.dispose();
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
          // ── Search bar ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _filter(),
              decoration: InputDecoration(
                hintText: 'Cari nama atau kode pekerjaan...',
                prefixIcon: const Icon(Icons.search, color: AppColors.navy),
                filled: true,
                fillColor: const Color(0xFFF5F6FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // ── Filter kategori ────────────────────────────────
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _kategoriList.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final k = _kategoriList[i];
                final active = k == _selectedKategori;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedKategori = k);
                    _filter();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: active ? AppColors.navy : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      k,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: active ? Colors.white : Colors.grey.shade700,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // ── List katalog ───────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? Center(
                        child: Text(
                          'Tidak ada pekerjaan ditemukan',
                          style: TextStyle(color: Colors.grey.shade400),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _filtered.length,
                        itemBuilder: (_, i) {
                          final item = _filtered[i];
                          final dipilih = _dipilih?.id == item.id;
                          return GestureDetector(
                            onTap: () => _pilih(item),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: dipilih
                                    ? AppColors.navy.withOpacity(0.08)
                                    : const Color(0xFFF5F6FA),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: dipilih ? AppColors.navy : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.nama,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: dipilih ? AppColors.navy : Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          item.kode,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    'Rp ${item.estimasiHarga.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.navy,
                                    ),
                                  ),
                                  if (dipilih) ...[
                                    const SizedBox(width: 8),
                                    const Icon(Icons.check_circle, color: AppColors.navy, size: 18),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
          // ── Panel konfirmasi (muncul jika ada yang dipilih) ─
          if (_dipilih != null)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _dipilih!.nama,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text('Harga Final (Rp): ',
                          style: TextStyle(fontSize: 13, color: Colors.grey)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _hargaController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
