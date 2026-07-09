import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewModel/menu_sidebar_viewmodel.dart';
import '../app_colors.dart';

class CustomSidebar extends StatelessWidget {
  const CustomSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    // Membaca status dan fungsi dari ViewModel
    final navViewModel = Provider.of<NavigationViewModel>(context);
    final isExpanded = navViewModel.isSidebarExpanded;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: isExpanded ? 260 : 85,
      color: AppColors.background,
      child: Column(
        crossAxisAlignment:
            isExpanded ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          // --- 1. AREA LOGO ---
          Padding(
            padding: EdgeInsets.only(
                top: 32,
                left: isExpanded ? 24 : 0,
                bottom: 32,
                right: isExpanded ? 24 : 0),
            child: isExpanded
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Garage Plus',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppColors.navy,
                              letterSpacing: -0.5)),
                      const SizedBox(height: 4),
                    ],
                  )
                : const Center(
                    child: Icon(Icons.directions_car,
                        size: 32, color: AppColors.navy)),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildMenuItem(context,
                      index: 0,
                      icon: Icons.grid_view_rounded,
                      label: 'Overview'),
                  _buildMenuItem(context,
                      index: 1,
                      icon: Icons.add_circle_outline,
                      label: 'Add Data'),
                  _buildMenuItem(context,
                      index: 2, icon: Icons.build_outlined, label: 'Service'),
                  _buildMenuItem(context,
                      index: 3, icon: Icons.edit_note_rounded, label: 'Katalog'),
                ],
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: isExpanded ? 24 : 8),
            child: const Divider(color: Colors.black12, height: 1),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context,
      {required int index, required IconData icon, required String label}) {
    // Akses ViewModel di sini
    final navViewModel = Provider.of<NavigationViewModel>(context);
    final isExpanded = navViewModel.isSidebarExpanded;
    bool isSelected = navViewModel.selectedIndex == index;

    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: isExpanded ? 16 : 8, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => navViewModel.navigateTo(index, context),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: isExpanded ? 16 : 0, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4))
                    ]
                  : [],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Row(
                children: [
                  SizedBox(
                    width: isExpanded ? null : 60,
                    child: Center(
                        child: Icon(icon,
                            size: 22,
                            color: isSelected
                                ? AppColors.navy
                                : Colors.grey.shade600)),
                  ),
                  if (isExpanded) const SizedBox(width: 16),
                  if (isExpanded)
                    Text(label,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected
                                ? AppColors.navy
                                : Colors.grey.shade700)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
