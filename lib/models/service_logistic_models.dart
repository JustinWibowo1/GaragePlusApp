class ServiceLogisticsItem {
  final int nomorWo; // Changed from orderId (String) to nomorWo (int)
  final String ownerName;
  final String licensePlate;
  final String vehicleName;
  final String status;
  final int totalBill;
  final DateTime tanggalMasuk;
  final List<String> serviceNames;
  final int completedItems;
  final int totalItems;

  const ServiceLogisticsItem({
    required this.nomorWo,
    required this.ownerName,
    required this.licensePlate,
    required this.vehicleName,
    required this.status,
    required this.totalBill,
    required this.tanggalMasuk,
    required this.serviceNames,
    required this.completedItems,
    required this.totalItems,
  });

  /// Display-friendly WO number
  String get nomorWoDisplay => 'WO-${tanggalMasuk.year}-${nomorWo.toString().padLeft(4, '0')}';

  double get progress =>
      totalItems == 0 ? 0 : completedItems / totalItems;
}