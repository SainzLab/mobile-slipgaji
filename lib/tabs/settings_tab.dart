import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_colors.dart';
import '../screens/login_page.dart';
import '../screens/change_password_page.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  String _nama = "-";
  String _nip = "-";
  String _inisial = "U";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nip = prefs.getString('nip') ?? "-";
      _nama = prefs.getString('nama_pegawai') ?? prefs.getString('nama') ?? "User Pegawai";
      _inisial = _getInitials(_nama);
    });
  }

  String _getInitials(String name) {
    if (name == "-" || name.isEmpty) return "U";
    List<String> words = name.trim().split(' ');
    if (words.length > 1) {
      return "${words[0][0]}${words[1][0]}".toUpperCase();
    } else if (words.isNotEmpty && words[0].isNotEmpty) {
      return words[0][0].toUpperCase();
    }
    return "U";
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); 

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false, 
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Akun Saya"), centerTitle: false, backgroundColor: AppColors.background),
      body: Column(
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primary,
            child: Text(_inisial, style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          Text(_nama, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          Text(_nip, style: const TextStyle(color: Colors.grey)),
          
          const SizedBox(height: 32),
          
          _buildMenuTile(context, "Ubah Password", Icons.lock_reset, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
            );
          }),
          
          _buildMenuTile(context, "Tentang Aplikasi", Icons.info_outline, () {
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Versi 1.0.0")));
          }),
          
          _buildMenuTile(context, "Keluar", Icons.logout, () {
             _logout();
          }, isDanger: true),
        ],
      ),
    );
  }

  Widget _buildMenuTile(BuildContext context, String title, IconData icon, VoidCallback onTap, {bool isDanger = false}) {
    return Container(
      color: Colors.white,
      child: ListTile(
        leading: Icon(icon, color: isDanger ? AppColors.danger : Colors.grey.shade700),
        title: Text(title, style: TextStyle(color: isDanger ? AppColors.danger : AppColors.dark, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}