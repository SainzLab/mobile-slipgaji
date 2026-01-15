import 'package:intl/intl.dart';

class SalaryData {
  // --- DATA UTAMA (REAL DATA: JANUARI 2026) ---
  static Map<String, dynamic> data = {
    "periode": "Januari 2026",
    "pegawai": {
      "nama": "FATHURRACHMAN ABDUL MALIK",
      "nip": "19970311 202012 1 004",
      "jabatan": "PRANATA KOMPUTER PERTAMA",
      "unit": "Dinas Komunikasi dan Informatika" // Asumsi unit kerja
    },
    
    // --- RINCIAN GAJI (SIPD) ---
    // Sumber: SIPD - Data Pegawai Gaji.xlsx
    "gaji": {
      // PENDAPATAN
      "pokok": 2964000,
      "tunj_keluarga": 355680,
      "tunj_jabatan": 0,
      "tunj_fungsional": 540000,
      "tunj_fungsional_umum": 0,
      "tunj_beras": 217260,
      "tunj_pph": 0,
      "pembulatan": 31,
      "tunj_bpjs_kes": 154387,
      "tunj_jkk": 7114,
      "tunj_jkm": 21341,
      "tunj_tapera": 0,
      
      // Khusus di file SIPD Gaji, kolom JHT ada di area tunjangan tapi
      // secara perhitungan matematika dia pengurang (potongan).
      // Kita masukkan ke pendapatan untuk balancing jika di slip gaji asli muncul sebagai tunjangan dulu.
      // Namun untuk perhitungan bersih, ia akan dipotong di bawah.
      "tunj_jht": 265574, 
      
      // POTONGAN SIPD
      "potongan_iwp": 38597,
      "potongan_pph21": 0,
      "potongan_bpjs_kes": 154387,
      "potongan_jkk": 7114,
      "potongan_jkm": 21341,
      "potongan_jht": 265574, // JHT/Tapera dari file Gaji
      "potongan_tapera": 0,
      "potongan_bulog": 0,
      "potongan_zakat": 0,

      // TOTAL SIPD (Gross)
      // 2.964.000 + 355.680 + 540.000 + 217.260 + 31 + 154.387 + 7.114 + 21.341 + 265.574 = 4.259.813
      "jumlah_kotor": 4259813,
      
      // Total Potongan SIPD
      // 38.597 + 154.387 + 7.114 + 21.341 + 265.574 = 487.013
      "potongan_sipd": 487013, 
    },

    // --- RINCIAN TPP (SIPD) ---
    // Sumber: SIPD - Data Pegawai TPP.xlsx
    "tpp": {
      // PENDAPATAN
      "beban_kerja": 773934,
      "kondisi_kerja": 1382589,
      "prestasi_kerja": 1160901,
      "kelangkaan_profesi": 0,
      "tunj_bpjs_kes": 132697, // Muncul sebagai tunjangan di TPP
      "tunj_pph": 0,

      // POTONGAN SIPD
      "potongan_iwp": 33174,
      "potongan_pph21": 75772,
      "potongan_bpjs_kes": 132697, // Potongan BPJS TPP
      "potongan_zakat": 0,
      "potongan_bulog": 0,

      // TOTAL SIPD
      // 773.934 + 1.382.589 + 1.160.901 + 132.697 = 3.450.121
      "jumlah_kotor": 3450121,
      
      // Total Potongan SIPD
      // 33.174 + 75.772 + 132.697 = 241.643
      "potongan_sipd": 241643, 
    },

    // --- POTONGAN EKSTERNAL (MANUAL DARI EXCEL POTONGAN) ---
    // Sumber: Potongan Gaji PNS JAN 2026.csv
    "potongan_eksternal": {
      "gaji": {
        "koperasi": 0,
        "korpri": 5000,
        "dharma_wanita": 15000,
        "bjb": 0,
        "bjb_syariah": 0,
        "zakat_fitrah": 20000, // Zakat Fitrah + Infak
        "bri": 0,
        "zakat": 0, // Zakat Mal
        "bsm": 0,
        "total": 40000 // 5.000 + 15.000 + 20.000
      },
      // Sumber: Potongan TPP.xlsx (Row 37 FATHURRACHMAN)
      "tpp": {
        "bjb": 0,
        "gotroy": 0,
        "bpr_otista": 0,
        "bpr_pasar": 0,
        "bendahara": 0,
        "total": 0
      }
    },

    // --- SUMMARY FINAL ---
    "summary": {
      // Gaji Bersih SIPD (3.772.800) - Potongan Eksternal (40.000)
      "thp_gaji": 3732800,

      // TPP Bersih SIPD (3.208.478) - Potongan Eksternal (0)
      "thp_tpp": 3208478,

      // Grand Total: 3.732.800 + 3.208.478
      "thp_total": 6941278
    }
  };

  static String formatRupiah(num number) {
    try {
      final currencyFormatter = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      );
      return currencyFormatter.format(number);
    } catch (e) {
      return "Rp $number";
    }
  }

  // --- HELPER UNTUK HISTORY DUMMY ---
  static Map<String, dynamic> _generateHistoryItem(int id, String month) {
    // Deep copy data agar aman dimodifikasi
    final item = Map<String, dynamic>.from(data);
    
    // Copy Sub-Maps (Deep Copy Manual)
    final newGaji = Map<String, dynamic>.from(data['gaji']);
    final newTpp = Map<String, dynamic>.from(data['tpp']);
    final newPotExtGaji = Map<String, dynamic>.from(data['potongan_eksternal']['gaji']);
    final newPotExtTpp = Map<String, dynamic>.from(data['potongan_eksternal']['tpp']);
    final newSummary = Map<String, dynamic>.from(data['summary']);
    
    // Susun item baru
    final newItem = {
      'id': id,
      'month': month,
      'periode': month,
      'pegawai': data['pegawai'],
      'gaji': newGaji,
      'tpp': newTpp,
      'potongan_eksternal': {
        'gaji': newPotExtGaji,
        'tpp': newPotExtTpp
      },
      'summary': newSummary,
      'take_home_pay': newSummary['thp_total'] 
    };
    
    // --- SIMULASI PERUBAHAN BULAN LALU ---
    // (Misal: Desember ada potongan BJB, dll)
    if (month.contains("Desember")) {
       newPotExtGaji['bjb'] = 500000;
       newPotExtGaji['zakat_fitrah'] = 0;
       
       // Hitung total eksternal baru
       // 40.000 (total asli) - 20.000 (zakat fitrah) + 500.000 (bjb) = 520.000
       final totalPotExtGajiBaru = 520000; 
       newPotExtGaji['total'] = totalPotExtGajiBaru;

       // Recalculate THP Gaji
       // Gaji Bersih SIPD (3.772.800) - Potongan Eksternal Baru (520.000)
       final thpGajiBaru = 3772800 - totalPotExtGajiBaru;
       
       newSummary['thp_gaji'] = thpGajiBaru;
       newSummary['thp_total'] = thpGajiBaru + (newSummary['thp_tpp'] as int);
       newItem['take_home_pay'] = newSummary['thp_total'];
    } 

    return newItem;
  }

  static List<Map<String, dynamic>> get salaryHistory => [
    _generateHistoryItem(1, "Januari 2026"),
    _generateHistoryItem(2, "Desember 2025"),
    _generateHistoryItem(3, "November 2025"),
    _generateHistoryItem(4, "Oktober 2025"),
    _generateHistoryItem(5, "September 2025"),
  ];
}