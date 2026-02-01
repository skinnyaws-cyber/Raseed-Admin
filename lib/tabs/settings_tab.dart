import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:glassmorphism/glassmorphism.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  bool _isDarkMode = false; // متغير محلي للواجهة (سنربطه لاحقاً)
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "الإعدادات والحساب",
          style: TextStyle(
            fontFamily: 'IBMPlexSansArabic',
            fontWeight: FontWeight.bold,
            color: Color(0xFF2F3542),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
        child: Column(
          children: [
            // === 1. بطاقة البروفايل ===
            GlassmorphicContainer(
              width: double.infinity,
              height: 120,
              borderRadius: 20,
              blur: 20,
              alignment: Alignment.center,
              border: 1,
              linearGradient: LinearGradient(
                colors: [const Color(0xFFFF4757).withOpacity(0.2), const Color(0xFFFF4757).withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderGradient: LinearGradient(
                colors: [Colors.white.withOpacity(0.5), Colors.white.withOpacity(0.1)],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: const Icon(Icons.person, size: 40, color: Color(0xFFFF4757)),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? "مدير النظام",
                          style: const TextStyle(
                            fontFamily: 'IBMPlexSansArabic',
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFF2F3542),
                          ),
                        ),
                        Text(
                          user?.email ?? "admin@raseed.app",
                          style: const TextStyle(
                            fontFamily: 'IBMPlexSansArabic',
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // === 2. إعدادات التطبيق ===
            const Align(
              alignment: Alignment.centerRight,
              child: Text("عام", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            ),
            const SizedBox(height: 10),
            _buildSettingsContainer(
              children: [
                SwitchListTile(
                  title: const Text("الوضع الليلي", style: TextStyle(fontFamily: 'IBMPlexSansArabic')),
                  secondary: const Icon(Icons.dark_mode_outlined),
                  activeColor: const Color(0xFFFF4757),
                  value: _isDarkMode,
                  onChanged: (val) {
                    setState(() => _isDarkMode = val);
                    // هنا سنضع كود تغيير الثيم لاحقاً
                  },
                ),
                const Divider(),
                ListTile(
                  title: const Text("لغة التطبيق", style: TextStyle(fontFamily: 'IBMPlexSansArabic')),
                  secondary: const Icon(Icons.language),
                  trailing: const Text("العربية", style: TextStyle(color: Colors.grey)),
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 30),

            // === 3. إدارة الحساب (Pop-ups) ===
            const Align(
              alignment: Alignment.centerRight,
              child: Text("الأمان", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            ),
            const SizedBox(height: 10),
            _buildSettingsContainer(
              children: [
                ListTile(
                  title: const Text("تغيير البريد الإلكتروني", style: TextStyle(fontFamily: 'IBMPlexSansArabic')),
                  subtitle: const Text("سيتم الحفاظ على جميع الإحصائيات", style: TextStyle(fontSize: 10, color: Colors.grey)),
                  leading: const Icon(Icons.email_outlined, color: Color(0xFFFF4757)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: _showChangeEmailDialog,
                ),
                const Divider(),
                ListTile(
                  title: const Text("تغيير كلمة المرور", style: TextStyle(fontFamily: 'IBMPlexSansArabic')),
                  leading: const Icon(Icons.lock_outline, color: Color(0xFFFF4757)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: _showChangePasswordDialog,
                ),
              ],
            ),

            const SizedBox(height: 30),

            // === 4. تسجيل الخروج ===
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  // العودة لصفحة الدخول (سنربطها لاحقاً)
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF4757).withOpacity(0.1),
                  foregroundColor: const Color(0xFFFF4757),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                icon: const Icon(Icons.logout),
                label: const Text("تسجيل الخروج", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // حاوية زجاجية للقوائم
  Widget _buildSettingsContainer({required List<Widget> children}) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: children.length * 75.0, // ارتفاع ديناميكي تقريبي
      borderRadius: 20,
      blur: 20,
      alignment: Alignment.center,
      border: 1,
      linearGradient: LinearGradient(
        colors: [Colors.white.withOpacity(0.8), Colors.white.withOpacity(0.5)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderGradient: LinearGradient(
        colors: [Colors.white.withOpacity(0.5), Colors.white.withOpacity(0.1)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
      ),
    );
  }

  // --- Pop-up: تغيير كلمة المرور ---
  void _showChangePasswordDialog() {
    final passController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF5F6FA),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("تغيير كلمة المرور", style: TextStyle(fontFamily: 'IBMPlexSansArabic')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: passController,
              decoration: const InputDecoration(hintText: "كلمة المرور الجديدة", prefixIcon: Icon(Icons.lock)),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(hintText: "تأكيد كلمة المرور", prefixIcon: Icon(Icons.lock_reset)),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("إلغاء", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              // Firebase Logic Here: user?.updatePassword(...)
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم تحديث كلمة المرور")));
            },
            child: const Text("حفظ"),
          ),
        ],
      ),
    );
  }

  // --- Pop-up: تغيير البريد الإلكتروني ---
  void _showChangeEmailDialog() {
    final emailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF5F6FA),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("تغيير البريد الإلكتروني", style: TextStyle(fontFamily: 'IBMPlexSansArabic')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "تنبيه: تغيير البريد لا يحذف بياناتك أو إحصائياتك.",
              style: TextStyle(fontSize: 12, color: Colors.green),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(hintText: "البريد الإلكتروني الجديد", prefixIcon: Icon(Icons.email)),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(hintText: "كلمة المرور الحالية (للتأكيد)", prefixIcon: Icon(Icons.security)),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("إلغاء", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              // Firebase Logic Here: user?.verifyBeforeUpdateEmail(...)
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم إرسال رابط التأكيد للبريد الجديد")));
            },
            child: const Text("تحديث"),
          ),
        ],
      ),
    );
  }
}
