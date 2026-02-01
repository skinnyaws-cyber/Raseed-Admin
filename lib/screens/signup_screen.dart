import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart'; // تأكد من وجود المكتبة في pubspec
import 'package:raseed_admin/screens/login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
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
            colors: [Color(0xFFF5F6FA), Color(0xFFDCDDE1)], // خلفية رمادية هادئة تبرز الزجاج
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                // === الشعار أو العنوان ===
                const Text(
                  "انضم للفريق",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2F3542),
                    fontFamily: 'IBMPlexSansArabic',
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "سجل بياناتك للبدء في إدارة الطلبات",
                  style: TextStyle(fontSize: 16, color: Colors.grey, fontFamily: 'IBMPlexSansArabic'),
                ),
                const SizedBox(height: 40),

                // === البطاقة الزجاجية (The Glass Card) ===
                GlassmorphicContainer(
                  width: double.infinity,
                  height: 450,
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
                        _buildGlassTextField(controller: _nameController, hint: "الاسم الكامل", icon: Icons.person_outline),
                        const SizedBox(height: 20),
                        _buildGlassTextField(controller: _emailController, hint: "البريد الإلكتروني", icon: Icons.email_outlined),
                        const SizedBox(height: 20),
                        _buildGlassTextField(controller: _passwordController, hint: "كلمة المرور", icon: Icons.lock_outline, isPassword: true),
                        
                        const Spacer(),

                        // === زر الفقاعة الأحمر ===
                        GestureDetector(
                          onTap: () {
                            // منطق التسجيل الحقيقي هنا
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
                                "تسجيل حساب جديد",
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

                // === رابط تسجيل الدخول ===
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("هل لديك حساب؟ ", style: TextStyle(color: Colors.grey, fontFamily: 'IBMPlexSansArabic')),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                      child: const Text(
                        "تسجيل الدخول",
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
