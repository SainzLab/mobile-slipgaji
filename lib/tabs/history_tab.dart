import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../data/salary_data.dart';
import '../screens/history_detail_sheet.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  
  List<Map<String, dynamic>> _allHistory = [];
  List<Map<String, dynamic>> _filteredHistory = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _allHistory = SalaryData.salaryHistory;
    _filteredHistory = _allHistory;
  }

  void _runFilter(String enteredKeyword) {
    List<Map<String, dynamic>> results = [];
    if (enteredKeyword.isEmpty) {
      results = _allHistory;
    } else {
      results = _allHistory
          .where((item) => item['month']
              .toString()
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    setState(() {
      _filteredHistory = results;
    });
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _searchController.clear();
      _filteredHistory = _allHistory; 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Riwayat Gaji"),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.dark,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _runFilter(value),
              decoration: InputDecoration(
                hintText: 'Cari bulan',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          _runFilter('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1),
                ),
              ),
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              color: AppColors.primary,
              backgroundColor: Colors.white,
              child: _filteredHistory.isNotEmpty
                  ? ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredHistory.length,
                      itemBuilder: (context, index) {
                        final item = _filteredHistory[index];
                        final month = item['month'] as String;
                        final thp = item['take_home_pay'] as int;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade100,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
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
                                    builder: (_, controller) =>
                                        HistoryDetailSheet(data: item),
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
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.calendar_month,
                                          color: AppColors.primary),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(month,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15)),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(Icons.check_circle,
                                                  size: 12,
                                                  color: AppColors.secondary),
                                              const SizedBox(width: 4),
                                              const Text("Ditransfer",
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(SalaryData.formatRupiah(thp),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: AppColors.dark)),
                                        const SizedBox(height: 4),
                                        const Text("Lihat Detail >",
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: AppColors.primary)),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off,
                                  size: 64, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text(
                                "Bulan tidak ditemukan",
                                style: TextStyle(color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}