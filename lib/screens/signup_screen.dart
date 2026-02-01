import 'package:flutter/material.dart';
import 'package:raseed_admin/screens/login_screen.dart'; // سننشئها في الخطوة التالية

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // للتحكم في الحقول
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // دالة وهمية حالياً لزر التسجيل
  void _register() {
    // هنا سنضع كود Firebase Auth لاحقاً
    print("Name: ${_nameController.text}");
    print("Email: ${_emailController.text}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA), // خلفية رمادية فاتحة جداً مريحة للعين
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              
              // العنوان
              const Text(
                "إنشاء حساب مدير",
                style: TextStyle(
                  fontSize: 28, 
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2F3542),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                "أدخل بياناتك للانضمام لفريق الإدارة",
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 50),

              // === حقل الاسم ===
              _buildBubbleTextField(
                controller: _nameController,
                label: "الاسم الكامل",
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 20),

              // === حقل البريد الإلكتروني ===
              _buildBubbleTextField(
                controller: _emailController,
                label: "البريد الإلكتروني",
                icon: Icons.email_outlined,
                inputType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),

              // === حقل كلمة المرور ===
              _buildBubbleTextField(
                controller: _passwordController,
                label: "كلمة المرور",
                icon: Icons.lock_outline,
                isPassword: true,
              ),

              const SizedBox(height: 40),

              // === زر التسجيل (Red Bubble) ===
              ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF4757),
                  foregroundColor: Colors.white,
                  elevation: 5,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // حواف دائرية بالكامل
                  ),
                  shadowColor: const Color(0xFFFF4757).withOpacity(0.5),
                ),
                child: const Text(
                  "تسجيل حساب جديد",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 30),

              // === رابط تسجيل الدخول ===
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "هل لديك حساب بالفعل؟",
                    style: TextStyle(color: Colors.grey),
                  ),
                  TextButton(
                    onPressed: () {
                      // الانتقال لصفحة تسجيل الدخول
                      Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context) => const LoginScreen())
                      );
                    },
                    child: const Text(
                      "قم بتسجيل الدخول",
                      style: TextStyle(
                        color: Color(0xFFFF4757), 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // دالة مساعدة لبناء الحقول بتصميم موحد
  Widget _buildBubbleTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType inputType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // حواف ناعمة
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: inputType,
        decoration: InputDecoration(
          hintText: label,
          prefixIcon: Icon(icon, color: Colors.grey),
          border: InputBorder.none, // إخفاء الحدود الافتراضية
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}
