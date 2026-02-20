class Gaji {
  final int id;
  final String nip;
  final int gajiPokok;
  final int tunjKeluarga;
  final int tunjJabatan;
  final int tunjFungsional;
  final int tunjFungsionalUmum; // Tambahan
  final int tunjBeras;
  final int tunjPajak; // Tambahan
  final int tunjKhusus; // Tambahan
  final int pembulatan;
  
  // Iuran & Potongan
  final int iuranBpjs;      // iuran_jaminan_1
  final int iuranJkk;       // iuran_jaminan_2
  final int iuranJkm;       // iuran_jaminan_3
  final int iuranSimpanan;  // Tambahan
  final int iuranPensiun;   // Tambahan
  final int tunjJht;        // tunjangan_jaminan_hari_tua
  
  final int potonganIwp;    // potongan_iw
  final int potonganPph;    // potongan_pp
  final int zakat;          // Tambahan
  final int bulog;          // Tambahan
  
  final int jumlahKotor;
  final int jumlahPotongan;
  final int jumlahDiterima;

  Gaji({
    required this.id, required this.nip, required this.gajiPokok,
    required this.tunjKeluarga, required this.tunjJabatan,
    required this.tunjFungsional, required this.tunjFungsionalUmum,
    required this.tunjBeras, required this.tunjPajak, required this.tunjKhusus,
    required this.pembulatan, required this.iuranBpjs, required this.iuranJkk,
    required this.iuranJkm, required this.iuranSimpanan, required this.iuranPensiun,
    required this.tunjJht, required this.potonganIwp, required this.potonganPph,
    required this.zakat, required this.bulog,
    required this.jumlahKotor, required this.jumlahPotongan, required this.jumlahDiterima
  });

  factory Gaji.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is double) return val.toInt();
      if (val is String) return double.tryParse(val)?.toInt() ?? 0;
      return 0;
    }

    return Gaji(
      id: toInt(json['id']),
      nip: json['nip']?.toString() ?? '',
      gajiPokok: toInt(json['gaji_pokok']), 
      tunjKeluarga: toInt(json['tunjangan_keluarga']),
      tunjJabatan: toInt(json['tunjangan_jabatan']),
      tunjFungsional: toInt(json['tunjangan_fungsional']),
      tunjFungsionalUmum: toInt(json['tunjangan_fungsional_umum']),
      tunjBeras: toInt(json['tunjangan_beras']),
      tunjPajak: toInt(json['tunjangan_pajak']),
      tunjKhusus: toInt(json['tunjangan_khusus']),
      pembulatan: toInt(json['pembulatan']),
      
      // Iuran & Tunjangan Lain
      iuranBpjs: toInt(json['iuran_jaminan_1']), 
      iuranJkk: toInt(json['iuran_jaminan_2']),  
      iuranJkm: toInt(json['iuran_jaminan_3']),
      iuranSimpanan: toInt(json['iuran_simpanan']),
      iuranPensiun: toInt(json['iuran_pensiun']),
      tunjJht: toInt(json['tunjangan_jaminan_hari_tua']),
      
      // Potongan
      potonganIwp: toInt(json['potongan_iw']),
      potonganPph: toInt(json['potongan_pp']),
      zakat: toInt(json['zakat']),
      bulog: toInt(json['bulog']),
      
      jumlahKotor: toInt(json['jumlah_gaji_kotor']),
      jumlahPotongan: toInt(json['jumlah_potongan']),
      jumlahDiterima: toInt(json['jumlah_diterima']),
    );
  }
}