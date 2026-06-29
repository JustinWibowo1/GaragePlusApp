import 'package:flutter/material.dart';
import '../../../app_colors.dart';
import '../../../component_apps.dart';
import '../../../viewModel/order_kerja_viewmodel.dart';
import 'service_card_item.dart';

class ServiceCatalogList extends StatelessWidget {
  final OrderKerjaViewModel vm;
  final Function(BuildContext, dynamic, List<dynamic>) onServiceSelected;

  const ServiceCatalogList({
    Key? key,
    required this.vm,
    required this.onServiceSelected,
  }) : super(key: key);

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
                onChanged: vm.cariPekerjaan,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListenableBuilder(
          listenable: vm,
          builder: (context, child) {
            if (vm.isLoading) {
              return const Center(
                  child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator()));
            }
            if (vm.errorMessage != null) {
              return Center(
                  child: Text(
                      vm.errorMessage!,
                      style:
                          const TextStyle(color: Colors.red)));
            }
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Filter Kategori ──
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: vm.daftarKategori.map((kategori) {
                      final isSelected = vm.kategoriTerpilih == kategori;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(kategori == 'Semua' ? 'Semua Kategori' : kategori),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              vm.setKategori(kategori);
                            }
                          },
                          selectedColor: AppColors.navy,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.navy,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? AppColors.navy : Colors.grey.shade300,
                            )
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Daftar Jasa ──
                if (vm.daftarKerjaTampil.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16)),
                    child: const Center(
                        child: Text('Pekerjaan tidak ditemukan.')),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.0,
                    ),
                    itemCount:
                        vm.daftarKerjaTampil.length,
                    itemBuilder: (context, index) {
                      final jasa = vm.daftarKerjaTampil[index];
                      final isSelected =
                          vm.keranjangJasa.contains(jasa);
                      final sparepartTerpilih =
                          vm.sparepartPerPekerjaan[jasa.id] ?? [];

                      return ServiceCardItem(
                        jasa: jasa,
                        isSelected: isSelected,
                        selectedSpareparts: sparepartTerpilih,
                        onTap: () {
                          onServiceSelected(context, jasa, sparepartTerpilih);
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
