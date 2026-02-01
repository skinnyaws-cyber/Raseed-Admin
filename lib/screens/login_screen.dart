import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:raseed_admin/screens/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

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
                const Text(
                  "أهلاً بعودتك",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2F3542),
                    fontFamily: 'IBMPlexSansArabic',
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "سجل دخولك لمتابعة العمل",
                  style: TextStyle(fontSize: 16, color: Colors.grey, fontFamily: 'IBMPlexSansArabic'),
                ),
                const SizedBox(height: 40),

                GlassmorphicContainer(
                  width: double.infinity,
                  height: 380, // أقصر قليلاً من التسجيل
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildGlassTextField(controller: _emailController, hint: "البريد الإلكتروني", icon: Icons.email_outlined),
                        const SizedBox(height: 20),
                        _buildGlassTextField(controller: _passwordController, hint: "كلمة المرور", icon: Icons.lock_outline, isPassword: true),
                        
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text("نسيت كلمة المرور؟", style: TextStyle(color: Colors.grey, fontSize: 12, fontFamily: 'IBMPlexSansArabic')),
                          ),
                        ),

                        const Spacer(),

                        GestureDetector(
                          onTap: () {
                            // منطق الدخول الحقيقي
                          },
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
                            child: const Center(
                              child: Text(
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

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("مدير جديد؟ ", style: TextStyle(color: Colors.grey, fontFamily: 'IBMPlexSansArabic')),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SignUpScreen())),
                      child: const Text(
                        "إنشاء حساب",
                        style: TextStyle(
                          color: Color(0xFFFF4757),
                          fontWeight: FontWeight.bold,
                          fontFamily: 'IBMPlexSansArabic',
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

  Widget _buildGlassTextField({required TextEditingController controller, required String hint, required IconData icon, bool isPassword = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
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
