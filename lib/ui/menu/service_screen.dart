import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewModel/car_viewmodel.dart';
import 'order_detail_screen.dart';
import 'order_kerja_screen.dart';
import '../../viewModel/menu_sidebar_viewmodel.dart';
import 'edit_car_screen.dart';
import '../../app_colors.dart';
import '../../component_apps.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CarViewModel>(context, listen: false).getAllCars();
    });
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
    final viewModel = Provider.of<CarViewModel>(context);
    final query = _searchQuery.toLowerCase();
    final filteredCars = viewModel.cars.where((car) {
      return [
        car['nomor_polisi'],
        car['nama_pemilik'],
        car['jenis_mobil'],
        car['nomor_mesin'],
        car['nomor_rangka'],
      ].any((field) => (field ?? '')
          .toString()
          .toLowerCase()
          .contains(query));
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 24),
                  color: Colors.white,
                  child: Row(
                    children: [
                      AppAnimatedBackButton(onTap: () => _goBackToHome()),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AppSearchBar(
                          hintText: 'Cari Nopol, Pemilik, atau Nomor Rangka...',
                          onChanged: (value) => setState(() => _searchQuery = value),
                          fillColor: Colors.grey.shade100,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Service Screen',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                    color: AppColors.navyDeep)),
                            SizedBox(height: 4),
                            Text('Vehicle Inventory',
                                style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.navy)),
                          ],
                        ),
                        const SizedBox(height: 32),

                        viewModel.isLoading
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(50),
                                  child: CircularProgressIndicator(),
                                ))
                            : filteredCars.isEmpty
                                ? Center(
                                    child: Text(
                                      'Kendaraan tidak ditemukan.',
                                      style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 16),
                                    ),
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: filteredCars.length,
                                    itemBuilder: (context, index) {
                                      final car = filteredCars[index];
                                      return _buildPremiumCarCard(car, context);
                                    },
                                  ),
                      ],
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

  Widget _buildPremiumCarCard(
      Map<String, dynamic> car, BuildContext context) {
    final namaMobil  = car['tipe_mobil'] ?? car['jenis_mobil'] ?? 'Unknown Vehicle';
    final nomorRangka = car['nomor_rangka'] ?? '-';
    final nomorPolisi = car['nomor_polisi'] ?? '-';
    final namaPemilik = car['nama_pemilik'] ?? '-';
    final badgeColor  = Colors.blue.shade50;
    final textColor   = Colors.blue.shade900;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          // ── Gambar Mobil ─────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 120,
              height: 80,
              color: Colors.grey.shade200,
              child: Icon(Icons.directions_car,
                  size: 40, color: Colors.grey.shade400),
            ),
          ),
          const SizedBox(width: 24),

          // ── Nama & VIN ───────────────────────────────
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(namaMobil.toString().toUpperCase(),
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navy)),
                const SizedBox(height: 8),
                Text('VIN:',
                    style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.bold)),
                Text(nomorRangka,
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),

          // ── Plat Nomor ───────────────────────────────
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('LICENSE PLATE',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade500)),
                const SizedBox(height: 4),
                Text(nomorPolisi,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navy)),
              ],
            ),
          ),

          // ── Pemilik ──────────────────────────────────
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('OWNER',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade500)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(namaPemilik,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: textColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),

          // ── Tombol Aksi ──────────────────────────────
          Row(
            children: [
              // 🔧 Buat Order Kerja
              AppActionButton(
                icon: Icons.build,
                tooltip: 'Buat Order Kerja',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderKerjaScreen(
                        customerId        : car['nomor_rangka'],
                        namaPemilik       : car['nama_pemilik'],
                        nomorTelepon      : car['no_telepon'],
                        alamat            : car['alamat_pemilik'],
                        nomorRangka       : car['nomor_rangka'],
                        mesinMobil        : car['tipe_mesin'],
                        transmisiMobil    : car['tipe_transmisi'],
                        namaMobil         : namaMobil,
                        nomorPolisi       : car['nomor_polisi'],
                        nomorMesin        : car['nomor_mesin'],
                        odometerTerakhir  : car['odometer_terakhir'] as int? ?? 0,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),

              // 📋 Detail Service — ✅ TANPA ChangeNotifierProvider
              AppActionButton(
                icon: Icons.receipt_long,
                tooltip: 'Detail Service',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderDetailScreen(
                        customerId  : car['nomor_rangka'],
                        nomorPolisi : car['nomor_polisi'] ?? '',
                        namaPemilik : car['nama_pemilik'] ?? '',
                        telepon     : car['no_telepon'] ?? '',
                        alamat      : car['alamat_pemilik'] ?? '',
                        merkMobil   : car['jenis_mobil'] ?? '',
                        typeMobil   : car['tipe_mobil'] ?? '',
                        tahun       : (car['tahun'] ?? '').toString(),
                        noRangka    : car['nomor_rangka'] ?? '',
                        noMesin     : car['nomor_mesin'] ?? '',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),

              // ✏️ Edit Data Mobil
              AppActionButton(
                icon: Icons.edit,
                tooltip: 'Edit Data Mobil',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditCarScreen(carData: car),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

