import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_animations.dart';
import '../../viewModel/car_viewmodel.dart';
import '../../viewModel/menu_sidebar_viewmodel.dart';// PAstikan path ke NavigationViewModel benar

class AddCarScreen extends StatefulWidget {
  const AddCarScreen({super.key});

  @override
  State<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CarViewModel>(context, listen: false).clearForm();
    });
  }

  Future<void> _handleSave(CarViewModel viewModel) async {
    if (_formKey.currentState!.validate()) {
      bool success = await viewModel.submitAddCar();

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Data Mobil Berhasil Disimpan!')),
        );
        _goBackToHome();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(viewModel.errorMessage ?? '❌ Gagal menyimpan data')),
        );
      }
    }
  }

  void _goBackToHome() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      return;
    }

    Provider.of<NavigationViewModel>(context, listen: false).navigateTo(0, context);
  }

  @override
  Widget build(BuildContext context) {
    final carViewModel = Provider.of<CarViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            color: Colors.white,
            child: Row(
              children: [
                AppAnimatedBackButton(onTap: _goBackToHome),
                const SizedBox(width: 8),
                const Text(
                  'Input Data Mobil Baru',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F2042)),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1, color: Colors.black12),

          Expanded(
            child: carViewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Center( // Center formnya agar rapi di layar monitor lebar
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800), // Lebar maksimum form
                      child: Form(
                        key: _formKey,
                        child: ListView(
                          padding: const EdgeInsets.all(32.0),
                          children: [
                            Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionTitle('Identitas Kendaraan', Icons.directions_car),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(child: _buildTextField(carViewModel.polisiCtrl, 'Nomor Polisi (Contoh: H-815-R)', Icons.badge)),
                                      const SizedBox(width: 16),
                                      Expanded(child: _buildTextField(carViewModel.rangkaCtrl, 'Nomor Rangka', Icons.qr_code)),
                                    ],
                                  ),
                                  _buildTextField(carViewModel.mesinCtrl, 'Nomor Mesin', Icons.precision_manufacturing),
                                  
                                  const SizedBox(height: 32),
                                  
                                  _buildSectionTitle('Detail Mobil', Icons.info_outline),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(child: _buildTextField(carViewModel.jenisCtrl, 'Jenis Mobil (Contoh: NISSAN)', Icons.car_rental)),
                                      const SizedBox(width: 16),
                                      Expanded(child: _buildTextField(carViewModel.typeCtrl, 'Type (Contoh: XTRAIL 2.5L)', Icons.model_training)),
                                    ],
                                  ),
                                  _buildTextField(carViewModel.tahunCtrl, 'Tahun Pembuatan', Icons.calendar_today, isNumber: true),
                                  Row(
                                    children: [
                                      Expanded(child: _buildDropdown(
                                        label: 'Tipe Mesin',
                                        icon: Icons.local_gas_station,
                                        value: carViewModel.tipeMesin,
                                        items: CarViewModel.mesinOpts,
                                        onChanged: (val) => carViewModel.setTipeMesin(val),
                                      )),
                                      const SizedBox(width: 16),
                                      Expanded(child: _buildDropdown(
                                        label: 'Tipe Transmisi',
                                        icon: Icons.settings,
                                        value: carViewModel.tipeTransmisi,
                                        items: CarViewModel.transmisiOpts,
                                        onChanged: (val) => carViewModel.setTipeTransmisi(val),
                                      )),
                                    ],
                                  ),

                                  const SizedBox(height: 32),
                                  
                                  _buildSectionTitle('Data Pemilik', Icons.person_outline),
                                  const SizedBox(height: 16),

                                  // ── Sapaan + Nama Pemilik ──
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Dropdown Sapaan
                                        SizedBox(
                                          width: 130,
                                          child: DropdownButtonFormField<String>(
                                            value: carViewModel.sapaan,
                                            decoration: InputDecoration(
                                              labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                                              prefixIcon: Icon(Icons.wc, color: Colors.grey.shade400),
                                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF0F2042))),
                                              filled: true,
                                              fillColor: Colors.grey.shade50,
                                            ),
                                            items: CarViewModel.sapaanOpts
                                                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                                .toList(),
                                            onChanged: (val) {
                                              if (val != null) carViewModel.setSapaan(val);
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // Nama Pemilik
                                        Expanded(
                                          child: TextFormField(
                                            controller: carViewModel.ownerCtrl,
                                            decoration: InputDecoration(
                                              labelText: 'Nama Pemilik',
                                              labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                                              prefixIcon: Icon(Icons.person, color: Colors.grey.shade400),
                                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF0F2042))),
                                              filled: true,
                                              fillColor: Colors.grey.shade50,
                                            ),
                                            validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // ── Telepon + Kota ──
                                  Row(
                                    children: [
                                      Expanded(child: _buildTextField(carViewModel.teleponCtrl, 'Nomor Telepon / WA', Icons.phone, isNumber: true)),
                                      const SizedBox(width: 16),
                                      Expanded(child: _buildTextField(carViewModel.kotaCtrl, 'Kota', Icons.location_city)),
                                    ],
                                  ),

                                  // ── Nama Perusahaan (opsional) ──
                                  _buildOptionalTextField(carViewModel.perusahaanCtrl, 'Nama Perusahaan (opsional)', Icons.business),

                                  // ── Alamat (opsional) ──
                                  _buildOptionalTextField(carViewModel.alamatCtrl, 'Alamat Lengkap (opsional)', Icons.home),

                                  const SizedBox(height: 40),
                                  
                                  // Tombol Simpan
                                  SizedBox(
                                    width: double.infinity,
                                    height: 55,
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.save, color: Colors.white),
                                      label: const Text('Simpan Data Kendaraan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF0F2042),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      onPressed: () => _handleSave(carViewModel),
                                    ),
                                  ),

                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // WIDGET HELPERS UNTUK FORM (Disesuaikan agar lebih elegan)
  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          prefixIcon: Icon(icon, color: Colors.grey.shade400),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF0F2042))),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        validator: (value) => (value == null || value.isEmpty) ? 'Wajib diisi' : null,
      ),
    );
  }

  /// Field opsional — tidak ada validasi wajib diisi
  Widget _buildOptionalTextField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          prefixIcon: Icon(icon, color: Colors.grey.shade400),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF0F2042))),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        // Tidak ada validator — field ini opsional
      ),
    );
  }


  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          prefixIcon: Icon(icon, color: Colors.grey.shade400),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF0F2042))),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: onChanged,
        validator: (value) => (value == null || value.isEmpty) ? 'Wajib dipilih' : null,
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF0F2042), size: 20),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F2042))),
          ],
        ),
        const SizedBox(height: 8),
        const Divider(),
      ],
    );
  }
}
