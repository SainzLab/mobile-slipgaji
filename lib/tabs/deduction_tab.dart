import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../services/api_service.dart';
import '../models/potongan_gaji_model.dart';
import '../models/potongan_tpp_model.dart';

class DeductionTab extends StatefulWidget {
  const DeductionTab({super.key});

  @override
  State<DeductionTab> createState() => _DeductionTabState();
}

class _DeductionTabState extends State<DeductionTab> {
  bool _isLoading = true;
  String _errorMessage = "";
  
  List<Map<String, dynamic>> _deductionsList = [];
  
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchDeductionsData();
  }

  Future<void> _fetchDeductionsData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    final api = ApiService();

    try {
      final results = await Future.wait([
        api.getPotonganGajiHistory(),
        api.getPotonganTppHistory(),
      ]);

      final listPotGaji = results[0] as List<PotonganGaji>;
      final listPotTpp = results[1] as List<PotonganTpp>;

      List<Map<String, dynamic>> tempData = [];

      int maxLength = listPotGaji.length > listPotTpp.length ? listPotGaji.length : listPotTpp.length;

      for (int i = 0; i < maxLength; i++) {
        final potGaji = (i < listPotGaji.length) ? listPotGaji[i] : null;
        final potTpp = (i < listPotTpp.length) ? listPotTpp[i] : null;

        String namaBulan = potGaji?.bulan ?? potTpp?.bulan ?? "-";
        String tahun = potGaji?.tahun ?? potTpp?.tahun ?? "";
        String monthName = "$namaBulan $tahun".trim();

        tempData.add({
          'month': monthName,
          'potongan_gaji': potGaji,
          'potongan_tpp': potTpp,
        });
      }

      if (mounted) {
        setState(() {
          _deductionsList = tempData;
          _selectedIndex = 0; 
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

  String formatRupiah(num number) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(number);
  }

  void _showMonthPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Pilih Periode",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.dark),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _deductionsList.length,
                  itemBuilder: (context, index) {
                    final item = _deductionsList[index];
                    final isSelected = index == _selectedIndex;
                    
                    return ListTile(
                      title: Text(
                        item['month'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? AppColors.primary : Colors.black87,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Potongan Pihak Ketiga"), 
        centerTitle: false, 
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _errorMessage.isNotEmpty
          ? Center(child: Text(_errorMessage))
          : _deductionsList.isEmpty
            ? const Center(child: Text("Tidak ada data potongan."))
            : _buildContent(),
    );
  }

  Widget _buildContent() {
    final currentData = _deductionsList[_selectedIndex];
    final monthLabel = currentData['month'] as String;
    final potGaji = currentData['potongan_gaji'] as PotonganGaji?;
    final potTpp = currentData['potongan_tpp'] as PotonganTpp?;

    return RefreshIndicator(
      onRefresh: _fetchDeductionsData,
      color: AppColors.primary,
      backgroundColor: Colors.white,
      child: ListView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          
          InkWell(
            onTap: _showMonthPicker,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300), 
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.grey.shade100, blurRadius: 4, offset: const Offset(0, 2))
                ]
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Periode",
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        monthLabel, 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.dark),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.keyboard_arrow_down, size: 20, color: AppColors.primary),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          _buildManualCard(
            "Potongan Gaji", 
            AppColors.danger, 
            potGaji?.jumlahPotongan ?? 0,
            [
              _ItemRow("Koperasi", potGaji?.koperasi ?? 0),
              _ItemRow("Korpri", potGaji?.korpri ?? 0),
              _ItemRow("Dharma Wanita", potGaji?.dharmaWanita ?? 0),
              _ItemRow("Bank BJB", potGaji?.bjb ?? 0),
              _ItemRow("Bank BJB Syariah", potGaji?.bjbs ?? 0),
              _ItemRow("Zakat Fitrah / Infak", potGaji?.zakatFitrahInfak ?? 0),
              _ItemRow("Zakat Profesi", potGaji?.zakatProfesi ?? 0),
            ]
          ),
          
          const SizedBox(height: 16),
          
          _buildManualCard(
            "Potongan TPP", 
            AppColors.warning, 
            potTpp?.jumlahPotongan ?? 0,
            [
              _ItemRow("Bank BJB", potTpp?.bjb ?? 0),
              _ItemRow("Gotong Royong (Gotroy)", potTpp?.gotroy ?? 0),
              _ItemRow("BPR Otista", potTpp?.bprOtista ?? 0),
              _ItemRow("BPR Pasar", potTpp?.bprPasar ?? 0),
              _ItemRow("Bendahara", potTpp?.bendahara ?? 0),
            ]
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildManualCard(String title, Color color, int total, List<_ItemRow> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade100, blurRadius: 8, offset: const Offset(0, 4))
        ]
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(bottom: BorderSide(color: color.withOpacity(0.1))),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                  child: Icon(Icons.content_cut_rounded, color: color, size: 18),
                ),
                const SizedBox(width: 12),
                Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: items.map((item) {
                if (item.value == 0) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item.label, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                      Text(
                        formatRupiah(item.value), 
                        style: const TextStyle(
                          fontWeight: FontWeight.w600, 
                          fontSize: 13, 
                          color: AppColors.dark
                        )
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Potongan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(formatRupiah(total), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _ItemRow {
  final String label;
  final int value;
  _ItemRow(this.label, this.value);
}