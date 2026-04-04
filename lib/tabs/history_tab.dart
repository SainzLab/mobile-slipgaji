import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; 
import '../constants/app_colors.dart';
import '../screens/history_detail_sheet.dart';
import '../services/api_service.dart';
import '../models/gaji_model.dart';
import '../models/tpp_model.dart';
import '../models/potongan_tpp_model.dart';
import '../models/potongan_gaji_model.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  List<Map<String, dynamic>> _allHistory = [];
  List<Map<String, dynamic>> _filteredHistory = [];
  bool _isLoading = true;
  String _errorMessage = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchHistoryData();
  }

  String _getNamaBulanIndonesia(String monthCode) {
    const months = {
      '1': 'Januari', '01': 'Januari',
      '2': 'Februari', '02': 'Februari',
      '3': 'Maret', '03': 'Maret',
      '4': 'April', '04': 'April',
      '5': 'Mei', '05': 'Mei',
      '6': 'Juni', '06': 'Juni',
      '7': 'Juli', '07': 'Juli',
      '8': 'Agustus', '08': 'Agustus',
      '9': 'September', '09': 'September',
      '10': 'Oktober',
      '11': 'November',
      '12': 'Desember'
    };
    return months[monthCode.toString().trim()] ?? monthCode;
  }

  Future<void> _fetchHistoryData() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    final api = ApiService();

    try {
      await initializeDateFormatting('id_ID', null);

      final results = await Future.wait([
        api.getGajiHistory(),
        api.getTppHistory(),
        api.getPotonganGajiHistory(), 
        api.getPotonganTppHistory(), 
      ]);

      final listGaji = results[0] as List<Gaji>;
      final listTpp = results[1] as List<Tpp>;
      final listPotGaji = results[2] as List<PotonganGaji>; 
      final listPotTpp = results[3] as List<PotonganTpp>;   

      List<Map<String, dynamic>> tempHistory = [];

      for (int i = 0; i < listGaji.length; i++) {
        final gaji = listGaji[i];
        final tpp = (i < listTpp.length) ? listTpp[i] : null;
        final potGaji = (i < listPotGaji.length) ? listPotGaji[i] : null; 
        final potTpp = (i < listPotTpp.length) ? listPotTpp[i] : null;   

        final int thpGaji = potGaji != null ? potGaji.jumlahYgDiterima : gaji.jumlahDiterima;
        final int thpTpp = potTpp != null ? potTpp.sisaTpp : (tpp?.jumlahDiterima ?? 0);
        final int totalThp = thpGaji + thpTpp;

        String rawBulan = potGaji?.bulan ?? potTpp?.bulan ?? "-";
        String namaBulan = _getNamaBulanIndonesia(rawBulan); 
        
        String tahun = potGaji?.tahun ?? potTpp?.tahun ?? "";
        String monthName = "$namaBulan $tahun".trim();

        if (monthName == "-") {
          DateTime fallbackDate = DateTime(DateTime.now().year, DateTime.now().month - i, 1);
          monthName = DateFormat('MMMM yyyy', 'id_ID').format(fallbackDate);
        }

        tempHistory.add({
          'month': monthName, 
          'total': totalThp,
          'status': 'Ditransfer',
          'gaji_data': gaji,
          'tpp_data': tpp,
          'pot_gaji_data': potGaji, 
          'pot_tpp_data': potTpp,   
        });
      }

      if (mounted) {
        setState(() {
          _allHistory = tempHistory;
          _filteredHistory = tempHistory;
          _isLoading = false;
        });
      }

    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Gagal memuat data: $e";
        });
      }
    }
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
    _searchController.clear();
    await _fetchHistoryData();
  }

  String formatRupiah(num number) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(number);
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
        surfaceTintColor: Colors.transparent,
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
                hintText: 'Cari bulan (misal: Januari)',
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1)),
              ),
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              color: AppColors.primary,
              backgroundColor: Colors.white,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage.isNotEmpty
                      ? Center(child: Text(_errorMessage))
                      : _filteredHistory.isNotEmpty
                          ? ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredHistory.length,
                              itemBuilder: (context, index) {
                                final item = _filteredHistory[index];
                                final month = item['month'] as String;
                                final thp = item['total'] as int;
                                final status = item['status'] as String;

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.grey.shade200),
                                    boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 4, offset: const Offset(0, 2))],
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
                                          builder: (context) => HistoryDetailSheet(
                                            month: month,
                                            gaji: item['gaji_data'],
                                            tpp: item['tpp_data'],
                                            potonganGaji: item['pot_gaji_data'], 
                                            potonganTpp: item['pot_tpp_data'],
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
                                                      const Icon(Icons.check_circle, size: 12, color: Colors.green),
                                                      const SizedBox(width: 4),
                                                      Text(status, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Text(formatRupiah(thp), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.dark)),
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
                            )
                          : ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
                                      const SizedBox(height: 16),
                                      Text("Bulan tidak ditemukan", style: TextStyle(color: Colors.grey.shade500)),
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