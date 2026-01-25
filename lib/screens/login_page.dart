import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import 'main_screen.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _nipController = TextEditingController(text: "199703112020121004");
  final _passController = TextEditingController(text: "admin");
  bool _isLoading = false;
  bool _obscurePassword = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nipController.dispose();
    _passController.dispose();
    super.dispose();
  }

  void _login() async {
    setState(() => _isLoading = true);
    
    await Future.delayed(const Duration(seconds: 1)); 
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          
          Positioned(
            top: -50,
            left: -50,
            child: _buildCircleDecoration(150),
          ),
          Positioned(
            top: 50,
            right: -30,
            child: _buildCircleDecoration(100),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.2,
            left: 30,
            child: _buildCircleDecoration(50),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.35,
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.account_balance_wallet_rounded, size: 60, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "SiGaji Diskominfo",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Kelola Gaji & Tunjangan Anda",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.65,
                  padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 20,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Selamat Datang!",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.dark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Silakan login untuk melanjutkan",
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 32),

                        _buildTextField(
                          controller: _nipController,
                          label: "NIP",
                          icon: Icons.badge_outlined,
                          inputType: TextInputType.number,
                        ),
                        
                        const SizedBox(height: 20),

                        _buildTextField(
                          controller: _passController,
                          label: "Password",
                          icon: Icons.lock_outline,
                          isPassword: true,
                          isObscure: _obscurePassword,
                          onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
                              );
                            },
                            child: const Text("Lupa Password?", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                          ),
                        ),

                        const SizedBox(height: 32),

                        SizedBox(
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 5,
                              shadowColor: AppColors.primary.withOpacity(0.5),
                            ),
                            child: _isLoading 
                              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("Masuk Sekarang", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward_rounded, size: 20),
                                  ],
                                ),
                          ),
                        ),

                        const SizedBox(height: 40),
                        
                        const Center(
                          child: Text(
                            "v1.0.0",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleDecoration(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    bool isPassword = false,
    bool isObscure = false,
    VoidCallback? onToggleObscure,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? isObscure : false,
        keyboardType: inputType,
        style: const TextStyle(fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade600),
          prefixIcon: Icon(icon, color: AppColors.primary),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                  onPressed: onToggleObscure,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}