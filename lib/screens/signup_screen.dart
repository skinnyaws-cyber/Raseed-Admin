import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:raseed_admin/screens/login_screen.dart';
import 'package:raseed_admin/screens/home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // دالة التسجيل في فايربيس
  Future<void> _handleSignUp() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty || _nameController.text.isEmpty) {
      _showMsg("يرجى ملء جميع الحقول");
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // تحديث اسم المدير
      await userCredential.user?.updateDisplayName(_nameController.text.trim());

      if (mounted) {
        // الحل الجذري: مسح السجل والتوجه للرئيسية فوراً
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = "حدث خطأ في التسجيل";
      if (e.code == 'email-already-in-use') message = "هذا الحساب مسجل مسبقاً";
      else if (e.code == 'weak-password') message = "كلمة المرور ضعيفة جداً";
      _showMsg(message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg, style: const TextStyle(fontFamily: 'IBMPlexSansArabic'))),
    );
  }

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

                // بطاقة التسجيل الزجاجية
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
                      children: [
                        _buildField(_nameController, "الاسم الكامل", Icons.person_outline),
                        const SizedBox(height: 20),
                        _buildField(_emailController, "البريد الإلكتروني", Icons.email_outlined),
                        const SizedBox(height: 20),
                        _buildField(_passwordController, "كلمة المرور", Icons.lock_outline, isPass: true),
                        const Spacer(),
                        GestureDetector(
                          onTap: _isLoading ? null : _handleSignUp,
                          child: Container(
                            width: double.infinity,
                            height: 55,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF4757),
                              borderRadius: BorderRadius.circular(50),
                              boxShadow: [
                                BoxShadow(color: const Color(0xFFFF4757).withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8)),
                              ],
                            ),
                            child: Center(
                              child: _isLoading 
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    "تسجيل حساب جديد",
                                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'IBMPlexSansArabic'),
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // === الإضافة المطلوبة: رابط تسجيل الدخول ===
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "هل لديك حساب مسبق؟ ",
                      style: TextStyle(color: Colors.grey, fontFamily: 'IBMPlexSansArabic'),
                    ),
                    GestureDetector(
                      onTap: () {
                        // الانتقال لصفحة تسجيل الدخول
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      child: const Text(
                        "سجل دخول",
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
                const SizedBox(height: 20),
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