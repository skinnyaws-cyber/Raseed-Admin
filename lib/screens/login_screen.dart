import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:raseed_admin/screens/signup_screen.dart';
import 'package:raseed_admin/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showMsg("يرجى إدخال البيانات");
      return;
    }
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      _showMsg("خطأ في البريد أو كلمة المرور");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMsg(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFF5F6FA), Color(0xFFDCDDE1)])),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Text("أهلاً بعودتك", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'IBMPlexSansArabic')),
                const SizedBox(height: 40),
                GlassmorphicContainer(
                  width: double.infinity, height: 380, borderRadius: 30, blur: 20, alignment: Alignment.center, border: 2,
                  linearGradient: LinearGradient(colors: [Colors.white.withOpacity(0.8), Colors.white.withOpacity(0.4)]),
                  borderGradient: LinearGradient(colors: [Colors.white.withOpacity(0.5), Colors.white.withOpacity(0.1)]),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        _buildField(_emailController, "البريد الإلكتروني", Icons.email_outlined),
                        const SizedBox(height: 20),
                        _buildField(_passwordController, "كلمة المرور", Icons.lock_outline, isPass: true),
                        const Spacer(),
                        GestureDetector(
                          onTap: _isLoading ? null : _handleLogin,
                          child: Container(
                            width: double.infinity, height: 55,
                            decoration: BoxDecoration(color: const Color(0xFFFF4757), borderRadius: BorderRadius.circular(50)),
                            child: Center(child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("دخول", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String hint, IconData icon, {bool isPass = false}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(15)),
      child: TextField(
        controller: controller, obscureText: isPass,
        decoration: InputDecoration(prefixIcon: Icon(icon, color: const Color(0xFFFF4757)), hintText: hint, border: InputBorder.none, contentPadding: const EdgeInsets.all(15)),
      ),
    );
  }
}