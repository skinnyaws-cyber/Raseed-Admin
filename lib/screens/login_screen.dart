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

  // منطق تسجيل الدخول الأصلي [cite: 207-213]
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

  void _showMsg(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg, style: const TextStyle(fontFamily: 'IBMPlexSansArabic'))),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF5F6FA), Color(0xFFDCDDE1)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                // الشعار أو الأيقونة العلوية 
                const Icon(Icons.admin_panel_settings_rounded, size: 80, color: Color(0xFFFF4757)),
                const SizedBox(height: 20),
                const Text(
                  "أهلاً بعودتك أيها المدير",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2F3542),
                    fontFamily: 'IBMPlexSansArabic',
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "قم بتسجيل الدخول لإدارة عمليات رصيد",
                  style: TextStyle(fontSize: 14, color: Colors.grey, fontFamily: 'IBMPlexSansArabic'),
                ),
                const SizedBox(height: 40),

                // بطاقة تسجيل الدخول الزجاجية المطورة [cite: 216-221]
                GlassmorphicContainer(
                  width: double.infinity,
                  height: 380,
                  borderRadius: 30,
                  blur: 20,
                  alignment: Alignment.center,
                  border: 2,
                  linearGradient: LinearGradient(
                    colors: [Colors.white.withOpacity(0.8), Colors.white.withOpacity(0.4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderGradient: LinearGradient(
                    colors: [Colors.white.withOpacity(0.5), Colors.white.withOpacity(0.1)],
                  ),
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
                            width: double.infinity,
                            height: 55,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF4757),
                              borderRadius: BorderRadius.circular(50),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF4757).withOpacity(0.4),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Center(
                              child: _isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text(
                                      "تسجيل الدخول",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'IBMPlexSansArabic',
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // رابط الانتقال لإنشاء حساب [cite: 221]
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "ليس لديك حساب؟ ",
                      style: TextStyle(color: Colors.grey, fontFamily: 'IBMPlexSansArabic'),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const SignUpScreen()),
                        );
                      },
                      child: const Text(
                        "أنشئ حساباً",
                        style: TextStyle(
                          color: Color(0xFFFF4757),
                          fontWeight: FontWeight.bold,
                          fontFamily: 'IBMPlexSansArabic',
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
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
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPass,
        style: const TextStyle(fontFamily: 'IBMPlexSansArabic'),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFFFF4757)),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black45, fontFamily: 'IBMPlexSansArabic'),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }
}
