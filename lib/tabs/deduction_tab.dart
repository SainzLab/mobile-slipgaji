import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class DeductionTab extends StatelessWidget {
  const DeductionTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Potongan Pihak Ketiga"),
        centerTitle: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.15),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.engineering_rounded,
                      size: 80,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 40),

                  const Text(
                    "Segera Hadir!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.dark,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    "Kami sedang menyiapkan fitur rincian potongan (Bank, Koperasi, Zakat, dll) agar data Anda lebih transparan dan akurat.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade500,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 40),

                  const SizedBox(height: 16),
                  
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import '../constants/app_colors.dart';
// import '../data/salary_data.dart';

// class DeductionTab extends StatefulWidget {
//   const DeductionTab({super.key});

//   @override
//   State<DeductionTab> createState() => _DeductionTabState();
// }

// class _DeductionTabState extends State<DeductionTab> {
//   int _selectedMonthId = 1;

//   Map<String, dynamic> get _currentData {
//     return SalaryData.salaryHistory.firstWhere(
//       (element) => element['id'] == _selectedMonthId,
//       orElse: () => SalaryData.salaryHistory.first,
//     );
//   }

//   void _showMonthPicker() {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return Container(
//           padding: const EdgeInsets.symmetric(vertical: 20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Text(
//                 "Pilih Periode",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.dark),
//               ),
//               const SizedBox(height: 16),
//               Expanded(
//                 child: ListView.builder(
//                   shrinkWrap: true,
//                   itemCount: SalaryData.salaryHistory.length,
//                   itemBuilder: (context, index) {
//                     final item = SalaryData.salaryHistory[index];
//                     final isSelected = item['id'] == _selectedMonthId;
                    
//                     return ListTile(
//                       title: Text(
//                         item['month'],
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                           color: isSelected ? AppColors.primary : Colors.black87,
//                         ),
//                       ),
//                       onTap: () {
//                         setState(() {
//                           _selectedMonthId = item['id'];
//                         });
//                         Navigator.pop(context);
//                       },
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final currentItem = _currentData;
//     final d = currentItem['potongan_eksternal'] as Map<String, dynamic>;
//     final gajiExt = d['gaji'] as Map<String, dynamic>;
//     final tppExt = d['tpp'] as Map<String, dynamic>;

//     int val(Map<String, dynamic> source, String key) => (source[key] ?? 0) as int;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Potongan Pihak Ketiga"), 
//         centerTitle: false, 
//         backgroundColor: AppColors.background,
//         surfaceTintColor: Colors.transparent,
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           InkWell(
//             onTap: _showMonthPicker,
//             borderRadius: BorderRadius.circular(12),
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 border: Border.all(color: Colors.grey.shade300), 
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: [
//                   BoxShadow(color: Colors.grey.shade100, blurRadius: 4, offset: const Offset(0, 2))
//                 ]
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "Periode",
//                         style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
//                       ),
//                       Text(
//                         currentItem['month'], 
//                         style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.dark),
//                       ),
//                     ],
//                   ),
//                   Container(
//                     padding: const EdgeInsets.all(4),
//                     decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
//                     child: const Icon(Icons.keyboard_arrow_down, size: 20, color: AppColors.primary),
//                   )
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 24),

//           _buildManualCard(
//             "Potongan Gaji", 
//             AppColors.danger, 
//             val(gajiExt, 'total'),
//             [
//               _ItemRow("Koperasi", val(gajiExt, 'koperasi')),
//               _ItemRow("Korpri", val(gajiExt, 'korpri')),
//               _ItemRow("Dharma Wanita", val(gajiExt, 'dharma_wanita')),
//               _ItemRow("Bank BJB", val(gajiExt, 'bjb')),
//               _ItemRow("Bank BJB Syariah", val(gajiExt, 'bjb_syariah')),
//               _ItemRow("Zakat Fitrah + Infak", val(gajiExt, 'zakat_fitrah')),
//               _ItemRow("Bank BRI", val(gajiExt, 'bri')),
//               _ItemRow("Zakat (Mal)", val(gajiExt, 'zakat')),
//               _ItemRow("Bank Syariah Mandiri (BSM)", val(gajiExt, 'bsm')),
//               _ItemRow("Zakat Profesi", 0),
//             ]
//           ),
          
//           const SizedBox(height: 16),
//           _buildManualCard(
//             "Potongan TPP", 
//             AppColors.warning, 
//             val(tppExt, 'total'),
//             [
//               _ItemRow("Bank BJB", val(tppExt, 'bjb')),
//               _ItemRow("Gotong Royong (Gotroy)", val(tppExt, 'gotroy')),
//               _ItemRow("BPR Otista", val(tppExt, 'bpr_otista')),
//               _ItemRow("BPR Pasar", val(tppExt, 'bpr_pasar')),
//               _ItemRow("Bendahara", val(tppExt, 'bendahara')),
//             ]
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildManualCard(String title, Color color, int total, List<_ItemRow> items) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.grey.shade200),
//         boxShadow: [
//           BoxShadow(color: Colors.grey.shade100, blurRadius: 8, offset: const Offset(0, 4))
//         ]
//       ),
//       child: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.05),
//               borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
//               border: Border(bottom: BorderSide(color: color.withOpacity(0.1))),
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(6),
//                   decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
//                   child: Icon(Icons.content_cut_rounded, color: color, size: 18),
//                 ),
//                 const SizedBox(width: 12),
//                 Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
//               ],
//             ),
//           ),
          
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               children: items.map((item) {
//                 return Padding(
//                   padding: const EdgeInsets.only(bottom: 12),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(item.label, style: TextStyle(fontSize: 13, color: item.value > 0 ? Colors.grey.shade700 : Colors.grey.shade400)),
//                       Text(
//                         SalaryData.formatRupiah(item.value), 
//                         style: TextStyle(
//                           fontWeight: FontWeight.w600, 
//                           fontSize: 13, 
//                           color: item.value > 0 ? AppColors.dark : Colors.grey.shade300
//                         )
//                       ),
//                     ],
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
          
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: const BoxDecoration(
//               border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text("Total Potongan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
//                 Text(SalaryData.formatRupiah(total), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }

// class _ItemRow {
//   final String label;
//   final int value;
//   _ItemRow(this.label, this.value);
// }