class PotonganTpp {
  final int id;
  final String nip;
  final String bulan;
  final String tahun;
  final int tkd;
  final int bjb;
  final int gotroy;
  final int bprOtista;
  final int bprPasar;
  final int bendahara;
  final int jumlahPotongan;
  final int sisaTpp;

  PotonganTpp({
    required this.id,
    required this.nip,
    required this.bulan,
    required this.tahun,
    required this.tkd,
    required this.bjb,
    required this.gotroy,
    required this.bprOtista,
    required this.bprPasar,
    required this.bendahara,
    required this.jumlahPotongan,
    required this.sisaTpp,
  });

  factory PotonganTpp.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is double) return val.toInt();
      if (val is String) return double.tryParse(val)?.toInt() ?? 0;
      return 0;
    }

    return PotonganTpp(
      id: toInt(json['id']),
      nip: json['nip']?.toString() ?? '',
      bulan: json['bulan']?.toString() ?? '',
      tahun: json['tahun']?.toString() ?? '',
      
      tkd: toInt(json['tkd']),
      bjb: toInt(json['bjb']),
      gotroy: toInt(json['gotroy']),
      bprOtista: toInt(json['bpr_otista']),
      bprPasar: toInt(json['bpr_pasar']),
      bendahara: toInt(json['bendahara']),
      jumlahPotongan: toInt(json['jumlah_potongan']),
      sisaTpp: toInt(json['sisa_tpp']),
    );
  }
}