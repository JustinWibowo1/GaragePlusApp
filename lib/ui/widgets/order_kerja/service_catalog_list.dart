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
            if (vm.daftarKerjaTampil.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16)),
                child: const Center(
                    child: Text('Pekerjaan tidak ditemukan.')),
              );
            }
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.5,
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
            );
          },
        ),
      ],
    );
  }
}
