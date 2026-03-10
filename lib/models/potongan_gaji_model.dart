class PotonganGaji {
  final int id;
  final String nip;
  final String bulan;
  final String tahun;
  final int gajiBruto;
  final int koperasi;
  final int korpri;
  final int dharmaWanita;
  final int bjb;
  final int bjbs;
  final int zakatFitrahInfak;
  final int zakatProfesi;
  final int jumlahPotongan;
  final int jumlahYgDiterima;

  PotonganGaji({
    required this.id, required this.nip, required this.bulan, required this.tahun,
    required this.gajiBruto, required this.koperasi, required this.korpri,
    required this.dharmaWanita, required this.bjb, required this.bjbs,
    required this.zakatFitrahInfak, required this.zakatProfesi,
    required this.jumlahPotongan, required this.jumlahYgDiterima,
  });

  factory PotonganGaji.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is double) return val.toInt();
      if (val is String) return double.tryParse(val)?.toInt() ?? 0;
      return 0;
    }

    return PotonganGaji(
      id: toInt(json['id']),
      nip: json['nip']?.toString() ?? '',
      bulan: json['bulan']?.toString() ?? '',
      tahun: json['tahun']?.toString() ?? '',
      gajiBruto: toInt(json['gaji_bruto']),
      koperasi: toInt(json['koperasi']),
      korpri: toInt(json['korpri']),
      dharmaWanita: toInt(json['dharma_wanita']),
      bjb: toInt(json['bjb']),
      bjbs: toInt(json['bjbs']),
      zakatFitrahInfak: toInt(json['zakat_fitrah_infak']),
      zakatProfesi: toInt(json['zakat_profesi']),
      jumlahPotongan: toInt(json['jumlah_potongan']),
      jumlahYgDiterima: toInt(json['jumlah_yg_diterima']),
    );
  }
}