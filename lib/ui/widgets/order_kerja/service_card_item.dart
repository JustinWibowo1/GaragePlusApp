import 'package:flutter/material.dart';
import '../../../app_colors.dart';
import '../../../models/order_kerja_models.dart';

class ServiceCardItem extends StatefulWidget {
  final OrderKerja jasa;
  final bool isSelected;
  final VoidCallback onTap;
  final List<dynamic>? selectedSpareparts; // Tambahan prop opsional dari ServiceCatalogList

  const ServiceCardItem({
    Key? key,
    required this.jasa,
    required this.isSelected,
    required this.onTap,
    this.selectedSpareparts,
  }) : super(key: key);

  @override
  State<ServiceCardItem> createState() => _ServiceCardItemState();
}

class _ServiceCardItemState extends State<ServiceCardItem> {
  bool isHovered = false;

  String _formatRupiah(int value) {
    return value.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
  }

  @override
  Widget build(BuildContext context) {
    bool isActive = isHovered || widget.isSelected;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.isSelected
            ? Colors.blue.shade50.withOpacity(0.5)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isSelected
              ? Colors.blue.shade600
              : (isHovered ? Colors.blue.shade300 : Colors.grey.shade200),
          width: widget.isSelected ? 2 : 1,
        ),
        boxShadow: isHovered
            ? [
                BoxShadow(
                    color: Colors.blue.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MouseRegion(
                cursor: SystemMouseCursors.click,
                onEnter: (_) => setState(() => isHovered = true),
                onExit: (_) => setState(() => isHovered = false),
                child: GestureDetector(
                  onTap: widget.onTap,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isActive ? Colors.blue[800] : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      widget.isSelected
                          ? Icons.check
                          : (isHovered ? Icons.add : Icons.build),
                      color: isActive ? Colors.white : Colors.blue[800],
                      size: 18,
                    ),
                  ),
                ),
              ),
              Text('Rp ${_formatRupiah(widget.jasa.estimasiHarga)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13)),
            ],
          ),
          const Spacer(),
          Text(
            widget.jasa.nama,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.navy),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              if (widget.jasa.kategoriPerbaikan != null)
                Text(widget.jasa.kategoriPerbaikan!,
                    style: TextStyle(color: Colors.grey[500], fontSize: 11)),
              if (widget.jasa.requiresSparepart) ...[
                const SizedBox(width: 6),
                Icon(Icons.inventory_2, size: 11, color: Colors.orange[400]),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
