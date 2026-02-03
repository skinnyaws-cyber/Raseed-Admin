import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  final TextEditingController _chatIdController = TextEditingController();
  bool _isSaving = false;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentChatId();
  }

  // جلب الـ Chat ID الحالي إذا كان موجوداً مسبقاً
  Future<void> _loadCurrentChatId() async {
    if (_currentUser == null) return;
    var doc = await FirebaseFirestore.instance.collection('admins').doc(_currentUser!.uid).get();
    if (doc.exists && doc.data() != null) {
      setState(() {
        _chatIdController.text = doc.data()!['telegramChatId']?.toString() ?? "";
      });
    }
  }

  // حفظ الـ Chat ID في قاعدة البيانات
  Future<void> _saveSettings() async {
    if (_currentUser == null) return;
    if (_chatIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("يرجى إدخال Chat ID")));
      return;
    }

    setState(() => _isSaving = true);
    try {
      await FirebaseFirestore.instance.collection('admins').doc(_currentUser!.uid).set({
        'adminName': _currentUser!.displayName ?? "مدير",
        'adminEmail': _currentUser!.email,
        'telegramChatId': _chatIdController.text.trim(),
        'isActive': true, // لتفعيل استلام الطلبات تلقائياً
        'lastUpdate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم تحديث البيانات بنجاح ✅")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("خطأ في الحفظ: $e")));
      }
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
        title: const Text("إعدادات الملف الشخصي", style: TextStyle(color: Color(0xFF2F3542), fontWeight: FontWeight.bold, fontFamily: 'IBMPlexSansArabic')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("معلومات الربط التقني", style: TextStyle(fontSize: 14, color: Colors.grey, fontFamily: 'IBMPlexSansArabic')),
            const SizedBox(height: 16),
            
            // حقل إدخال الـ Chat ID
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  _buildInputField(_chatIdController, "Telegram Chat ID", Icons.send_rounded),
                  const SizedBox(height: 12),
                  const Text(
                    "يمكنك الحصول على الـ ID الخاص بك عبر مراسلة @userinfobot في تليجرام.",
                    style: TextStyle(fontSize: 11, color: Colors.grey, fontFamily: 'IBMPlexSansArabic'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // زر الحفظ
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF4757),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isSaving 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text("حفظ الإعدادات", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'IBMPlexSansArabic')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFFF4757)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
