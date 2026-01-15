import 'package:flutter/material.dart';
import 'constants/app_colors.dart';
import 'screens/login_page.dart';

void main() {
  runApp(const MySalaryApp());
}

class MySalaryApp extends StatelessWidget {
  const MySalaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Salary',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: const LoginPage(),
    );
  }
}