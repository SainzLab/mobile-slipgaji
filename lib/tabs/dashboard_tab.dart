import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_colors.dart';
import '../screens/ai_chat_sheet.dart';
import '../services/api_service.dart';
import '../models/gaji_model.dart';
import '../models/tpp_model.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  Future<Map<String, dynamic>>? _dataFuture;
  String _userName = "Pegawai";
  String _userNip = "-";

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _dataFuture = _fetchDashboardData();
  }

  void _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userNip = prefs.getString('nip') ?? "-";
    });
  }

  Future<Map<String, dynamic>> _fetchDashboardData() async {
    final api = ApiService();
    
    final results = await Future.wait([
      api.getGajiHistory(),
      api.getTppHistory(),
    ]);

    final listGaji = results[0] as List<Gaji>;
    final listTpp = results[1] as List<Tpp>;

    return {
      'gaji': listGaji.isNotEmpty ? listGaji.first : null,
      'tpp': listTpp.isNotEmpty ? listTpp.first : null,
    };
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _dataFuture = _fetchDashboardData();
    });
  }

  String formatRupiah(num number) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(number);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const AiChatSheet(),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.smart_toy_rounded, color: Colors.white),
        label: const Text("Tanya AI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppColors.primary,
        child: FutureBuilder<Map<String, dynamic>>(
          future: _dataFuture,
          builder: (context, snapshot) {
 
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text("Terjadi kesalahan: ${snapshot.error}"));
            }

            final Gaji? gaji = snapshot.data?['gaji'];
            final Tpp? tpp = snapshot.data?['tpp'];

            if (gaji == null && tpp == null) {
              return ListView(
                children: const [
                   SizedBox(height: 100),
                   Center(child: Text("Belum ada data gaji untuk periode ini.")),
                ],
              );
            }

            final int thpGaji = gaji?.jumlahDiterima ?? 0;
            final int thpTpp = tpp?.jumlahDiterima ?? 0;
            final int totalThp = thpGaji + thpTpp;
            
            final int potGaji = gaji?.jumlahPotongan ?? 0;
            final int potTpp = tpp?.jumlahPotongan ?? 0;
            final int totalPotongan = potGaji + potTpp;

            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverAppBar(
                  expandedHeight: 80,
                  floating: true,
                  backgroundColor: AppColors.background,
                  surfaceTintColor: Colors.transparent,
                  title: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.warning, 
                        child: const Text("P", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_userName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.dark)),
                            Text("NIP. $_userNip", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
                        // --- CARD UTAMA (THP) ---
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2563EB), Color(0xFF1E40AF)], 
                              begin: Alignment.topLeft, 
                              end: Alignment.bottomRight
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
                            ],
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Total Diterima (Net)", style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1)),
                              const SizedBox(height: 4),
                              Text(
                                formatRupiah(totalThp), 
                                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)
                              ),
                              const SizedBox(height: 16),
                              Container(height: 1, color: Colors.white24),
                              const SizedBox(height: 16),
                              _buildTransferRow("Transfer Gaji", thpGaji, Colors.blue.shade100),
                              const SizedBox(height: 8),
                              _buildTransferRow("Transfer TPP", thpTpp, Colors.green.shade100),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),
                        const Text("Ringkasan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(child: _buildStatCard("Gaji Kotor", gaji?.jumlahKotor ?? 0, AppColors.primary, Icons.monetization_on)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildStatCard("TPP Kotor", tpp?.jumlahKotor ?? 0, AppColors.secondary, Icons.trending_up)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildStatCard("Total Potongan", totalPotongan, AppColors.danger, Icons.pie_chart, fullWidth: true),

                        const SizedBox(height: 24),
                        const Text("Rincian Lengkap", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),

                        // --- EXPANDABLE: GAJI ---
                        // --- EXPANDABLE: GAJI ---
                        if (gaji != null) 
                        _buildExpandableSection(
                          title: "Rincian Gaji (Pendapatan)",
                          color: AppColors.primary,
                          items: {
                            "Gaji Pokok": gaji.gajiPokok,
                            "Tunj. Keluarga": gaji.tunjKeluarga,
                            "Tunj. Jabatan": gaji.tunjJabatan,
                            "Tunj. Fungsional": gaji.tunjFungsional,
                            "Tunj. Fung. Umum": gaji.tunjFungsionalUmum,
                            "Tunj. Beras": gaji.tunjBeras,
                            "Tunj. Khusus": gaji.tunjKhusus,
                            "Tunj. Pajak": gaji.tunjPajak,
                            "Pembulatan": gaji.pembulatan,
                            "Tunj. BPJS": gaji.iuranBpjs,
                            "Tunj. JKK": gaji.iuranJkk,
                            "Tunj. JKM": gaji.iuranJkm,
                            "Tunj. JHT": gaji.tunjJht,
                          },
                        ),
                        const SizedBox(height: 12),

                        if (tpp != null)
                        _buildExpandableSection(
                          title: "Rincian TPP (Pendapatan)",
                          color: AppColors.secondary,
                          items: {
                            "Beban Kerja": tpp.bebanKerja,
                            "Prestasi Kerja": tpp.prestasiKerja,
                            "Kondisi Kerja": tpp.kondisiKerja,
                            "Kelangkaan Profesi": tpp.kelangkaanProfesi,
                            "Tempat Bertugas": tpp.tempatBertugas,
                            "Tunj. BPJS Kesehatan": tpp.iuranBpjs,
                          },
                        ),
                        const SizedBox(height: 12),

                        if (gaji != null)
                        _buildExpandableSection(
                          title: "Potongan Gaji",
                          color: AppColors.danger,
                          items: {
                            "IWP (10%)": gaji.potonganIwp,
                            "PPh 21": gaji.potonganPph,
                            "BPJS Kesehatan": gaji.iuranBpjs, 
                            "Iuran Pensiun": gaji.iuranPensiun,
                            "Simpanan": gaji.iuranSimpanan,
                            "Zakat": gaji.zakat,
                            "Bulog": gaji.bulog,
                          },
                        ),
                        const SizedBox(height: 12),

                        if (tpp != null)
                        _buildExpandableSection(
                          title: "Potongan TPP",
                          color: AppColors.warning,
                          items: {
                            "PPh 21 (TPP)": tpp.potonganPph,
                            "IWP (TPP)": tpp.potonganIwp,
                            "BPJS (TPP)": tpp.iuranBpjs,
                            "Iuran Pensiun": tpp.iuranPensiun,
                            "Simpanan": tpp.iuranSimpanan,
                            "Zakat": tpp.zakat,
                            "Bulog": tpp.bulog,
                          },
                        ),
                        
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                )
              ],
            );
          }
        ),
      ),
    );
  }

  Widget _buildTransferRow(String label, int amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.check_circle, size: 16, color: color),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
          ],
        ),
        Text(formatRupiah(amount), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildStatCard(String title, int value, Color color, IconData icon, {bool fullWidth = false}) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 12),
          Text(formatRupiah(value), style: TextStyle(color: AppColors.dark, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildExpandableSection({required String title, required Color color, required Map<String, int> items}) {
    final itemList = items.entries.toList();

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        shape: const Border(),
        leading: Container(
          width: 4, height: 24, 
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))
        ),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: itemList.map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      e.key, 
                      style: TextStyle(fontSize: 13, color: e.value > 0 ? Colors.grey.shade700 : Colors.grey.shade400)
                    ),
                    Text(
                      formatRupiah(e.value), 
                      style: TextStyle(
                        fontSize: 13, 
                        fontWeight: FontWeight.w500,
                        color: e.value > 0 ? AppColors.dark : Colors.grey.shade400
                      )
                    ),
                  ],
                ),
              )).toList(),
            ),
          )
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import '../constants/app_colors.dart';
// import '../data/salary_data.dart';
// import '../screens/ai_chat_sheet.dart';

// class DashboardTab extends StatelessWidget {
//   const DashboardTab({super.key});

//   Future<void> _handleRefresh() async {
//     await Future.delayed(const Duration(seconds: 2));
//   }

//   @override
//   Widget build(BuildContext context) {
//     final d = SalaryData.data;

//     int val(Map<String, dynamic> source, String key) => (source[key] ?? 0) as int;

//     final totalPotongan = 
//         val(d['gaji'], 'potongan_sipd') + 
//         val(d['tpp'], 'potongan_sipd') + 
//         val(d['potongan_eksternal']['gaji'], 'total') + 
//         val(d['potongan_eksternal']['tpp'], 'total');

//     return Scaffold(
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () {
//           showModalBottomSheet(
//             context: context,
//             isScrollControlled: true,
//             backgroundColor: Colors.transparent,
//             builder: (context) => const AiChatSheet(),
//           );
//         },
//         backgroundColor: AppColors.primary,
//         icon: const Icon(Icons.smart_toy_rounded, color: Colors.white),
//         label: const Text("AI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//       ),

//       body: RefreshIndicator(
//         onRefresh: _handleRefresh,
//         color: AppColors.primary,
//         backgroundColor: Colors.white,
//         child: CustomScrollView(
//           physics: const AlwaysScrollableScrollPhysics(),
//           slivers: [
//             SliverAppBar(
//               expandedHeight: 80,
//               floating: true,
//               backgroundColor: AppColors.background,
//               surfaceTintColor: Colors.transparent,
//               title: Row(
//                 children: [
//                   CircleAvatar(
//                     backgroundColor: AppColors.warning, 
//                     child: const Text("FM", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(d['pegawai']['nama'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.dark)),
//                         Text("NIP. ${d['pegawai']['nip']}", style: const TextStyle(fontSize: 11, color: Colors.grey)),
//                       ],
//                     ),
//                   )
//                 ],
//               ),
//             ),
            
//             SliverToBoxAdapter(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
                    
//                     Container(
//                       decoration: BoxDecoration(
//                         gradient: const LinearGradient(
//                           colors: [Color(0xFF2563EB), Color(0xFF1E40AF)], 
//                           begin: Alignment.topLeft, 
//                           end: Alignment.bottomRight
//                         ),
//                         borderRadius: BorderRadius.circular(20),
//                         boxShadow: [
//                           BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
//                         ],
//                       ),
//                       padding: const EdgeInsets.all(20),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text("Total Diterima (Net)", style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1)),
//                           const SizedBox(height: 4),
//                           Text(
//                             SalaryData.formatRupiah(val(d['summary'], 'thp_total')), 
//                             style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)
//                           ),
//                           const SizedBox(height: 16),
//                           Container(height: 1, color: Colors.white24),
//                           const SizedBox(height: 16),
//                           _buildTransferRow("Transfer Gaji", val(d['summary'], 'thp_gaji'), Colors.blue.shade100),
//                           const SizedBox(height: 8),
//                           _buildTransferRow("Transfer TPP", val(d['summary'], 'thp_tpp'), Colors.green.shade100),
//                         ],
//                       ),
//                     ),

//                     const SizedBox(height: 24),
//                     const Text("Ringkasan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                     const SizedBox(height: 12),

//                     Row(
//                       children: [
//                         Expanded(child: _buildStatCard("Gaji Kotor", val(d['gaji'], 'jumlah_kotor'), AppColors.primary, Icons.monetization_on)),
//                         const SizedBox(width: 12),
//                         Expanded(child: _buildStatCard("TPP Kotor", val(d['tpp'], 'jumlah_kotor'), AppColors.secondary, Icons.trending_up)),
//                       ],
//                     ),
//                     const SizedBox(height: 12),
//                     _buildStatCard("Total Potongan (Semua)", totalPotongan, AppColors.danger, Icons.pie_chart, fullWidth: true),

//                     const SizedBox(height: 24),
//                     const Text("Rincian Lengkap", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                     const SizedBox(height: 12),

//                     _buildExpandableSection(
//                       title: "Rincian Gaji",
//                       color: AppColors.primary,
//                       items: {
//                         "Gaji Pokok": val(d['gaji'], 'pokok'),
//                         "Tunj. Keluarga": val(d['gaji'], 'tunj_keluarga'),
//                         "Tunj. Jabatan": val(d['gaji'], 'tunj_jabatan'),
//                         "Tunj. Fungsional": val(d['gaji'], 'tunj_fungsional'),
//                         "Tunj. Fungsional Umum": val(d['gaji'], 'tunj_fungsional_umum'),
//                         "Tunj. Beras": val(d['gaji'], 'tunj_beras'),
//                         "Tunj. PPh": val(d['gaji'], 'tunj_pph'),
//                         "Pembulatan": val(d['gaji'], 'pembulatan'),
//                         "Tunj. BPJS Kes": val(d['gaji'], 'tunj_bpjs_kes'),
//                         "Tunj. JKK": val(d['gaji'], 'tunj_jkk'),
//                         "Tunj. JKM": val(d['gaji'], 'tunj_jkm'),
//                         "Tunj. Tapera": val(d['gaji'], 'tunj_tapera'),
//                         "Tunj. JHT": val(d['gaji'], 'tunj_jht'),
//                       },
//                     ),
//                     const SizedBox(height: 12),

//                     _buildExpandableSection(
//                       title: "Rincian TPP",
//                       color: AppColors.secondary,
//                       items: {
//                         "Beban Kerja": val(d['tpp'], 'beban_kerja'),
//                         "Prestasi Kerja": val(d['tpp'], 'prestasi_kerja'),
//                         "Kondisi Kerja": val(d['tpp'], 'kondisi_kerja'),
//                         "Kelangkaan Profesi": val(d['tpp'], 'kelangkaan_profesi'),
//                         "Tunj. BPJS (TPP)": val(d['tpp'], 'tunj_bpjs_kes'),
//                       },
//                     ),
//                     const SizedBox(height: 12),

//                     _buildExpandableSection(
//                       title: "Potongan Gaji",
//                       color: AppColors.danger,
//                       items: {
//                         "IWP (1% + 8%)": val(d['gaji'], 'potongan_iwp'),
//                         "PPh 21 Gaji": val(d['gaji'], 'potongan_pph21'),
//                         "BPJS Kes (Gaji)": val(d['gaji'], 'potongan_bpjs_kes'),
//                         "Jaminan Kecelakaan (JKK)": val(d['gaji'], 'potongan_jkk'),
//                         "Jaminan Kematian (JKM)": val(d['gaji'], 'potongan_jkm'),
//                         "Jaminan Hari Tua (JHT)": val(d['gaji'], 'potongan_jht'),
//                         "Tapera": val(d['gaji'], 'potongan_tapera'),
//                         "Bulog": val(d['gaji'], 'potongan_bulog'),
                        
//                         "Korpri": val(d['potongan_eksternal']['gaji'], 'korpri'),
//                         "Dharma Wanita": val(d['potongan_eksternal']['gaji'], 'dharma_wanita'),
//                         "Koperasi": val(d['potongan_eksternal']['gaji'], 'koperasi'),
//                         "Bank BJB": val(d['potongan_eksternal']['gaji'], 'bjb'),
//                         "Bank BJB Syariah": val(d['potongan_eksternal']['gaji'], 'bjb_syariah'),
//                         "Bank BRI": val(d['potongan_eksternal']['gaji'], 'bri'),
//                         "Bank Syariah Mandiri": val(d['potongan_eksternal']['gaji'], 'bsm'),
//                         "Zakat Fitrah": val(d['potongan_eksternal']['gaji'], 'zakat_fitrah'),
//                         "Zakat Mal": val(d['potongan_eksternal']['gaji'], 'zakat'),
//                       },
//                     ),
//                     const SizedBox(height: 12),

//                     _buildExpandableSection(
//                       title: "Potongan TPP",
//                       color: AppColors.warning,
//                       items: {
//                         "IWP (TPP)": val(d['tpp'], 'potongan_iwp'),
//                         "PPh 21 (TPP)": val(d['tpp'], 'potongan_pph21'),
//                         "BPJS Kes (TPP)": val(d['tpp'], 'potongan_bpjs_kes'),

//                         "Bank BJB (TPP)": val(d['potongan_eksternal']['tpp'], 'bjb'),
//                         "Gotong Royong": val(d['potongan_eksternal']['tpp'], 'gotroy'),
//                         "BPR Otista": val(d['potongan_eksternal']['tpp'], 'bpr_otista'),
//                         "BPR Pasar": val(d['potongan_eksternal']['tpp'], 'bpr_pasar'),
//                         "Bendahara": val(d['potongan_eksternal']['tpp'], 'bendahara'),
//                       },
//                     ),
//                     const SizedBox(height: 80),
//                   ],
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTransferRow(String label, int amount, Color color) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Row(
//           children: [
//             Icon(Icons.check_circle, size: 16, color: color),
//             const SizedBox(width: 8),
//             Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
//           ],
//         ),
//         Text(SalaryData.formatRupiah(amount), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//       ],
//     );
//   }

//   Widget _buildStatCard(String title, int value, Color color, IconData icon, {bool fullWidth = false}) {
//     return Container(
//       width: fullWidth ? double.infinity : null,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.grey.shade100),
//         boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 4, offset: const Offset(0, 2))],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(6),
//                 decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
//                 child: Icon(icon, color: color, size: 18),
//               ),
//               const SizedBox(width: 8),
//               Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w500)),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Text(SalaryData.formatRupiah(value), style: TextStyle(color: AppColors.dark, fontSize: 16, fontWeight: FontWeight.bold)),
//         ],
//       ),
//     );
//   }

//   Widget _buildExpandableSection({required String title, required Color color, required Map<String, int> items}) {
//     final itemList = items.entries.toList();

//     return Card(
//       elevation: 0,
//       color: Colors.white,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//         side: BorderSide(color: Colors.grey.shade200),
//       ),
//       child: ExpansionTile(
//         shape: const Border(),
//         leading: Container(
//           width: 4, height: 24, 
//           decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))
//         ),
//         title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
//         children: [
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//             child: Column(
//               children: itemList.map((e) => Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 6),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       e.key, 
//                       style: TextStyle(fontSize: 13, color: e.value > 0 ? Colors.grey.shade700 : Colors.grey.shade400)
//                     ),
//                     Text(
//                       SalaryData.formatRupiah(e.value), 
//                       style: TextStyle(
//                         fontSize: 13, 
//                         fontWeight: FontWeight.w500,
//                         color: e.value > 0 ? AppColors.dark : Colors.grey.shade400
//                       )
//                     ),
//                   ],
//                 ),
//               )).toList(),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import '../constants/app_colors.dart';
// import '../data/salary_data.dart';

// class DashboardTab extends StatelessWidget {
//   const DashboardTab({super.key});

//   // Fungsi simulasi refresh (Nanti diganti dengan panggil API)
//   Future<void> _handleRefresh() async {
//     // Pura-pura loading selama 2 detik
//     await Future.delayed(const Duration(seconds: 2));
    
//     // Di sini nanti Anda bisa panggil fungsi untuk update data
//     // Contoh: await SalaryData.fetchLatestData();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final d = SalaryData.data;

//     int val(Map<String, dynamic> source, String key) => (source[key] ?? 0) as int;

//     final totalPotongan = 
//         val(d['gaji'], 'potongan_sipd') + 
//         val(d['tpp'], 'potongan_sipd') + 
//         val(d['potongan_eksternal']['gaji'], 'total') + 
//         val(d['potongan_eksternal']['tpp'], 'total');

//     return Scaffold(
//       // 1. BUNGKUS DENGAN REFRESH INDICATOR
//       body: RefreshIndicator(
//         onRefresh: _handleRefresh,
//         color: AppColors.primary, // Warna loading
//         backgroundColor: Colors.white,
//         child: CustomScrollView(
//           // 2. TAMBAHKAN PHYSICS AGAR SELALU BISA DI-SWIPE
//           physics: const AlwaysScrollableScrollPhysics(),
//           slivers: [
//             SliverAppBar(
//               expandedHeight: 80,
//               floating: true,
//               backgroundColor: AppColors.background,
//               surfaceTintColor: Colors.transparent,
//               title: Row(
//                 children: [
//                   CircleAvatar(
//                     backgroundColor: AppColors.warning, 
//                     child: const Text("FM", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(d['pegawai']['nama'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.dark)),
//                         Text("NIP. ${d['pegawai']['nip']}", style: const TextStyle(fontSize: 11, color: Colors.grey)),
//                       ],
//                     ),
//                   )
//                 ],
//               ),
//             ),
            
//             SliverToBoxAdapter(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
                    
//                     Container(
//                       decoration: BoxDecoration(
//                         gradient: const LinearGradient(
//                           colors: [Color(0xFF2563EB), Color(0xFF1E40AF)], 
//                           begin: Alignment.topLeft, 
//                           end: Alignment.bottomRight
//                         ),
//                         borderRadius: BorderRadius.circular(20),
//                         boxShadow: [
//                           BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
//                         ],
//                       ),
//                       padding: const EdgeInsets.all(20),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text("Total Diterima (Net)", style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1)),
//                           const SizedBox(height: 4),
//                           Text(
//                             SalaryData.formatRupiah(val(d['summary'], 'thp_total')), 
//                             style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)
//                           ),
//                           const SizedBox(height: 16),
//                           Container(height: 1, color: Colors.white24),
//                           const SizedBox(height: 16),
//                           _buildTransferRow("Transfer Gaji", val(d['summary'], 'thp_gaji'), Colors.blue.shade100),
//                           const SizedBox(height: 8),
//                           _buildTransferRow("Transfer TPP", val(d['summary'], 'thp_tpp'), Colors.green.shade100),
//                         ],
//                       ),
//                     ),

//                     const SizedBox(height: 24),
//                     const Text("Ringkasan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                     const SizedBox(height: 12),

//                     Row(
//                       children: [
//                         Expanded(child: _buildStatCard("Gaji Kotor", val(d['gaji'], 'jumlah_kotor'), AppColors.primary, Icons.monetization_on)),
//                         const SizedBox(width: 12),
//                         Expanded(child: _buildStatCard("TPP Kotor", val(d['tpp'], 'jumlah_kotor'), AppColors.secondary, Icons.trending_up)),
//                       ],
//                     ),
//                     const SizedBox(height: 12),
//                     _buildStatCard("Total Potongan (Semua)", totalPotongan, AppColors.danger, Icons.pie_chart, fullWidth: true),

//                     const SizedBox(height: 24),
//                     const Text("Rincian Lengkap", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                     const SizedBox(height: 12),

//                     _buildExpandableSection(
//                       title: "Rincian Gaji (Pendapatan)",
//                       color: AppColors.primary,
//                       items: {
//                         "Gaji Pokok": val(d['gaji'], 'pokok'),
//                         "Tunj. Keluarga": val(d['gaji'], 'tunj_keluarga'),
//                         "Tunj. Jabatan": val(d['gaji'], 'tunj_jabatan'),
//                         "Tunj. Fungsional": val(d['gaji'], 'tunj_fungsional'),
//                         "Tunj. Fungsional Umum": val(d['gaji'], 'tunj_fungsional_umum'),
//                         "Tunj. Beras": val(d['gaji'], 'tunj_beras'),
//                         "Tunj. PPh": val(d['gaji'], 'tunj_pph'),
//                         "Pembulatan": val(d['gaji'], 'pembulatan'),
//                         "Tunj. BPJS Kes": val(d['gaji'], 'tunj_bpjs_kes'),
//                         "Tunj. JKK": val(d['gaji'], 'tunj_jkk'),
//                         "Tunj. JKM": val(d['gaji'], 'tunj_jkm'),
//                         "Tunj. Tapera": val(d['gaji'], 'tunj_tapera'),
//                         "Tunj. JHT": val(d['gaji'], 'tunj_jht'),
//                       },
//                     ),
//                     const SizedBox(height: 12),

//                     _buildExpandableSection(
//                       title: "Rincian TPP (Pendapatan)",
//                       color: AppColors.secondary,
//                       items: {
//                         "Beban Kerja": val(d['tpp'], 'beban_kerja'),
//                         "Prestasi Kerja": val(d['tpp'], 'prestasi_kerja'),
//                         "Kondisi Kerja": val(d['tpp'], 'kondisi_kerja'),
//                         "Kelangkaan Profesi": val(d['tpp'], 'kelangkaan_profesi'),
//                         "Tunj. BPJS (TPP)": val(d['tpp'], 'tunj_bpjs_kes'),
//                       },
//                     ),
//                     const SizedBox(height: 12),

//                     _buildExpandableSection(
//                       title: "Potongan Gaji (SIPD & Lainnya)",
//                       color: AppColors.danger,
//                       items: {
//                         "IWP (1% + 8%)": val(d['gaji'], 'potongan_iwp'),
//                         "PPh 21 Gaji": val(d['gaji'], 'potongan_pph21'),
//                         "BPJS Kes (Gaji)": val(d['gaji'], 'potongan_bpjs_kes'),
//                         "Jaminan Kecelakaan (JKK)": val(d['gaji'], 'potongan_jkk'),
//                         "Jaminan Kematian (JKM)": val(d['gaji'], 'potongan_jkm'),
//                         "Jaminan Hari Tua (JHT)": val(d['gaji'], 'potongan_jht'),
//                         "Tapera": val(d['gaji'], 'potongan_tapera'),
//                         "Bulog": val(d['gaji'], 'potongan_bulog'),
                        
//                         "Korpri": val(d['potongan_eksternal']['gaji'], 'korpri'),
//                         "Dharma Wanita": val(d['potongan_eksternal']['gaji'], 'dharma_wanita'),
//                         "Koperasi": val(d['potongan_eksternal']['gaji'], 'koperasi'),
//                         "Bank BJB": val(d['potongan_eksternal']['gaji'], 'bjb'),
//                         "Bank BJB Syariah": val(d['potongan_eksternal']['gaji'], 'bjb_syariah'),
//                         "Bank BRI": val(d['potongan_eksternal']['gaji'], 'bri'),
//                         "Bank Syariah Mandiri": val(d['potongan_eksternal']['gaji'], 'bsm'),
//                         "Zakat Fitrah": val(d['potongan_eksternal']['gaji'], 'zakat_fitrah'),
//                         "Zakat Mal": val(d['potongan_eksternal']['gaji'], 'zakat'),
//                       },
//                     ),
//                     const SizedBox(height: 12),

//                     _buildExpandableSection(
//                       title: "Potongan TPP (SIPD & Lainnya)",
//                       color: AppColors.warning,
//                       items: {
//                         "IWP (TPP)": val(d['tpp'], 'potongan_iwp'),
//                         "PPh 21 (TPP)": val(d['tpp'], 'potongan_pph21'),
//                         "BPJS Kes (TPP)": val(d['tpp'], 'potongan_bpjs_kes'),

//                         "Bank BJB (TPP)": val(d['potongan_eksternal']['tpp'], 'bjb'),
//                         "Gotong Royong": val(d['potongan_eksternal']['tpp'], 'gotroy'),
//                         "BPR Otista": val(d['potongan_eksternal']['tpp'], 'bpr_otista'),
//                         "BPR Pasar": val(d['potongan_eksternal']['tpp'], 'bpr_pasar'),
//                         "Bendahara": val(d['potongan_eksternal']['tpp'], 'bendahara'),
//                       },
//                     ),
//                     const SizedBox(height: 80),
//                   ],
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   // --- WIDGET HELPER DI BAWAH INI SAMA SEPERTI SEBELUMNYA ---

//   Widget _buildTransferRow(String label, int amount, Color color) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Row(
//           children: [
//             Icon(Icons.check_circle, size: 16, color: color),
//             const SizedBox(width: 8),
//             Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
//           ],
//         ),
//         Text(SalaryData.formatRupiah(amount), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//       ],
//     );
//   }

//   Widget _buildStatCard(String title, int value, Color color, IconData icon, {bool fullWidth = false}) {
//     return Container(
//       width: fullWidth ? double.infinity : null,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.grey.shade100),
//         boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 4, offset: const Offset(0, 2))],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(6),
//                 decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
//                 child: Icon(icon, color: color, size: 18),
//               ),
//               const SizedBox(width: 8),
//               Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w500)),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Text(SalaryData.formatRupiah(value), style: TextStyle(color: AppColors.dark, fontSize: 16, fontWeight: FontWeight.bold)),
//         ],
//       ),
//     );
//   }

//   Widget _buildExpandableSection({required String title, required Color color, required Map<String, int> items}) {
//     final itemList = items.entries.toList();

//     return Card(
//       elevation: 0,
//       color: Colors.white,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//         side: BorderSide(color: Colors.grey.shade200),
//       ),
//       child: ExpansionTile(
//         shape: const Border(),
//         leading: Container(
//           width: 4, height: 24, 
//           decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))
//         ),
//         title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
//         children: [
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//             child: Column(
//               children: itemList.map((e) => Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 6),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       e.key, 
//                       style: TextStyle(fontSize: 13, color: e.value > 0 ? Colors.grey.shade700 : Colors.grey.shade400)
//                     ),
//                     Text(
//                       SalaryData.formatRupiah(e.value), 
//                       style: TextStyle(
//                         fontSize: 13, 
//                         fontWeight: FontWeight.w500,
//                         color: e.value > 0 ? AppColors.dark : Colors.grey.shade400
//                       )
//                     ),
//                   ],
//                 ),
//               )).toList(),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }