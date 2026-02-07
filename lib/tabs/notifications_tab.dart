import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:glassmorphism/glassmorphism.dart';

class NotificationsTab extends StatefulWidget {
  const NotificationsTab({super.key});

  @override
  State<NotificationsTab> createState() => _NotificationsTabState();
}

class _NotificationsTabState extends State<NotificationsTab> {
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;

  // دالة النشر المرتبطة بتطبيق المستخدمين
  Future<void> _publishAnnouncement() async {
    final text = _messageController.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("لا يمكن نشر إشعار فارغ!", style: TextStyle(fontFamily: 'IBMPlexSansArabic'))),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      // إرسال البيانات لمجموعة notifications ليتعرف عليها تطبيق المستخدم [cite: 165]
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': 'all', // لكي يظهر عند جميع المستخدمين [cite: 165]
        'title': 'إشعار إداري جديد', // العنوان الثابت المعتمد
        'body': text, // نص الإشعار
        'timestamp': FieldValue.serverTimestamp(), // توقيت السيرفر للترتيب [cite: 165]
        'isRead': false, // لتمييزه كإشعار جديد غير مقروء [cite: 179]
        'type': 'broadcast', // لتمييز نوع الإشعار العام [cite: 184]
      });

      if (mounted) {
        _messageController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("تم نشر الإشعار لجميع المستخدمين بنجاح ✅", style: TextStyle(fontFamily: 'IBMPlexSansArabic')),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
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
      backgroundColor: Colors.transparent,
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

            // منطقة الكتابة الزجاجية [cite: 140-145]
            GlassmorphicContainer(
              width: double.infinity,
              height: 250,
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
                  maxLines: 10,
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

            // زر النشر (Red Bubble) [cite: 147-157]
            Center(
              child: GestureDetector(
                onTap: _isLoading ? null : _publishAnnouncement,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _isLoading ? 60 : 200,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4757),
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF4757).withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.2),
                        blurRadius: 5,
                        offset: const Offset(0, -2),
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
                style: TextStyle(fontSize: 12, color: Colors.grey, fontFamily: 'IBMPlexSansArabic'),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}