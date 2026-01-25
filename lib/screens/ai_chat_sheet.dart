import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../constants/app_colors.dart';
import '../data/salary_data.dart';

class AiChatSheet extends StatefulWidget {
  const AiChatSheet({super.key});

  @override
  State<AiChatSheet> createState() => _AiChatSheetState();
}

class _AiChatSheetState extends State<AiChatSheet> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  static const String _apiKey = 'AIzaSyDEFV40q0XZFdhBimPFtZXspsAz_5xcRW8'; 

  late final GenerativeModel _model;
  late final ChatSession _chatSession;

  @override
  void initState() {
    super.initState();
    _initGemini();
  }

  void _initGemini() {
    final String salaryContext = _buildSalaryContext();

    _model = GenerativeModel(
      model: 'gemini-2.5-flash', 
      apiKey: _apiKey,
      systemInstruction: Content.system("""
        Kamu adalah Asisten Cerdas untuk aplikasi 'SiGaji'.
        
        PERANMU:
        1. Jawab pertanyaan seputar gaji berdasarkan DATA DI BAWAH.
        2. Jika user bertanya hal umum (tips, cuaca, curhat), jawablah dengan luwes menggunakan pengetahuan luasmu.
        
        DATA GAJI USER:
        $salaryContext
        
        GAYA BICARA:
        - Gunakan formatting Markdown seperti Bold (**) untuk angka penting.
        - Gunakan Bullet points (-) untuk rincian agar mudah dibaca di HP.
        - Ramah, solutif, dan menggunakan Emoji sesekali.
      """),
    );

    _chatSession = _model.startChat();
    
    _addMessage("Halo! 👋 Saya Asisten SiGaji.\nAda yang bisa saya bantu?", false);
  }

  String _buildSalaryContext() {
    final d = SalaryData.data; 
    final history = SalaryData.salaryHistory; 
    String fmt(dynamic val) => SalaryData.formatRupiah(val ?? 0);

    final recentHistory = history.length >= 2 ? history.take(2).toList() : history;
    String historyText = "";
    for (var item in recentHistory) {
      historyText += "- Bulan ${item['month']}: ${fmt(item['take_home_pay'])}\n";
    }

    return """
    === DATA PEGAWAI ===
    Nama: ${d['pegawai']['nama']}
    NIP: ${d['pegawai']['nip']}
    Jabatan: ${d['pegawai']['jabatan']}
    Unit Kerja: ${d['pegawai']['unit']}
    Periode Data: ${d['periode']}

    === 1. RINCIAN GAJI (GAJI INDUK) ===
    A. PENDAPATAN GAJI:
    - Gaji Pokok: ${fmt(d['gaji']['pokok'])}
    - Tunjangan Keluarga: ${fmt(d['gaji']['tunj_keluarga'])}
    - Tunjangan Jabatan: ${fmt(d['gaji']['tunj_jabatan'])}
    - Tunjangan Fungsional: ${fmt(d['gaji']['tunj_fungsional'])}
    - Tunjangan Fungsional Umum: ${fmt(d['gaji']['tunj_fungsional_umum'])}
    - Tunjangan Beras: ${fmt(d['gaji']['tunj_beras'])}
    - Tunjangan PPh: ${fmt(d['gaji']['tunj_pph'])}
    - Pembulatan: ${fmt(d['gaji']['pembulatan'])}
    - Tunjangan BPJS Kesehatan: ${fmt(d['gaji']['tunj_bpjs_kes'])}
    - Tunjangan JKK (Kecelakaan Kerja): ${fmt(d['gaji']['tunj_jkk'])}
    - Tunjangan JKM (Kematian): ${fmt(d['gaji']['tunj_jkm'])}
    - Tunjangan JHT/Tapera: ${fmt(d['gaji']['tunj_jht'])}
    -> TOTAL GAJI KOTOR: ${fmt(d['gaji']['jumlah_kotor'])}

    B. POTONGAN GAJI (SIPD & MANUAL):
    - Potongan IWP (1% + 8%): ${fmt(d['gaji']['potongan_iwp'])}
    - Potongan PPh 21: ${fmt(d['gaji']['potongan_pph21'])}
    - Potongan BPJS Kesehatan: ${fmt(d['gaji']['potongan_bpjs_kes'])}
    - Potongan JKK: ${fmt(d['gaji']['potongan_jkk'])}
    - Potongan JKM: ${fmt(d['gaji']['potongan_jkm'])}
    - Potongan JHT: ${fmt(d['gaji']['potongan_jht'])}
    - Potongan Tapera: ${fmt(d['gaji']['potongan_tapera'])}
    - Potongan Bulog: ${fmt(d['gaji']['potongan_bulog'])}
    - Iuran Korpri: ${fmt(d['potongan_eksternal']['gaji']['korpri'])}
    - Iuran Dharma Wanita: ${fmt(d['potongan_eksternal']['gaji']['dharma_wanita'])}
    - Koperasi: ${fmt(d['potongan_eksternal']['gaji']['koperasi'])}
    - Bank BJB (Gaji): ${fmt(d['potongan_eksternal']['gaji']['bjb'])}
    - Bank BJB Syariah: ${fmt(d['potongan_eksternal']['gaji']['bjb_syariah'])}
    - Bank BRI: ${fmt(d['potongan_eksternal']['gaji']['bri'])}
    - Bank Syariah Mandiri: ${fmt(d['potongan_eksternal']['gaji']['bsm'])}
    - Zakat Fitrah: ${fmt(d['potongan_eksternal']['gaji']['zakat_fitrah'])}
    - Zakat Mal: ${fmt(d['potongan_eksternal']['gaji']['zakat'])}

    === 2. RINCIAN TPP (TAMBAHAN PENGHASILAN) ===
    A. PENDAPATAN TPP:
    - Beban Kerja: ${fmt(d['tpp']['beban_kerja'])}
    - Kondisi Kerja: ${fmt(d['tpp']['kondisi_kerja'])}
    - Prestasi Kerja: ${fmt(d['tpp']['prestasi_kerja'])}
    - Kelangkaan Profesi: ${fmt(d['tpp']['kelangkaan_profesi'])}
    - Tunjangan BPJS (di TPP): ${fmt(d['tpp']['tunj_bpjs_kes'])}
    -> TOTAL TPP KOTOR: ${fmt(d['tpp']['jumlah_kotor'])}

    B. POTONGAN TPP:
    - Potongan IWP TPP: ${fmt(d['tpp']['potongan_iwp'])}
    - Potongan PPh 21 TPP: ${fmt(d['tpp']['potongan_pph21'])}
    - Potongan BPJS TPP: ${fmt(d['tpp']['potongan_bpjs_kes'])}
    - Bank BJB (TPP): ${fmt(d['potongan_eksternal']['tpp']['bjb'])}
    - Gotong Royong: ${fmt(d['potongan_eksternal']['tpp']['gotroy'])}
    - BPR Otista: ${fmt(d['potongan_eksternal']['tpp']['bpr_otista'])}
    - BPR Pasar: ${fmt(d['potongan_eksternal']['tpp']['bpr_pasar'])}
    - Bendahara: ${fmt(d['potongan_eksternal']['tpp']['bendahara'])}

    === 3. RINGKASAN TERIMA BERSIH (THP) ===
    - Transfer Gaji Bersih: ${fmt(d['summary']['thp_gaji'])}
    - Transfer TPP Bersih: ${fmt(d['summary']['thp_tpp'])}
    - TOTAL DITERIMA (NET): ${fmt(d['summary']['thp_total'])}

    === 4. RIWAYAT 2 BULAN TERAKHIR ===
    $historyText
    """;
  }

  void _addMessage(String text, bool isUser) {
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: isUser));
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    _addMessage(text, true);
    setState(() => _isLoading = true);

    try {
      final response = await _chatSession.sendMessage(Content.text(text));
      _addMessage(response.text ?? "Maaf, saya tidak mengerti.", false);
    } catch (e) {
      print("Error Gemini: $e");
      _addMessage("Koneksi bermasalah. Coba periksa internet Anda.", false);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.smart_toy_rounded, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Asisten SiGaji", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text("Powered by Gemini AI", style: TextStyle(color: Colors.grey, fontSize: 10)),
                  ],
                ),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg.isUser;

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                    decoration: BoxDecoration(
                      color: isUser ? AppColors.primary : Colors.grey.shade100,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isUser ? 16 : 0),
                        bottomRight: Radius.circular(isUser ? 0 : 16),
                      ),
                    ),
                    
                    child: MarkdownBody(
                      data: msg.text,
                      selectable: true,
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(color: isUser ? Colors.white : AppColors.dark, fontSize: 14),
                        strong: TextStyle(color: isUser ? Colors.white : AppColors.dark, fontWeight: FontWeight.bold),
                        listBullet: TextStyle(color: isUser ? Colors.white : AppColors.dark),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(left: 16, bottom: 8),
              child: Align(alignment: Alignment.centerLeft, child: Text("Sedang mengetik...", style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic))),
            ),

          Container(
            padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Tanya sesuatu...",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton.small(
                  onPressed: _isLoading ? null : _sendMessage,
                  backgroundColor: AppColors.primary,
                  child: _isLoading 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                    : const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}