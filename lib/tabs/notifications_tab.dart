import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:glassmorphism/glassmorphism.dart';

class NotificationsTab extends StatefulWidget {
  const NotificationsTab({super.key});

  @override
  State<NotificationsTab> createState() => _NotificationsTabState();
}

class _NotificationsTabState extends State<NotificationsTab> {
  // للتحكم في النص المدخل
  final TextEditingController _messageController = TextEditingController();
  
  // للتحكم في حالة التحميل (لمنع الضغط المكرر)
  bool _isLoading = false;

  // دالة النشر الحقيقية
  Future<void> _publishAnnouncement() async {
    final text = _messageController.text.trim();

    // 1. التحقق من أن الحقل ليس فارغاً
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("لا يمكن نشر إشعار فارغ!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. إرسال البيانات الحقيقية لـ Firebase Firestore
      await FirebaseFirestore.instance.collection('announcements').add({
        'message': text,
        'timestamp': FieldValue.serverTimestamp(), // توقيت السيرفر الموحد
        'sender_type': 'admin',
        'is_active': true, // يمكن استخدامه لاحقاً لإخفاء الإعلان
      });

      // 3. تنظيف الحقل وإظهار نجاح
      if (mounted) {
        _messageController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("تم نشر الإشعار لجميع المستخدمين بنجاح ✅"),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // 4. معالجة الأخطاء
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("فشل النشر: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // تعتمد على خلفية Home
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "مركز التنبيهات",
          style: TextStyle(
            fontFamily: 'IBMPlexSansArabic',
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Color(0xFF2F3542),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "رسالة جديدة للجميع",
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 15),

            // === منطقة الكتابة الزجاجية ===
            GlassmorphicContainer(
              width: double.infinity,
              height: 250, // مساحة كافية للكتابة المريحة
              borderRadius: 20,
              blur: 20,
              alignment: Alignment.center,
              border: 1,
              linearGradient: LinearGradient(
                colors: [Colors.white.withOpacity(0.9), Colors.white.withOpacity(0.5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderGradient: LinearGradient(
                colors: [Colors.white.withOpacity(0.6), Colors.white.withOpacity(0.1)],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _messageController,
                  maxLines: 10, // يسمح بكتابة نص طويل
                  style: const TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 16,
                    color: Color(0xFF2F3542),
                  ),
                  decoration: const InputDecoration(
                    hintText: "أكتب نص الإشعار هنا...\nيمكنك نسخ ولصق النصوص.",
                    hintStyle: TextStyle(color: Colors.black38),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // === زر النشر (Red Bubble) ===
            Center(
              child: GestureDetector(
                onTap: _isLoading ? null : _publishAnnouncement,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _isLoading ? 60 : 200, // يصغر ليتحول لدائرة تحميل عند الضغط
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4757),
                    borderRadius: BorderRadius.circular(50), // Bubble
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF4757).withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.2),
                        blurRadius: 5,
                        offset: const Offset(0, -2), // إضاءة علوية
                      ),
                    ],
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B81), Color(0xFFFF4757)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: _isLoading
                        ? const SizedBox(
                            width: 25,
                            height: 25,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                          )
                        : const Text(
                            "نشر",
                            style: TextStyle(
                              fontFamily: 'IBMPlexSansArabic',
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            const Center(
              child: Text(
                "تحذير: بمجرد الضغط على نشر، سيصل الإشعار لجميع المستخدمين فوراً.",
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
