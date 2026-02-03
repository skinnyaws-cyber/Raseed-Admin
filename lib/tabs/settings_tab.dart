import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:raseed_admin/screens/signup_screen.dart'; // لتوجيه المستخدم عند الخروج أو الحذف

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  final TextEditingController _chatIdController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isSaving = false;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentData();
  }

  // تحميل البيانات الحالية (Chat ID والبريد الإلكتروني) [cite: 136, 137]
  Future<void> _loadCurrentData() async {
    if (_currentUser == null) return;
    _emailController.text = _currentUser!.email ?? "";
    
    var doc = await FirebaseFirestore.instance.collection('admins').doc(_currentUser!.uid).get();
    if (doc.exists && doc.data() != null && mounted) {
      setState(() {
        _chatIdController.text = doc.data()!['telegramChatId']?.toString() ?? "";
      });
    }
  }

  // 1. وظيفة تسجيل الخروج
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const SignUpScreen()),
        (route) => false,
      );
    }
  }

  // 2. وظيفة حذف الحساب نهائياً
  Future<void> _deleteAccount() async {
    bool confirm = await _showConfirmDialog("حذف الحساب", "هل أنت متأكد؟ سيتم حذف بياناتك والـ Chat ID ولن تتمكن من العودة.");
    if (!confirm || _currentUser == null) return;

    setState(() => _isSaving = true);
    try {
      String uid = _currentUser!.uid;
      // أ- حذف البيانات من Firestore أولاً [cite: 140]
      await FirebaseFirestore.instance.collection('admins').doc(uid).delete();
      
      // ب- حذف المستخدم من Firebase Auth
      await _currentUser!.delete();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const SignUpScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      _showError("يجب تسجيل الدخول مرة أخرى قبل حذف الحساب لأسباب أمنية.");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // 3. تحديث البيانات (البريد، كلمة المرور، و Chat ID) [cite: 139, 140]
  Future<void> _updateAccount() async {
    if (_currentUser == null) return;
    setState(() => _isSaving = true);

    try {
      // أ- تحديث الـ Chat ID في Firestore [cite: 140]
      await FirebaseFirestore.instance.collection('admins').doc(_currentUser!.uid).update({
        'telegramChatId': _chatIdController.text.trim(),
        'lastUpdate': FieldValue.serverTimestamp(),
      });

      // ب- تحديث البريد الإلكتروني إذا تغير
      if (_emailController.text.trim() != _currentUser!.email) {
        await _currentUser!.updateEmail(_emailController.text.trim());
      }

      // ج- تحديث كلمة المرور إذا تم إدخال واحدة جديدة
      if (_passwordController.text.isNotEmpty) {
        await _currentUser!.updatePassword(_passwordController.text.trim());
      }

      _showSuccess("تم تحديث كافة البيانات بنجاح ✅");
    } catch (e) {
      _showError("خطأ في التحديث: تأكد من صحة البيانات أو أعد تسجيل الدخول.");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text("إعدادات الإدارة", style: TextStyle(color: Color(0xFF2F3542), fontWeight: FontWeight.bold, fontFamily: 'IBMPlexSansArabic')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // قسم البيانات الشخصية
            _buildSectionCard("البيانات الشخصية", [
              _buildInputField(_emailController, "البريد الإلكتروني", Icons.email_outlined, isNumber: false),
              const SizedBox(height: 15),
              _buildInputField(_passwordController, "كلمة مرور جديدة", Icons.lock_outline, isNumber: false, isPass: true),
            ]),

            const SizedBox(height: 20),

            // قسم التنبيهات (Chat ID) [cite: 145-147]
            _buildSectionCard("إعدادات تليجرام", [
              _buildInputField(_chatIdController, "Telegram Chat ID", Icons.send_rounded, isNumber: true),
              const SizedBox(height: 10),
              const Text("يستخدم لإرسال إشعارات الطلبات المخصصة لك.", style: TextStyle(fontSize: 11, color: Colors.grey, fontFamily: 'IBMPlexSansArabic')),
            ]),

            const SizedBox(height: 30),

            // أزرار التحكم
            _buildActionButton("حفظ التغييرات", _updateAccount, const Color(0xFFFF4757)),
            const SizedBox(height: 12),
            _buildActionButton("تسجيل الخروج", _logout, const Color(0xFF2F3542)),
            const SizedBox(height: 40),

            // زر الحذف النهائي
            TextButton.icon(
              onPressed: _deleteAccount,
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              label: const Text("حذف الحساب نهائياً", style: TextStyle(color: Colors.red, fontFamily: 'IBMPlexSansArabic', decoration: TextDecoration.underline)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey, fontFamily: 'IBMPlexSansArabic')),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInputField(TextEditingController controller, String label, IconData icon, {required bool isNumber, bool isPass = false}) {
    return TextField(
      controller: controller,
      obscureText: isPass,
      keyboardType: isNumber ? TextInputType.number : TextInputType.emailAddress,
      style: const TextStyle(fontFamily: 'IBMPlexSansArabic'),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFFFF4757), size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildActionButton(String label, VoidCallback action, Color color) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isSaving ? null : action,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: _isSaving 
          ? const CircularProgressIndicator(color: Colors.white) 
          : Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'IBMPlexSansArabic')),
      ),
    );
  }

  // دوال مساعدة للتفاعل مع المستخدم
  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  void _showSuccess(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
  
  Future<bool> _showConfirmDialog(String title, String body) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: const TextStyle(fontFamily: 'IBMPlexSansArabic')),
        content: Text(body, style: const TextStyle(fontFamily: 'IBMPlexSansArabic')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("إلغاء")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("تأكيد الحذف", style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;
  }
}
