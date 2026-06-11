class Customer {
  final String nomorRangka; // PK
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
    this.odometerTerakhir = 0,
    this.tglServiceTerakhir,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  /// ID utama customer = nomor_rangka
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
}