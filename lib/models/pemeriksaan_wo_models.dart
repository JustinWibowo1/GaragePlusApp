/// Model untuk tabel pemeriksaan_wo
class PemeriksaanWO {
  final String id;
  final int nomorWo;

  // Battery
  final double? batteryAwal;
  final double? batteryStater;
  final double? batteryPengisian;
  final String? batteryStatus;

  // Oli & Cairan
  final String? oliMesin;
  final String? oliMatik;
  final String? coolant;
  final String? oliRemKopling;

  // Tekanan Ban
  final int? tekananDepan;
  final int? tekananBelakang;
  final int? tekananCadangan;

  // Lain-lain
  final String? torsiMur;
  final int? serviceBerikutKm;
  final int? serviceBerikutBulan;
  final String? catatanTambahan;

  // Personel
  final String? namaMekanik;
  final String? namaForeman;

  final DateTime createdAt;
  final DateTime updatedAt;

  const PemeriksaanWO({
    required this.id,
    required this.nomorWo,
    this.batteryAwal,
    this.batteryStater,
    this.batteryPengisian,
    this.batteryStatus,
    this.oliMesin,
    this.oliMatik,
    this.coolant,
    this.oliRemKopling,
    this.tekananDepan,
    this.tekananBelakang,
    this.tekananCadangan,
    this.torsiMur,
    this.serviceBerikutKm,
    this.serviceBerikutBulan,
    this.catatanTambahan,
    this.namaMekanik,
    this.namaForeman,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PemeriksaanWO.fromJson(Map<String, dynamic> json) {
    return PemeriksaanWO(
      id              : json['id'] as String,
      nomorWo         : json['nomor_wo'] as int,
      batteryAwal     : (json['battery_awal'] as num?)?.toDouble(),
      batteryStater   : (json['battery_stater'] as num?)?.toDouble(),
      batteryPengisian: (json['battery_pengisian'] as num?)?.toDouble(),
      batteryStatus   : json['battery_status'] as String?,
      oliMesin        : json['oli_mesin'] as String?,
      oliMatik        : json['oli_matik'] as String?,
      coolant         : json['coolant'] as String?,
      oliRemKopling   : json['oli_rem_kopling'] as String?,
      tekananDepan    : json['tekanan_depan'] as int?,
      tekananBelakang : json['tekanan_belakang'] as int?,
      tekananCadangan : json['tekanan_cadangan'] as int?,
      torsiMur        : json['torsi_mur'] as String?,
      serviceBerikutKm   : json['service_berikut_km'] as int?,
      serviceBerikutBulan: json['service_berikut_bulan'] as int?,
      catatanTambahan : json['catatan_tambahan'] as String?,
      namaMekanik     : json['nama_mekanik'] as String?,
      namaForeman     : json['nama_foreman'] as String?,
      createdAt       : DateTime.parse(json['created_at'] as String),
      updatedAt       : DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toUpsertJson(int nomorWo) {
    return {
      'nomor_wo'             : nomorWo,
      'battery_awal'         : batteryAwal,
      'battery_stater'       : batteryStater,
      'battery_pengisian'    : batteryPengisian,
      'battery_status'       : batteryStatus,
      'oli_mesin'            : oliMesin,
      'oli_matik'            : oliMatik,
      'coolant'              : coolant,
      'oli_rem_kopling'      : oliRemKopling,
      'tekanan_depan'        : tekananDepan,
      'tekanan_belakang'     : tekananBelakang,
      'tekanan_cadangan'     : tekananCadangan,
      'torsi_mur'            : torsiMur,
      'service_berikut_km'   : serviceBerikutKm,
      'service_berikut_bulan': serviceBerikutBulan,
      'catatan_tambahan'     : catatanTambahan,
      'nama_mekanik'         : namaMekanik,
      'nama_foreman'         : namaForeman,
      'updated_at'           : DateTime.now().toIso8601String(),
    };
  }
}
