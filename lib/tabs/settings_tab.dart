import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:raseed_admin/screens/signup_screen.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  final TextEditingController _chatIdController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (_currentUser == null) return;
    _emailController.text = _currentUser!.email ?? "";
    
    var doc = await FirebaseFirestore.instance.collection('admins').doc(_currentUser!.uid).get();
    if (doc.exists && mounted) {
      setState(() {
        _chatIdController.text = doc.data()?['telegramChatId']?.toString() ?? "";
      });
    }
  }

  // 1. تحديث بيانات الدخول
  Future<void> _updateAuthCredentials() async {
    if (_currentUser == null) return;
    setState(() => _isLoading = true);
    try {
      if (_emailController.text.trim() != _currentUser!.email) {
        await _currentUser!.updateEmail(_emailController.text.trim());
      }
      if (_passwordController.text.isNotEmpty) {
        await _currentUser!.updatePassword(_passwordController.text.trim());
      }
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم تحديث بيانات الدخول بنجاح ✅")));
      }
    } catch (e) {
      _showError("يجب تسجيل الخروج والمعاودة لتغيير البيانات الحساسة لدواعي أمنية.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 2. حفظ الـ Chat ID
  Future<void> _saveChatId() async {
    if (_currentUser == null) return;
    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('admins').doc(_currentUser!.uid).set({
        'telegramChatId': _chatIdController.text.trim(),
        'isActive': true,
        'lastUpdate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم ربط التليجرام بنجاح ✅")));
      }
    } catch (e) {
      _showError("فشل تحديث Chat ID: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 3. تسجيل الخروج
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const SignUpScreen()), (route) => false);
    }
  }

  // 4. دالة حذف الحساب النهائية (المنطق الجديد)
  Future<void> _deleteAccount() async {
    if (_currentUser == null) return;
    setState(() => _isLoading = true);
    final String uid = _currentUser!.uid;

    try {
      // أولاً: حذف مستند المدير من Firestore لضمان مسح البيانات
      await FirebaseFirestore.instance.collection('admins').doc(uid).delete();

      // ثانياً: حذف المستخدم من نظام المصادقة
      await _currentUser!.delete();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const SignUpScreen()), (route) => false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم حذف الحساب والبيانات نهائياً")));
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        _showError("لدواعي أمنية، يرجى تسجيل الخروج ثم الدخول مرة أخرى قبل حذف الحساب.");
      } else {
        _showError("حدث خطأ أثناء الحذف: ${e.message}");
      }
    } catch (e) {
      _showError("فشل حذف الحساب: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("الإعدادات", style: TextStyle(color: Color(0xFF2F3542), fontWeight: FontWeight.bold, fontFamily: 'IBMPlexSansArabic')),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildSettingTile(
              title: "Email & security",
              subtitle: "تغيير البريد الإلكتروني وكلمة المرور",
              icon: Icons.security_rounded,
              onTap: () => _showAuthModal(),
            ),
            _buildSettingTile(
              title: "تهيئة الإشعارات",
              subtitle: "ربط الـ Chat ID لاستلام الطلبات",
              icon: Icons.notifications_active_rounded,
              onTap: () => _showNotificationModal(),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F3542),
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("تسجيل الخروج", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'IBMPlexSansArabic')),
              ),
            ),
            const SizedBox(height: 10),
            _isLoading 
              ? const CircularProgressIndicator(color: Colors.red)
              : TextButton(
                  onPressed: () => _showDeleteConfirmation(),
                  child: const Text("حذف الحساب نهائياً", style: TextStyle(color: Colors.red, decoration: TextDecoration.underline, fontFamily: 'IBMPlexSansArabic')),
                ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      color: Colors.white,
      child: Column(
        children: [
          const CircleAvatar(
            radius: 42,
            backgroundColor: Color(0xFFF5F6FA),
            child: Icon(Icons.person_rounded, size: 40, color: Color(0xFFFF4757)),
          ),
          const SizedBox(height: 12),
          Text(_currentUser?.displayName ?? "مدير النظام", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'IBMPlexSansArabic')),
          Text(_currentUser?.email ?? "", style: const TextStyle(fontSize: 14, color: Colors.grey, fontFamily: 'IBMPlexSansArabic')),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("حذف الحساب", textAlign: TextAlign.right, style: TextStyle(fontFamily: 'IBMPlexSansArabic')),
        content: const Text("هل أنت متأكد من حذف الحساب نهائياً؟ سيتم مسح كافة بياناتك من قاعدة البيانات ولا يمكن التراجع عن هذا الإجراء.", 
          textAlign: TextAlign.right, style: TextStyle(fontFamily: 'IBMPlexSansArabic')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء", style: TextStyle(color: Colors.grey, fontFamily: 'IBMPlexSansArabic')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAccount();
            },
            child: const Text("نعم، احذف نهائياً", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontFamily: 'IBMPlexSansArabic')),
          ),
        ],
      ),
    );
  }

  void _showAuthModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("تحديث بيانات الدخول", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'IBMPlexSansArabic')),
            const SizedBox(height: 20),
            _buildModalField(_emailController, "البريد الإلكتروني الحالي", Icons.email_outlined),
            const SizedBox(height: 12),
            _buildModalField(_passwordController, "كلمة مرور جديدة", Icons.lock_outline, isPass: true),
            const SizedBox(height: 25),
            _buildSaveButton("تحديث البيانات", _updateAuthCredentials),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showNotificationModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("تهيئة الإشعارات", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'IBMPlexSansArabic')),
            const SizedBox(height: 20),
            _buildModalField(_chatIdController, "Telegram Chat ID", Icons.send_rounded, isNum: true),
            const SizedBox(height: 10),
            const Text("يمكنك جلب الـ ID عبر مراسلة @userinfobot", style: TextStyle(fontSize: 11, color: Colors.grey, fontFamily: 'IBMPlexSansArabic')),
            const SizedBox(height: 25),
            _buildSaveButton("حفظ التغييرات", _saveChatId),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: const Color(0xFFFF4757)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'IBMPlexSansArabic', fontSize: 15)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey, fontFamily: 'IBMPlexSansArabic')),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
      ),
    );
  }

  Widget _buildModalField(TextEditingController controller, String label, IconData icon, {bool isPass = false, bool isNum = false}) {
    return TextField(
      controller: controller,
      obscureText: isPass,
      keyboardType: isNum ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontFamily: 'IBMPlexSansArabic'),
        prefixIcon: Icon(icon, color: const Color(0xFFFF4757), size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildSaveButton(String label, VoidCallback onAction) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onAction,
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF4757), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        child: _isLoading 
          ? const CircularProgressIndicator(color: Colors.white) 
          : Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'IBMPlexSansArabic')),
      ),
    );
  }

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, style: const TextStyle(fontFamily: 'IBMPlexSansArabic'))));
}
