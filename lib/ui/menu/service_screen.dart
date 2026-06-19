import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/customer_models.dart';
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

    // ── Gunakan properti Customer yang strongly-typed ──────────
    final filteredCars = viewModel.cars.where((car) {
      return [
        car.nomorPolisi,
        car.namaPemilik,
        car.jenisMobil,
        car.nomorMesin,
        car.nomorRangka,
      ].any((field) => field.toLowerCase().contains(query));
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
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

  /// Menerima Customer (strongly-typed) — bukan Map mentah
  Widget _buildPremiumCarCard(Customer car, BuildContext context) {
    final namaMobil   = car.tipeMobil.isNotEmpty ? car.tipeMobil : car.jenisMobil;
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
              child: Icon(Icons.directions_car, size: 40, color: Colors.grey.shade400),
            ),
          ),
          const SizedBox(width: 24),

          // ── Nama & VIN ───────────────────────────────
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(namaMobil.toUpperCase(),
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
                Text(car.nomorRangka,
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
                Text(car.nomorPolisi,
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(car.namaPemilik,
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
                        customerId       : car.nomorRangka,
                        namaPemilik      : car.namaPemilik,
                        nomorTelepon     : car.noTelepon ?? '',
                        alamat           : car.alamatLengkap,
                        nomorRangka      : car.nomorRangka,
                        mesinMobil       : car.tipeMesin,
                        transmisiMobil   : car.tipeTransmisi,
                        namaMobil        : namaMobil,
                        nomorPolisi      : car.nomorPolisi,
                        nomorMesin       : car.nomorMesin,
                        odometerTerakhir : car.odometerTerakhir,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),

              // 📋 Detail Service
              AppActionButton(
                icon: Icons.receipt_long,
                tooltip: 'Detail Service',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderDetailScreen(
                        customerId    : car.nomorRangka,
                        nomorPolisi   : car.nomorPolisi,
                        namaPemilik   : car.namaPemilik,
                        telepon       : car.noTelepon ?? '',
                        alamat        : car.alamatLengkap,
                        merkMobil     : car.jenisMobil,
                        typeMobil     : car.tipeMobil,
                        tahun         : car.tahun.toString(),
                        noRangka      : car.nomorRangka,
                        noMesin       : car.nomorMesin,
                        tipeMesin     : car.tipeMesin,
                        tipeTransmisi : car.tipeTransmisi,
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
                      builder: (context) => EditCarScreen(carData: car.toJson()),
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
