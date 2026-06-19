class Customer {
  final String nomorRangka;
  final String nomorMesin;
  final String nomorPolisi;
  final String jenisMobil;
  final String tipeMobil;
  final int tahun;
  final String tipeMesin;
  final String tipeTransmisi;
  final String namaPemilik;
  final String? alamatPemilik;
  final String? noTelepon;
  final String? namaPerusahaan;
  final String? kotaPemilik;
  final int odometerTerakhir;
  final DateTime? tglServiceTerakhir;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  Customer({
    required this.nomorRangka,
    required this.nomorMesin,
    required this.nomorPolisi,
    required this.jenisMobil,
    required this.tipeMobil,
    required this.tahun,
    required this.tipeMesin,
    required this.tipeTransmisi,
    required this.namaPemilik,
    this.alamatPemilik,
    this.noTelepon,
    this.namaPerusahaan,
    this.kotaPemilik,
    this.odometerTerakhir = 0,
    this.tglServiceTerakhir,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  String get id => nomorRangka;

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      nomorRangka       : json['nomor_rangka'] as String,
      nomorMesin        : json['nomor_mesin'] as String,
      nomorPolisi       : json['nomor_polisi'] as String,
      jenisMobil        : json['jenis_mobil'] as String,
      tipeMobil         : json['tipe_mobil'] as String,
      tahun             : json['tahun'] as int? ?? 0,
      tipeMesin         : json['tipe_mesin'] as String,
      tipeTransmisi     : json['tipe_transmisi'] as String,
      namaPemilik       : json['nama_pemilik'] as String,
      alamatPemilik     : json['alamat_pemilik'] as String?,
      noTelepon         : json['no_telepon'] as String?,
      namaPerusahaan    : json['nama_perusahaan'] as String?,
      kotaPemilik       : json['kota_pemilik'] as String?,
      odometerTerakhir  : json['odometer_terakhir'] as int? ?? 0,
      tglServiceTerakhir: json['tgl_service_terakhir'] != null
          ? DateTime.parse(json['tgl_service_terakhir'] as String)
          : null,
      createdAt         : DateTime.parse(json['created_at'] as String),
      updatedAt         : DateTime.parse(json['updated_at'] as String),
      deletedAt         : json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
    );
  }

  /// Gabungan kota + alamat untuk tampilan di Work Order PDF
  String get alamatLengkap => [kotaPemilik, alamatPemilik]
      .where((s) => s != null && s.trim().isNotEmpty)
      .join(', ');

  Map<String, dynamic> toJson() => {
    'nomor_rangka'     : nomorRangka,
    'nomor_mesin'      : nomorMesin,
    'nomor_polisi'     : nomorPolisi,
    'jenis_mobil'      : jenisMobil,
    'tipe_mobil'       : tipeMobil,
    'tahun'            : tahun,
    'tipe_mesin'       : tipeMesin,
    'tipe_transmisi'   : tipeTransmisi,
    'nama_pemilik'     : namaPemilik,
    'alamat_pemilik'   : alamatPemilik,
    'no_telepon'       : noTelepon,
    'nama_perusahaan'  : namaPerusahaan,
    'kota_pemilik'     : kotaPemilik,
    'odometer_terakhir': odometerTerakhir,
  };
}