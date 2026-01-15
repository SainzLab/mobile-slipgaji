import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../data/salary_data.dart';
import '../screens/history_detail_sheet.dart';

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final history = SalaryData.salaryHistory; 

    return Scaffold(
      appBar: AppBar(title: const Text("Riwayat Gaji"), centerTitle: false, backgroundColor: AppColors.background),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: history.length,
        itemBuilder: (context, index) {
          final item = history[index];
          final month = item['month'] as String;
          final thp = item['take_home_pay'] as int;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(color: Colors.grey.shade100, blurRadius: 4, offset: const Offset(0, 2))
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true, 
                    backgroundColor: Colors.transparent,
                    builder: (context) => DraggableScrollableSheet(
                      initialChildSize: 0.85,
                      minChildSize: 0.5,
                      maxChildSize: 0.95,
                      builder: (_, controller) => HistoryDetailSheet(data: item),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1), 
                          borderRadius: BorderRadius.circular(12)
                        ),
                        child: const Icon(Icons.calendar_month, color: AppColors.primary),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(month, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.check_circle, size: 12, color: AppColors.secondary),
                                const SizedBox(width: 4),
                                const Text("Ditransfer", style: TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(SalaryData.formatRupiah(thp), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.dark)),
                          const SizedBox(height: 4),
                          const Text("Lihat Detail >", style: TextStyle(fontSize: 11, color: AppColors.primary)),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}