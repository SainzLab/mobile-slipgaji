import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../data/salary_data.dart';

class HistoryDetailSheet extends StatelessWidget {
  final Map<String, dynamic> data;

  const HistoryDetailSheet({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    int val(dynamic source, String key) => (source != null && source[key] != null) ? source[key] as int : 0;

    final gajiIncome = val(data['gaji'], 'jumlah_kotor');
    
    final potGajiSipd = 
        val(data['gaji'], 'potongan_iwp') + 
        val(data['gaji'], 'potongan_pph21') + 
        val(data['gaji'], 'potongan_bpjs_kes') + 
        val(data['gaji'], 'potongan_jkk') + 
        val(data['gaji'], 'potongan_jkm') + 
        val(data['gaji'], 'potongan_jht') + 
        val(data['gaji'], 'potongan_tapera') + 
        val(data['gaji'], 'potongan_bulog');
        
    final netGajiSipd = gajiIncome - potGajiSipd; 
    final tppIncome = val(data['tpp'], 'jumlah_kotor');

    final potTppSipd = 
        val(data['tpp'], 'potongan_iwp') + 
        val(data['tpp'], 'potongan_pph21') + 
        val(data['tpp'], 'potongan_bpjs_kes');

    final netTppSipd = tppIncome - potTppSipd;
    final grandTotalSipd = netGajiSipd + netTppSipd; 
    final thpFinal = val(data['summary'], 'thp_total');

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, 
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Slip Gaji (SIPD)", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    Text(data['month'] ?? "Detail Gaji", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.dark)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text(SalaryData.formatRupiah(thpFinal), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
                )
              ],
            ),
          ),
          const Divider(height: 1),

          Flexible(
            child: ListView(
              padding: const EdgeInsets.all(16),
              shrinkWrap: true,
              children: [
                
                _buildSectionHeader("RINCIAN GAJI", AppColors.primary),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildRowHeader("Pendapatan"),
                      _buildRow("Gaji Pokok", val(data['gaji'], 'pokok')),
                      _buildRow("Tunjangan Keluarga", val(data['gaji'], 'tunj_keluarga')),
                      _buildRow("Tunjangan Jabatan", val(data['gaji'], 'tunj_jabatan')),
                      _buildRow("Tunjangan Fungsional", val(data['gaji'], 'tunj_fungsional')),
                      _buildRow("Tunjangan Fungsional Umum", val(data['gaji'], 'tunj_fungsional_umum')),
                      _buildRow("Tunjangan Beras", val(data['gaji'], 'tunj_beras')),
                      _buildRow("Tunjangan PPh", val(data['gaji'], 'tunj_pph')),
                      _buildRow("Pembulatan", val(data['gaji'], 'pembulatan')),
                      _buildRow("Tunj. Khusus Papua", 0),
                      _buildRow("Tunj. Jamsostek (BPJS)", val(data['gaji'], 'tunj_bpjs_kes')),
                      _buildRow("Tunj. Kerja (JKK)", val(data['gaji'], 'tunj_jkk')),
                      _buildRow("Tunj. Kematian (JKM)", val(data['gaji'], 'tunj_jkm')),
                      _buildRow("Tunj. Tapera", val(data['gaji'], 'tunj_tapera')),
                      _buildDivider(),
                      _buildRow("Jumlah Kotor", gajiIncome, isBold: true),
                      
                      const SizedBox(height: 16),
                      
                      _buildRowHeader("Potongan"),
                      _buildRow("Potongan IWP (10%)", val(data['gaji'], 'potongan_iwp')),
                      _buildRow("Potongan PPh", val(data['gaji'], 'potongan_pph21')),
                      _buildRow("Potongan Zakat", val(data['gaji'], 'potongan_zakat')),
                      _buildRow("Potongan Bulog", val(data['gaji'], 'potongan_bulog')),
                      _buildRow("Potongan BPJS", val(data['gaji'], 'potongan_bpjs_kes')),
                      _buildRow("Potongan JKK", val(data['gaji'], 'potongan_jkk')),
                      _buildRow("Potongan JKM", val(data['gaji'], 'potongan_jkm')),
                      _buildRow("Potongan Tapera", val(data['gaji'], 'potongan_tapera')),
                      _buildRow("Potongan JHT", val(data['gaji'], 'potongan_jht')),
                      _buildDivider(),
                      _buildRow("Jumlah Potongan", potGajiSipd, isBold: true, valueColor: AppColors.danger),
                      
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                        child: _buildRow("Gaji Bersih (SIPD)", netGajiSipd, isBold: true, valueColor: AppColors.primary),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                _buildSectionHeader("RINCIAN TPP", AppColors.secondary),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildRowHeader("Pendapatan"),
                      _buildRow("Beban Kerja", val(data['tpp'], 'beban_kerja')),
                      _buildRow("Kondisi Kerja", val(data['tpp'], 'kondisi_kerja')),
                      _buildRow("Kelangkaan Profesi", val(data['tpp'], 'kelangkaan_profesi')),
                      _buildRow("Prestasi Kerja", val(data['tpp'], 'prestasi_kerja')),
                      _buildRow("Tunjangan BPJS Kes", val(data['tpp'], 'tunj_bpjs_kes')),
                      _buildDivider(),
                      _buildRow("Jumlah Kotor", tppIncome, isBold: true),

                      const SizedBox(height: 16),

                      _buildRowHeader("Potongan"),
                      _buildRow("Potongan PPh 21", val(data['tpp'], 'potongan_pph21')),
                      _buildRow("Potongan IWP (1% & 4%)", val(data['tpp'], 'potongan_iwp')),
                      _buildRow("Potongan BPJS", val(data['tpp'], 'potongan_bpjs_kes')),
                      _buildDivider(),
                      _buildRow("Jumlah Potongan", potTppSipd, isBold: true, valueColor: AppColors.warning),

                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                        child: _buildRow("TPP Bersih (SIPD)", netTppSipd, isBold: true, valueColor: AppColors.secondary),
                      )
                    ],
                  ),
                ),
                
                const SizedBox(height: 40), 
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Row(
      children: [
        Container(width: 4, height: 18, color: color, margin: const EdgeInsets.only(right: 8)),
        Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color, letterSpacing: 1.0)),
      ],
    );
  }

  Widget _buildRowHeader(String title, {Color color = Colors.black87}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(), 
          style: TextStyle(
            fontSize: 12, 
            fontWeight: FontWeight.bold, 
            color: color.withOpacity(0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, int value, {bool isBold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: isBold ? AppColors.dark : Colors.grey.shade600, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(SalaryData.formatRupiah(value), style: TextStyle(fontSize: 13, fontWeight: isBold ? FontWeight.bold : FontWeight.w500, color: valueColor ?? AppColors.dark)),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Divider(height: 1, color: Colors.grey.shade200),
    );
  }
}