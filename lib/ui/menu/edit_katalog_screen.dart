import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../component/app_colors.dart';
import '../../models/order_kerja_models.dart';
import '../../viewModel/edit_katalog_viewmodel.dart';
import '../dialogs/status_popup.dart';
import '../menu_sidebar.dart';

class EditKatalogScreen extends StatefulWidget {
  const EditKatalogScreen({super.key});

  @override
  State<EditKatalogScreen> createState() => _EditKatalogScreenState();
}

class _EditKatalogScreenState extends State<EditKatalogScreen> {
  final _vm = EditKatalogViewModel();
  OrderKerja? _dipilih;
  bool _isFormBaru = false;

  // Form controllers
  final _namaCtrl = TextEditingController();
  final _hargaCtrl = TextEditingController();
  final _intervalKmCtrl = TextEditingController();
  final _intervalBulanCtrl = TextEditingController();
  final _sparepartCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();

  String? _kategoriForm;
  bool _isActiveForm = true;
  List<String> _mesinForm = [];
  List<String> _transmisiForm = [];

  @override
  void dispose() {
    _vm.dispose();
    _namaCtrl.dispose();
    _hargaCtrl.dispose();
    _intervalKmCtrl.dispose();
    _intervalBulanCtrl.dispose();
    _sparepartCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _pilihItem(OrderKerja item) {
    setState(() {
      _dipilih = item;
      _isFormBaru = false;
      _namaCtrl.text = item.nama;
      _hargaCtrl.text = _formatRupiah(item.estimasiHarga);
      _intervalKmCtrl.text = item.intervalKm != null ? _formatRupiah(item.intervalKm!) : '';
      _intervalBulanCtrl.text = item.intervalBulan?.toString() ?? '';
      _sparepartCtrl.text = item.kategoriSparepart ?? '';
      _kategoriForm = item.kategoriPerbaikan;
      _isActiveForm = item.isActive;
      _mesinForm = List.from(item.kompatibilitasMesin);
      _transmisiForm = List.from(item.kompatibilitasTransmisi);
    });
  }

  void _mulaiTambahBaru() {
    setState(() {
      _dipilih = null;
      _isFormBaru = true;
      _namaCtrl.clear();
      _hargaCtrl.text = '0';
      _intervalKmCtrl.clear();
      _intervalBulanCtrl.clear();
      _sparepartCtrl.clear();
      _kategoriForm = null;
      _isActiveForm = true;
      _mesinForm = [];
      _transmisiForm = [];
    });
  }

  void _batalForm() {
    setState(() {
      _dipilih = null;
      _isFormBaru = false;
    });
  }

  Future<void> _simpan() async {
    final nama = _namaCtrl.text.trim();
    final harga = int.tryParse(_hargaCtrl.text.replaceAll('.', '')) ?? 0;
    final intervalKm = int.tryParse(_intervalKmCtrl.text.replaceAll('.', ''));
    final intervalBulan = int.tryParse(_intervalBulanCtrl.text.replaceAll('.', ''));
    final sparepart = _sparepartCtrl.text.trim().isEmpty ? null : _sparepartCtrl.text.trim();

    if (nama.isEmpty) {
      await StatusPopup.show(context, isSuccess: false, message: 'Nama wajib diisi');
      return;
    }

    bool ok;
    if (_isFormBaru) {
      ok = await _vm.simpanBaru(
        nama: nama, estimasiHarga: harga,
        kategoriPerbaikan: _kategoriForm, kategoriSparepart: sparepart,
        kompatibilitasMesin: _mesinForm, kompatibilitasTransmisi: _transmisiForm,
        intervalKm: intervalKm, intervalBulan: intervalBulan, isActive: _isActiveForm,
      );
    } else {
      ok = await _vm.simpanUpdate(
        id: _dipilih!.id, nama: nama, estimasiHarga: harga,
        kategoriPerbaikan: _kategoriForm, kategoriSparepart: sparepart,
        kompatibilitasMesin: _mesinForm, kompatibilitasTransmisi: _transmisiForm,
        intervalKm: intervalKm, intervalBulan: intervalBulan, isActive: _isActiveForm,
      );
    }

    if (!mounted) return;
    await StatusPopup.show(
      context,
      isSuccess: ok,
      message: ok ? (_vm.successMessage ?? 'Berhasil') : (_vm.errorMessage ?? 'Gagal'),
    );
    if (ok) _batalForm();
  }

  Future<void> _hapus() async {
    if (_dipilih == null) return;
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Hapus', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Hapus "${_dipilih!.nama}" secara permanen?\nData WO yang sudah ada tidak akan terpengaruh.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (konfirmasi != true || !mounted) return;

    final ok = await _vm.hapusPekerjaan(_dipilih!.id, _dipilih!.nama);
    if (!mounted) return;
    await StatusPopup.show(
      context,
      isSuccess: ok,
      message: ok ? (_vm.successMessage ?? 'Berhasil') : (_vm.errorMessage ?? 'Gagal'),
    );
    if (ok) _batalForm();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Row(
        children: [
          const CustomSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: ListenableBuilder(
                    listenable: _vm,
                    builder: (context, _) {
                      if (_vm.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return Row(
                        children: [
                          // ── Panel Kiri: Daftar Pekerjaan ──
                          SizedBox(
                            width: 440,
                            child: _buildPanelKiri(),
                          ),
                          const VerticalDivider(width: 1),
                          // ── Panel Kanan: Form Edit/Tambah ──
                          Expanded(
                            child: (_dipilih != null || _isFormBaru)
                                ? _buildPanelKanan()
                                : _buildPanelKosong(),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      color: Colors.white,
      child: Row(
        children: [
          const Icon(Icons.edit_note_rounded, color: AppColors.navy, size: 28),
          const SizedBox(width: 12),
          const Text(
            'Manajemen Katalog Pekerjaan',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.navy),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: _mulaiTambahBaru,
            icon: const Icon(Icons.add, color: Colors.white, size: 18),
            label: const Text('Tambah Pekerjaan Baru', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navy,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanelKiri() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _vm.cari,
              decoration: InputDecoration(
                hintText: 'Cari nama pekerjaan...',
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
          // Filter kategori
          SizedBox(
            height: 44,
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.trackpad,
                },
              ),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: _vm.daftarKategori.map((k) {
                  final isSelected = _vm.kategoriFilter == k;
                  final nama = k == 'Semua' ? 'Semua Kategori' : k;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(nama),
                      selected: isSelected,
                      onSelected: (_) => _vm.setKategori(k),
                      selectedColor: AppColors.navy,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.navy,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: isSelected ? AppColors.navy : Colors.grey.shade300),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // Counter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text('${_vm.daftarFiltered.length} pekerjaan',
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          const Divider(height: 1),
          // Daftar item
          Expanded(
            child: _vm.daftarFiltered.isEmpty
                ? const Center(child: Text('Tidak ada pekerjaan', style: TextStyle(color: Colors.grey)))
                : ListView.separated(
                    itemCount: _vm.daftarFiltered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
                    itemBuilder: (_, i) {
                      final item = _vm.daftarFiltered[i];
                      final isSelected = _dipilih?.id == item.id;
                      return InkWell(
                        onTap: () => _pilihItem(item),
                        child: Container(
                          color: isSelected ? AppColors.navy.withOpacity(0.06) : null,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              // Status indicator
                              Container(
                                width: 8, height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: item.isActive ? Colors.green : Colors.grey.shade400,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.nama,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                          color: item.isActive ? AppColors.navy : Colors.grey,
                                        )),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        if (item.kategoriPerbaikan != null) ...[
                                          _chip(
                                            item.kategoriPerbaikan!,
                                            Colors.orange.shade100,
                                            Colors.orange.shade700,
                                          ),
                                        ],
                                        if (!item.isActive) ...[
                                          const SizedBox(width: 4),
                                          _chip('Nonaktif', Colors.grey.shade200, Colors.grey),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'Rp ${_formatRupiah(item.estimasiHarga)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.navy),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, Color bg, Color text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
    child: Text(label, style: TextStyle(fontSize: 10, color: text, fontWeight: FontWeight.w600)),
  );

  Widget _buildPanelKosong() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.touch_app_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('Pilih pekerjaan dari daftar kiri\natau tambahkan pekerjaan baru',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildPanelKanan() {
    final isEdit = _dipilih != null;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul form
          Row(
            children: [
              Icon(isEdit ? Icons.edit : Icons.add_circle_outline, color: AppColors.navy),
              const SizedBox(width: 8),
              Text(
                isEdit ? 'Edit Pekerjaan' : 'Tambah Pekerjaan Baru',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.navy),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Nama ──
          _label('Nama Pekerjaan *'),
          _field(_namaCtrl, 'Contoh: Ganti Oli Mesin'),
          const SizedBox(height: 16),

          // ── Kategori ──
          _label('Kategori Perbaikan'),
          _buildDropdownKategori(),
          const SizedBox(height: 16),

          // ── Harga & Interval ──
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Estimasi Harga (Rp) *'),
                    _field(_hargaCtrl, '0',
                        inputFormatters: [CurrencyInputFormatter()],
                        keyboardType: TextInputType.number),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Interval KM'),
                    _field(_intervalKmCtrl, 'Cth: 5000',
                        inputFormatters: [CurrencyInputFormatter()],
                        keyboardType: TextInputType.number),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Interval Bln'),
                    _field(_intervalBulanCtrl, 'Cth: 6',
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        keyboardType: TextInputType.number),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Kategori Sparepart ──
          _label('Kategori Sparepart (opsional)'),
          _field(_sparepartCtrl, 'Contoh: Oli, Kampas Rem'),
          const SizedBox(height: 16),

          // ── Kompatibilitas Mesin ──
          _label('Kompatibilitas Mesin (kosong = semua mesin)'),
          _buildMultiSelectChips(
            options: EditKatalogViewModel.mesinList,
            selected: _mesinForm,
            onChanged: (v) => setState(() => _mesinForm = v),
          ),
          const SizedBox(height: 16),

          // ── Kompatibilitas Transmisi ──
          _label('Kompatibilitas Transmisi (kosong = semua transmisi)'),
          _buildMultiSelectChips(
            options: EditKatalogViewModel.transmisiList,
            selected: _transmisiForm,
            onChanged: (v) => setState(() => _transmisiForm = v),
          ),
          const SizedBox(height: 20),

          // ── Status Aktif ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6FA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.toggle_on_outlined, color: AppColors.navy),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status Aktif', style: TextStyle(fontWeight: FontWeight.w600)),
                      Text('Pekerjaan nonaktif tidak akan muncul di katalog kasir',
                          style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
                Switch(
                  value: _isActiveForm,
                  onChanged: (v) => setState(() => _isActiveForm = v),
                  activeColor: AppColors.navy,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // ── Tombol Aksi ──
          ListenableBuilder(
            listenable: _vm,
            builder: (context, _) {
              return Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _vm.isSaving ? null : _simpan,
                      icon: _vm.isSaving
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.save_rounded, color: Colors.white),
                      label: Text(isEdit ? 'Simpan Perubahan' : 'Tambahkan',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.navy,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: _batalForm,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Batal'),
                  ),
                  if (isEdit) ...[
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: _vm.isSaving ? null : _hapus,
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      label: const Text('Hapus', style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
  );

  Widget _field(
    TextEditingController ctrl,
    String hint, {
    List<TextInputFormatter>? inputFormatters,
    TextInputType keyboardType = TextInputType.text,
  }) =>
      TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: const Color(0xFFF5F6FA),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      );

  Widget _buildDropdownKategori() {
    final List<String> availableKategori = _vm.daftarKategori
        .where((k) => k != 'Semua')
        .toList();
        
    // Cegah crash: Jika database memiliki value lama (misal "Body & AC") yang tidak ada di list standar
    if (_kategoriForm != null && !availableKategori.contains(_kategoriForm)) {
      availableKategori.add(_kategoriForm!);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _kategoriForm,
          isExpanded: true,
          hint: const Text('Pilih kategori'),
          items: [
            const DropdownMenuItem(value: null, child: Text('— Tanpa Kategori —')),
            ...availableKategori.map((k) => DropdownMenuItem(
                  value: k,
                  child: Text(k),
                )),
          ],
          onChanged: (v) => setState(() => _kategoriForm = v),
        ),
      ),
    );
  }

  Widget _buildMultiSelectChips({
    required List<String> options,
    required List<String> selected,
    required ValueChanged<List<String>> onChanged,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: options.map((opt) {
        final isSelected = selected.contains(opt);
        return FilterChip(
          label: Text(opt),
          selected: isSelected,
          onSelected: (v) {
            final updated = List<String>.from(selected);
            if (v) {
              updated.add(opt);
            } else {
              updated.remove(opt);
            }
            onChanged(updated);
          },
          selectedColor: AppColors.navy.withOpacity(0.1),
          checkmarkColor: AppColors.navy,
          labelStyle: TextStyle(
            color: isSelected ? AppColors.navy : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: isSelected ? AppColors.navy : Colors.grey.shade300),
          ),
        );
      }).toList(),
    );
  }

  String _formatRupiah(int v) => v.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]}.',
      );
}

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
