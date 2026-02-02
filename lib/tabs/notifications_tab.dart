import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsTab extends StatefulWidget {
  const NotificationsTab({super.key});

  @override
  State<NotificationsTab> createState() => _NotificationsTabState();
}

class _NotificationsTabState extends State<NotificationsTab> {
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;

  Future<void> _publishAnnouncement() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى كتابة نص التبليغ أولاً")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // إرسال التبليغ لقاعدة البيانات 
      await FirebaseFirestore.instance.collection('announcements').add({
        'message': text,
        'timestamp': FieldValue.serverTimestamp(),
        'sender_type': 'admin',
        'is_active': true,
      });

      if (mounted) {
        _messageController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("تم نشر التبليغ بنجاح ✅"),
            backgroundColor: Color(0xFF2ED573),
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
      if (mounted) setState(() => _isLoading = false);
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
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: false,
        title: const Text(
          "مركز التبليغات العامة",
          style: TextStyle(
            fontFamily: 'IBMPlexSansArabic',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color(0xFF2F3542),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "إرسال رسالة جماعية للمستخدمين",
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // === منطقة الكتابة الرصينة (بدون زجاج) ===
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _messageController,
                  maxLines: 8, // مساحة كافية ورصينة [cite: 39]
                  style: const TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 16,
                    color: Color(0xFF2F3542),
                  ),
                  decoration: const InputDecoration(
                    hintText: "اكتب هنا نص التنبيه الذي سيظهر لجميع مستخدمي التطبيق...",
                    hintStyle: TextStyle(color: Colors.black26, fontSize: 14),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // === تعليمات أمنية لملء الفراغ ===
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: const [
                  Icon(Icons.warning_amber_rounded, color: Colors.amber),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "سيتم إرسال هذا التبليغ كإشعار فوري لجميع الهواتف المسجلة. تأكد من دقة المعلومات قبل النشر.",
                      style: TextStyle(fontSize: 12, color: Color(0xFF2F3542), fontFamily: 'IBMPlexSansArabic'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // === زر النشر الرصين ===
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _publishAnnouncement,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF4757),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "نشر التبليغ الآن",
                        style: TextStyle(
                          fontFamily: 'IBMPlexSansArabic',
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
