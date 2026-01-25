import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../constants/app_colors.dart';
import '../tabs/dashboard_tab.dart';
import '../tabs/history_tab.dart';
import '../tabs/deduction_tab.dart';
import '../tabs/settings_tab.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardTab(),
    const HistoryTab(),
    const DeductionTab(),
    const SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: IndexedStack(index: _selectedIndex, children: _pages),
      
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(0.1),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              gap: 8, 
              activeColor: Colors.white, 
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: const Duration(milliseconds: 400), 
              tabBackgroundColor: AppColors.primary, 
              color: Colors.grey[600],
              
              tabs: const [
                GButton(
                  icon: Icons.dashboard_rounded,
                  text: 'Home',
                ),
                GButton(
                  icon: Icons.history_rounded,
                  text: 'Riwayat',
                ),
                GButton(
                  icon: Icons.content_cut_rounded,
                  text: 'Potongan',
                ),
                GButton(
                  icon: Icons.person_rounded,
                  text: 'Akun',
                ),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}