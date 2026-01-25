import 'package:intl/intl.dart';

class SalaryData {
  
  static Map<String, dynamic> data = {
    "periode": "Januari 2026",
    "pegawai": {
      "nama": "FATHURRACHMAN ABDUL MALIK",
      "nip": "19970311 202012 1 004",
      "jabatan": "PRANATA KOMPUTER PERTAMA",
      "unit": "Dinas Komunikasi dan Informatika" 
    },
    
    "gaji": {
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
      
      "tunj_jht": 265574, 
      
      "potongan_iwp": 38597,
      "potongan_pph21": 0,
      "potongan_bpjs_kes": 154387,
      "potongan_jkk": 7114,
      "potongan_jkm": 21341,
      "potongan_jht": 265574,
      "potongan_tapera": 0,
      "potongan_bulog": 0,
      "potongan_zakat": 0,

      "jumlah_kotor": 4259813,
      
      "potongan_sipd": 487013, 
    },

    "tpp": {
      "beban_kerja": 773934,
      "kondisi_kerja": 1382589,
      "prestasi_kerja": 1160901,
      "kelangkaan_profesi": 0,
      "tunj_bpjs_kes": 132697,
      "tunj_pph": 0,

      "potongan_iwp": 33174,
      "potongan_pph21": 75772,
      "potongan_bpjs_kes": 132697,
      "potongan_zakat": 0,
      "potongan_bulog": 0,

      "jumlah_kotor": 3450121,
      
      "potongan_sipd": 241643, 
    },

    "potongan_eksternal": {
      "gaji": {
        "koperasi": 0,
        "korpri": 5000,
        "dharma_wanita": 15000,
        "bjb": 0,
        "bjb_syariah": 0,
        "zakat_fitrah": 20000,
        "bri": 0,
        "zakat": 0,
        "bsm": 0,
        "total": 40000 
      },
      
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