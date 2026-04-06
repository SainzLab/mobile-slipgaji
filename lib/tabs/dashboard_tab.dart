import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_colors.dart';
import '../services/api_service.dart';
import '../models/gaji_model.dart';
import '../models/tpp_model.dart';
import '../models/potongan_tpp_model.dart'; 
import '../models/potongan_gaji_model.dart'; 
import 'dart:math';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  bool _isLoading = true;
  String _errorMessage = "";
  
  List<Map<String, dynamic>> _dashboardDataList = [];
  int _selectedIndex = 0; 

  String _userName = "-";
  String _userNip = "-";

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _fetchDashboardData();
  }

  void _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('nama_pegawai') ?? "-";
      _userNip = prefs.getString('nip') ?? "-";
    });
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

  Future<void> _fetchDashboardData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    try {
      await initializeDateFormatting('id_ID', null);
      final api = ApiService();
      
      final results = await Future.wait([
        api.getGajiHistory(),
        api.getTppHistory(),
        api.getPotonganTppHistory(),
        api.getPotonganGajiHistory(),
      ]);

      final listGaji = results[0] as List<Gaji>;
      final listTpp = results[1] as List<Tpp>;
      final listPotonganTpp = results[2] as List<PotonganTpp>;
      final listPotonganGaji = results[3] as List<PotonganGaji>; 

      List<Map<String, dynamic>> tempData = [];
      
      int maxLength = [listGaji.length, listTpp.length, listPotonganTpp.length, listPotonganGaji.length].reduce(max);

      String currentMonthYear = DateFormat('MMMM yyyy', 'id_ID').format(DateTime.now());
      int defaultIndex = 0; 

      for (int i = 0; i < maxLength; i++) {
        final gaji = (i < listGaji.length) ? listGaji[i] : null;
        final tpp = (i < listTpp.length) ? listTpp[i] : null;
        final potGaji = (i < listPotonganGaji.length) ? listPotonganGaji[i] : null;
        final potTpp = (i < listPotonganTpp.length) ? listPotonganTpp[i] : null;

        String rawBulan = potGaji?.bulan ?? potTpp?.bulan ?? "-";
        String namaBulan = _getNamaBulanIndonesia(rawBulan); 
        String tahun = potGaji?.tahun ?? potTpp?.tahun ?? "";
        String monthName = "$namaBulan $tahun".trim();

        if (monthName == "-") {
          DateTime fallbackDate = DateTime(DateTime.now().year, DateTime.now().month - i, 1);
          monthName = DateFormat('MMMM yyyy', 'id_ID').format(fallbackDate);
        }

        tempData.add({
          'month': monthName,
          'gaji': gaji,
          'tpp': tpp,
          'potongan_gaji': potGaji,
          'potongan_tpp': potTpp,
        });

        if (monthName.toLowerCase() == currentMonthYear.toLowerCase()) {
          defaultIndex = i;
        }
      }

      if (mounted) {
        setState(() {
          _dashboardDataList = tempData;
          _selectedIndex = defaultIndex;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Terjadi kesalahan: $e";
        });
      }
    }
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
                  itemCount: _dashboardDataList.length,
                  itemBuilder: (context, index) {
                    final item = _dashboardDataList[index];
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

  String formatRupiah(num number) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(number);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _fetchDashboardData,
        color: AppColors.primary,
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
            ? ListView(children: [SizedBox(height: MediaQuery.of(context).size.height * 0.4), Center(child: Text(_errorMessage))])
            : _dashboardDataList.isEmpty
              ? ListView(children: [const SizedBox(height: 100), const Center(child: Text("Belum ada data gaji untuk periode ini."))])
              : _buildDashboardContent(),
      ),
    );
  }

  Widget _buildDashboardContent() {
    final currentData = _dashboardDataList[_selectedIndex];
    final String monthLabel = currentData['month'];
    final Gaji? gaji = currentData['gaji'];
    final Tpp? tpp = currentData['tpp'];
    final PotonganTpp? potonganTpp = currentData['potongan_tpp'];
    final PotonganGaji? potonganGaji = currentData['potongan_gaji'];

    final int gajiIncome = (gaji?.gajiPokok ?? 0) +
        (gaji?.tunjKeluarga ?? 0) +
        (gaji?.tunjJabatan ?? 0) +
        (gaji?.tunjFungsional ?? 0) +
        (gaji?.tunjFungsionalUmum ?? 0) +
        (gaji?.tunjBeras ?? 0) +
        (gaji?.tunjKhusus ?? 0) +
        (gaji?.tunjPajak ?? 0) +
        (gaji?.pembulatan ?? 0) +
        (gaji?.iuranBpjs ?? 0) +
        (gaji?.iuranJkk ?? 0) +
        (gaji?.iuranJkm ?? 0);
        
    final int potGajiAwal = (gaji?.potonganIwp ?? 0) +
        (gaji?.potonganPph ?? 0) +
        (gaji?.iuranBpjs ?? 0) +
        (gaji?.tunjJht ?? 0) +
        (gaji?.iuranJkk ?? 0) +
        (gaji?.iuranJkm ?? 0) +
        (gaji?.iuranSimpanan ?? 0) +
        (gaji?.iuranPensiun ?? 0) +
        (gaji?.zakat ?? 0) +
        (gaji?.bulog ?? 0);

    final int potGajiPihak3 = (potonganGaji?.koperasi ?? 0) +
        (potonganGaji?.korpri ?? 0) +
        (potonganGaji?.dharmaWanita ?? 0) +
        (potonganGaji?.bjb ?? 0) +
        (potonganGaji?.bjbs ?? 0) +
        (potonganGaji?.zakatFitrahInfak ?? 0) +
        (potonganGaji?.zakatProfesi ?? 0);
        
    final int totalPotGaji = potGajiAwal + potGajiPihak3;
    final int thpGaji = gajiIncome - totalPotGaji;

    final int tppIncome = (tpp?.bebanKerja ?? 0) +
        (tpp?.prestasiKerja ?? 0) +
        (tpp?.kondisiKerja ?? 0) +
        (tpp?.kelangkaanProfesi ?? 0) +
        (tpp?.tempatBertugas ?? 0) +
        (tpp?.tunjanganJabatan ?? 0);

    final int potTppAwal = (tpp?.potonganPph ?? 0) +
        (tpp?.potonganIwp ?? 0) +
        (tpp?.iuranBpjs ?? 0) + 
        (tpp?.iuranSimpanan ?? 0) +
        (tpp?.iuranPensiun ?? 0) +
        (tpp?.zakat ?? 0) +
        (tpp?.bulog ?? 0);

    final int potTppPihak3 = (potonganTpp?.bjb ?? 0) +
        (potonganTpp?.gotroy ?? 0) +
        (potonganTpp?.bprOtista ?? 0) +
        (potonganTpp?.bprPasar ?? 0) +
        (potonganTpp?.bendahara ?? 0);
        
    final int totalPotTpp = potTppAwal + potTppPihak3;
    final int thpTpp = tppIncome - totalPotTpp;

    final int totalThp = thpGaji + thpTpp;
    final int totalPotongan = totalPotGaji + totalPotTpp;

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
                
                InkWell(
                  onTap: _showMonthPicker,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              "Periode: $monthLabel", 
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.dark, fontSize: 13)
                            ),
                          ],
                        ),
                        const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

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
                    Expanded(child: _buildStatCard("Gaji Kotor", gajiIncome, AppColors.primary, Icons.monetization_on)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatCard("TPP Kotor", tppIncome, AppColors.secondary, Icons.trending_up)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildStatCard("Total Potongan", totalPotongan, AppColors.danger, Icons.pie_chart, fullWidth: true),

                const SizedBox(height: 24),
                const Text("Rincian Lengkap", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                if (gaji != null) 
                _buildExpandableSection(
                  title: "Rincian Gaji",
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
                  },
                ),
                const SizedBox(height: 12),

                if (tpp != null)
                _buildExpandableSection(
                  title: "Rincian TPP",
                  color: AppColors.secondary,
                  items: {
                    "Beban Kerja": tpp.bebanKerja,
                    "Prestasi Kerja": tpp.prestasiKerja,
                    "Kondisi Kerja": tpp.kondisiKerja,
                    "Kelangkaan Profesi": tpp.kelangkaanProfesi,
                    "Tempat Bertugas": tpp.tempatBertugas,
                    "Tunj. Jabatan (TPP)": tpp.tunjanganJabatan,
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
                    "Tunj. JHT": gaji.tunjJht,
                    "Tunj. JKK": gaji.iuranJkk,
                    "Tunj. JKM": gaji.iuranJkm,
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
                const SizedBox(height: 12),

                if (potonganGaji != null)
                _buildExpandableSection(
                  title: "Pot. Pihak ke-3 Gaji",
                  color: Colors.redAccent.shade400,
                  items: {
                    "Koperasi": potonganGaji.koperasi,
                    "KORPRI": potonganGaji.korpri,
                    "Dharma Wanita": potonganGaji.dharmaWanita,
                    "BJB": potonganGaji.bjb,
                    "BJB Syariah": potonganGaji.bjbs,
                    "Zakat Fitrah/Infak": potonganGaji.zakatFitrahInfak,
                    "Zakat Profesi": potonganGaji.zakatProfesi,
                  },
                ),
                const SizedBox(height: 12),

                if (potonganTpp != null)
                _buildExpandableSection(
                  title: "Pot. Pihak ke-3 TPP",
                  color: Colors.purple.shade400,
                  items: {
                    "Bank BJB": potonganTpp.bjb,
                    "Gotroy": potonganTpp.gotroy,
                    "BPR Otista": potonganTpp.bprOtista,
                    "BPR Pasar": potonganTpp.bprPasar,
                    "Potongan Bendahara": potonganTpp.bendahara,
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
    
    final int totalAmount = items.values.fold(0, (sum, item) => sum + item);

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
              children: [
                ...itemList.map((e) => Padding(
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
                )),
                
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Divider(height: 1, color: Colors.grey.shade200),
                ),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total", 
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.dark)
                    ),
                    Text(
                      formatRupiah(totalAmount), 
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}