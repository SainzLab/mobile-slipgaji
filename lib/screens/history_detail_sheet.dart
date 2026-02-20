import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../constants/app_colors.dart';
import '../models/gaji_model.dart';
import '../models/tpp_model.dart';

class HistoryDetailSheet extends StatelessWidget {
  final String month;
  final Gaji? gaji;
  final Tpp? tpp;

  const HistoryDetailSheet({
    super.key, 
    required this.month, 
    required this.gaji, 
    required this.tpp
  });

  @override
  Widget build(BuildContext context) {
    final int thpFinal = (gaji?.jumlahDiterima ?? 0) + (tpp?.jumlahDiterima ?? 0);
    
    final int gajiIncome = gaji?.jumlahKotor ?? 0;
    final int tppIncome = tpp?.jumlahKotor ?? 0;

    final int potGaji = gaji?.jumlahPotongan ?? 0;
    final int potTpp = tpp?.jumlahPotongan ?? 0;

    final int netGaji = gaji?.jumlahDiterima ?? 0;
    final int netTpp = tpp?.jumlahDiterima ?? 0;

    Future<void> generatePdf() async {
      final pdf = pw.Document();
      final fontStyle = pw.TextStyle(fontSize: 9);
      final titleStyle = pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold);
      final headerStyle = pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold);

      pw.Widget buildPdfRow(String label, int value, {bool isBold = false}) {
        if (value == 0 && !isBold) return pw.Container();
        return pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 2),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(label, style: isBold ? titleStyle : fontStyle),
              pw.Text(_formatRupiah(value), style: isBold ? titleStyle : fontStyle),
            ],
          ),
        );
      }

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(child: pw.Text("SLIP GAJI & TPP", style: headerStyle)),
                pw.Center(child: pw.Text("Periode: $month", style: fontStyle)),
                pw.SizedBox(height: 15),
                pw.Divider(),

                if (gaji != null) ...[
                  pw.Text("I. RINCIAN GAJI", style: titleStyle),
                  pw.SizedBox(height: 5),
                
                  buildPdfRow("Gaji Pokok", gaji!.gajiPokok),
                  buildPdfRow("Tunj. Keluarga", gaji!.tunjKeluarga),
                  buildPdfRow("Tunj. Jabatan", gaji!.tunjJabatan),
                  buildPdfRow("Tunj. Fungsional", gaji!.tunjFungsional),
                  buildPdfRow("Tunj. Fung. Umum", gaji!.tunjFungsionalUmum),
                  buildPdfRow("Tunj. Beras", gaji!.tunjBeras),
                  buildPdfRow("Tunj. Khusus", gaji!.tunjKhusus),
                  buildPdfRow("Tunj. Pajak", gaji!.tunjPajak),
                  buildPdfRow("Pembulatan", gaji!.pembulatan),
                  buildPdfRow("Tunj. BPJS", gaji!.iuranBpjs),
                  buildPdfRow("Tunj. JKK", gaji!.iuranJkk),
                  buildPdfRow("Tunj. JKM", gaji!.iuranJkm),
                  buildPdfRow("Tunj. JHT", gaji!.tunjJht),
                  pw.Divider(thickness: 0.5),
                  buildPdfRow("TOTAL GAJI KOTOR", gajiIncome, isBold: true),
                  
                  pw.SizedBox(height: 8),
                  
                  pw.Text("Potongan Gaji:", style: fontStyle),
                  buildPdfRow("Potongan IWP", gaji!.potonganIwp),
                  buildPdfRow("Potongan PPh", gaji!.potonganPph),
                  buildPdfRow("BPJS Kesehatan", gaji!.iuranBpjs),
                  buildPdfRow("Simpanan", gaji!.iuranSimpanan),
                  buildPdfRow("Pensiun", gaji!.iuranPensiun),
                  buildPdfRow("Zakat", gaji!.zakat),
                  buildPdfRow("Bulog", gaji!.bulog),
                  pw.Divider(thickness: 0.5),
                  buildPdfRow("TOTAL POTONGAN GAJI", potGaji, isBold: true),
                  pw.SizedBox(height: 5),
                  pw.Container(
                    color: PdfColors.blue50,
                    padding: const pw.EdgeInsets.all(5),
                    child: buildPdfRow("GAJI BERSIH", netGaji, isBold: true),
                  ),
                ],

                pw.SizedBox(height: 15),

                if (tpp != null) ...[
                  pw.Text("II. RINCIAN TPP", style: titleStyle),
                  pw.SizedBox(height: 5),
                  buildPdfRow("Beban Kerja", tpp!.bebanKerja),
                  buildPdfRow("Prestasi Kerja", tpp!.prestasiKerja),
                  buildPdfRow("Kondisi Kerja", tpp!.kondisiKerja),
                  buildPdfRow("Kelangkaan Profesi", tpp!.kelangkaanProfesi),
                  buildPdfRow("Tempat Bertugas", tpp!.tempatBertugas),
                  buildPdfRow("Tunj. Jabatan (TPP)", tpp!.tunjanganJabatan),
                  buildPdfRow("Tunj. BPJS (TPP)", tpp!.iuranBpjs),
                  pw.Divider(thickness: 0.5),
                  buildPdfRow("TOTAL TPP KOTOR", tppIncome, isBold: true),
                  
                  pw.SizedBox(height: 8),
                  
                  pw.Text("Potongan TPP:", style: fontStyle),
                  buildPdfRow("PPh 21 (TPP)", tpp!.potonganPph),
                  buildPdfRow("IWP (TPP)", tpp!.potonganIwp),
                  buildPdfRow("BPJS Kesehatan (TPP)", tpp!.iuranBpjs),
                  buildPdfRow("Simpanan (TPP)", tpp!.iuranSimpanan),
                  buildPdfRow("Pensiun (TPP)", tpp!.iuranPensiun),
                  buildPdfRow("Zakat (TPP)", tpp!.zakat),
                  buildPdfRow("Bulog (TPP)", tpp!.bulog),
                  pw.Divider(thickness: 0.5),
                  buildPdfRow("TOTAL POTONGAN TPP", potTpp, isBold: true),
                  pw.SizedBox(height: 5),
                  pw.Container(
                    color: PdfColors.green50,
                    padding: const pw.EdgeInsets.all(5),
                    child: buildPdfRow("TPP BERSIH", netTpp, isBold: true),
                  ),
                ],

                pw.SizedBox(height: 20),
                pw.Divider(thickness: 2),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("TOTAL DITERIMA (NET)", style: headerStyle),
                    pw.Text(_formatRupiah(thpFinal), style: headerStyle),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Center(child: pw.Text("* Dokumen ini valid dan dicetak melalui aplikasi SiGaji", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey))),
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'SlipGaji-$month',
      );
    }

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
                    Text("Slip Gaji & TPP", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    Text(month, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.dark)),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: generatePdf, 
                      icon: const Icon(Icons.print_rounded, color: AppColors.primary),
                      tooltip: "Cetak PDF",
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                      child: Text(_formatRupiah(thpFinal), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
                    )
                  ],
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
                
                if (gaji != null) ...[
                  _buildSectionHeader("RINCIAN GAJI", AppColors.primary),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildRowHeader("Pendapatan"),
                        _buildRow("Gaji Pokok", gaji!.gajiPokok),
                        _buildRow("Tunj. Keluarga", gaji!.tunjKeluarga),
                        _buildRow("Tunj. Jabatan", gaji!.tunjJabatan),
                        _buildRow("Tunj. Fungsional", gaji!.tunjFungsional),
                        _buildRow("Tunj. Fung. Umum", gaji!.tunjFungsionalUmum),
                        _buildRow("Tunj. Beras", gaji!.tunjBeras),
                        _buildRow("Tunj. Khusus", gaji!.tunjKhusus),
                        _buildRow("Tunj. Pajak", gaji!.tunjPajak),
                        _buildRow("Pembulatan", gaji!.pembulatan),
                        _buildDivider(),
                        _buildRow("Tunj. BPJS", gaji!.iuranBpjs),
                        _buildRow("Tunj. JKK", gaji!.iuranJkk),
                        _buildRow("Tunj. JKM", gaji!.iuranJkm),
                        _buildRow("Tunj. JHT", gaji!.tunjJht),
                        _buildDivider(),
                        _buildRow("Jumlah Kotor", gajiIncome, isBold: true),
                        
                        const SizedBox(height: 16),
                        
                        _buildRowHeader("Potongan"),
                        _buildRow("Potongan IWP (10%)", gaji!.potonganIwp),
                        _buildRow("Potongan PPh", gaji!.potonganPph),
                        _buildRow("BPJS Kesehatan", gaji!.iuranBpjs),
                        _buildRow("Simpanan", gaji!.iuranSimpanan),
                        _buildRow("Pensiun", gaji!.iuranPensiun),
                        _buildRow("Zakat", gaji!.zakat),
                        _buildRow("Bulog", gaji!.bulog),
                        _buildDivider(),
                        _buildRow("Jumlah Potongan", potGaji, isBold: true, valueColor: AppColors.danger),
                        
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                          child: _buildRow("Gaji Bersih", netGaji, isBold: true, valueColor: AppColors.primary),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                if (tpp != null) ...[
                  _buildSectionHeader("RINCIAN TPP", AppColors.secondary),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildRowHeader("Pendapatan"),
                        _buildRow("Beban Kerja", tpp!.bebanKerja),
                        _buildRow("Prestasi Kerja", tpp!.prestasiKerja),
                        _buildRow("Kondisi Kerja", tpp!.kondisiKerja),
                        _buildRow("Kelangkaan Profesi", tpp!.kelangkaanProfesi),
                        _buildRow("Tempat Bertugas", tpp!.tempatBertugas),
                        _buildRow("Tunj. Jabatan (TPP)", tpp!.tunjanganJabatan),
                        _buildRow("Tunj. BPJS (TPP)", tpp!.iuranBpjs),
                        _buildDivider(),
                        _buildRow("Jumlah Kotor", tppIncome, isBold: true),

                        const SizedBox(height: 16),

                        _buildRowHeader("Potongan"),
                        _buildRow("PPh 21 (TPP)", tpp!.potonganPph),
                        _buildRow("IWP (TPP)", tpp!.potonganIwp),
                        _buildRow("BPJS Kesehatan (TPP)", tpp!.iuranBpjs),
                        _buildRow("Simpanan (TPP)", tpp!.iuranSimpanan),
                        _buildRow("Pensiun (TPP)", tpp!.iuranPensiun),
                        _buildRow("Zakat (TPP)", tpp!.zakat),
                        _buildRow("Bulog (TPP)", tpp!.bulog),
                        _buildDivider(),
                        _buildRow("Jumlah Potongan", potTpp, isBold: true, valueColor: AppColors.warning),

                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                          child: _buildRow("TPP Bersih", netTpp, isBold: true, valueColor: AppColors.secondary),
                        )
                      ],
                    ),
                  ),
                ],
                
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

  Widget _buildRowHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(), 
          style: TextStyle(
            fontSize: 12, 
            fontWeight: FontWeight.bold, 
            color: Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, int value, {bool isBold = false, Color? valueColor}) {
    if (value == 0 && !isBold) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: isBold ? AppColors.dark : Colors.grey.shade600, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(_formatRupiah(value), style: TextStyle(fontSize: 13, fontWeight: isBold ? FontWeight.bold : FontWeight.w500, color: valueColor ?? AppColors.dark)),
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

  String _formatRupiah(num number) {
    final str = number.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    return "Rp $str";
  }
}