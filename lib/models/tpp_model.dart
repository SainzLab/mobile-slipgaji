class Tpp {
  final int id;
  final String nip;
  final int bebanKerja;
  final int prestasiKerja;
  final int kondisiKerja;
  final int kelangkaanProfesi;
  final int tempatBertugas;
  final int tunjanganJabatan; // Tambahan
  
  // Iuran TPP
  final int iuranBpjs;          // iuran_jaminan_kesehatan
  final int iuranJkk;           // iuran_jaminan_kecelakaan
  final int iuranSimpanan;      // iuran_simpanan
  final int iuranPensiun;       // iuran_pensiun
  
  final int potonganIwp;        // potongan_iw
  final int potonganPph;        // potongan_pp
  final int zakat;              // Tambahan
  final int bulog;              // Tambahan
  
  final int jumlahKotor;        
  final int jumlahPotongan;
  final int jumlahDiterima;

  Tpp({
    required this.id, required this.nip, required this.bebanKerja,
    required this.prestasiKerja, required this.kondisiKerja,
    required this.kelangkaanProfesi, required this.tempatBertugas,
    required this.tunjanganJabatan, required this.iuranBpjs,
    required this.iuranJkk, required this.iuranSimpanan,
    required this.iuranPensiun, required this.potonganIwp,
    required this.potonganPph, required this.zakat, required this.bulog,
    required this.jumlahKotor, required this.jumlahPotongan, required this.jumlahDiterima
  });

  factory Tpp.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is double) return val.toInt();
      if (val is String) return double.tryParse(val)?.toInt() ?? 0;
      return 0;
    }

    return Tpp(
      id: toInt(json['id']),
      nip: json['nip']?.toString() ?? '',
      bebanKerja: toInt(json['tpp_beban_kerja']),
      prestasiKerja: toInt(json['tpp_prestasi_kerja']),
      kondisiKerja: toInt(json['tpp_kondisi_kerja']),
      kelangkaanProfesi: toInt(json['tpp_kelangkaan_profesi']),
      tempatBertugas: toInt(json['tpp_tempat_bertugas']),
      tunjanganJabatan: toInt(json['tunjangan_jabatan']),
      
      // Iuran
      iuranBpjs: toInt(json['iuran_jaminan_kesehatan']),
      iuranJkk: toInt(json['iuran_jaminan_kecelakaan']),
      iuranSimpanan: toInt(json['iuran_simpanan']),
      iuranPensiun: toInt(json['iuran_pensiun']),
      
      // Potongan
      potonganIwp: toInt(json['potongan_iw']),
      potonganPph: toInt(json['potongan_pp']),
      zakat: toInt(json['zakat']),
      bulog: toInt(json['bulog']),
      
      jumlahKotor: toInt(json['jumlah_tpp']),
      jumlahPotongan: toInt(json['jumlah_potongan']),
      jumlahDiterima: toInt(json['jumlah_diterima']),
    );
  }
}