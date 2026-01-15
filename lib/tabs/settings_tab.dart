import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../data/salary_data.dart';
import '../screens/login_page.dart';
import '../screens/change_password_page.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Akun Saya"), centerTitle: false, backgroundColor: AppColors.background),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primary,
            child: Text("FM", style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          Text(SalaryData.data['pegawai']['nama'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          Text(SalaryData.data['pegawai']['nip'], style: const TextStyle(color: Colors.grey)),
          
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
             Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
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