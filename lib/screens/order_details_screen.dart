import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // لتنسيق الوقت بشكل مقروء

class OrderDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  bool _isProcessing = false;

  // دالة تحويل الوقت من Firebase Timestamp إلى نص مفهوم
  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return "غير متوفر";
    DateTime date = (timestamp as Timestamp).toDate();
    return DateFormat('yyyy/MM/dd - hh:mm a').format(date);
  }

  Future<void> _confirmOrder() async {
    setState(() => _isProcessing = true);
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.order['id'])
          .update({'status': 'Successful'});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم تأكيد الطلب بنجاح", style: TextStyle(fontFamily: 'IBMPlexSansArabic'))),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("خطأ في التحديث: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text("مراجعة بيانات التحويل", style: TextStyle(color: Color(0xFF2F3542), fontWeight: FontWeight.bold, fontFamily: 'IBMPlexSansArabic')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2F3542)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
                ),
                child: Column(
                  children: [
                    // تم الالتزام بالتسلسل المطلوب بدقة
                    _buildDataRow("اسم المستخدم", widget.order['userFullName']),
                    const Divider(height: 32),
                    _buildDataRow("رقم الهاتف", widget.order['userPhone']),
                    const Divider(height: 32),
                    _buildDataRow("مبلغ الرصيد", "${widget.order['amount']} د.ع"),
                    const Divider(height: 32),
                    _buildDataRow("بطاقة الاستلام", widget.order['receivingCard']),
                    const Divider(height: 32),
                    _buildDataRow("وقت الطلب", _formatDate(widget.order['timestamp'])),
                  ],
                ),
              ),
            ),
          ),

          // منطقة العمليات (تأكيد التحويل)
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
            ),
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _confirmOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4757),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: _isProcessing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "تأكيد تحويل المال الحقيقي",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'IBMPlexSansArabic'),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, dynamic value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13, fontFamily: 'IBMPlexSansArabic')),
        const SizedBox(height: 6),
        Text(
          value?.toString() ?? "لا توجد بيانات",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2F3542), fontFamily: 'IBMPlexSansArabic'),
        ),
      ],
    );
  }
}
