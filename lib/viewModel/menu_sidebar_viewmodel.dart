import 'package:flutter/material.dart';
import '../ui/menu/home.dart';
import '../ui/menu/add_car.dart';
import '../ui/menu/service_screen.dart';
import '../ui/menu/edit_katalog_screen.dart';

class NavigationViewModel extends ChangeNotifier {
  int _selectedIndex = 0;
  bool _isSidebarExpanded = true;

  int get selectedIndex => _selectedIndex;
  bool get isSidebarExpanded => _isSidebarExpanded;

  // Mengubah status buka/tutup Sidebar
  void toggleSidebar() {
    _isSidebarExpanded = !_isSidebarExpanded;
    notifyListeners();
  }

  // Logika Sakti Navigasi Terpusat
  void navigateTo(int index, BuildContext context) {
    if (_selectedIndex == index) return; // Mencegah pindah ke halaman yang sama

    _selectedIndex = index;
    notifyListeners();

    Widget targetScreen;

    // Tentukan layar tujuan berdasarkan index
    switch (index) {
      case 0:
        targetScreen = const AdminDashboard();
        break;
      case 1:
        targetScreen = const AddCarScreen();
        break;
      case 2:
        targetScreen = const ServicesScreen();
        break;
      case 3:
        targetScreen = const EditKatalogScreen();
        break;
      default:
        targetScreen = const AdminDashboard();
    }

    // Gunakan pushReplacement agar tumpukan layar tidak menumpuk bikin HP berat
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => targetScreen,
        transitionDuration:
            Duration.zero, // Matikan animasi agar terasa seperti tab web
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  // Fungsi khusus agar saat pindah halaman secara manual (bukan dari sidebar), index tetap update
  void setIndexWithoutNavigate(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void goToGarageList() {
    setIndexWithoutNavigate(2);
  }
}
