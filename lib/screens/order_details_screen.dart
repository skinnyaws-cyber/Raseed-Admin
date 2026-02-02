import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2F3542)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("تفاصيل الطلب", style: TextStyle(color: Color(0xFF2F3542), fontWeight: FontWeight.bold, fontFamily: 'IBMPlexSansArabic')),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // بطاقة تفاصيل الطلب الزجاجية
                GlassmorphicContainer(
                  width: double.infinity,
                  height: 300,
                  borderRadius: 30,
                  blur: 20,
                  alignment: Alignment.center,
                  border: 2,
                  linearGradient: LinearGradient(colors: [Colors.white.withOpacity(0.9), Colors.white.withOpacity(0.6)]),
                  borderGradient: LinearGradient(colors: [Colors.white.withOpacity(0.5), Colors.white.withOpacity(0.1)]),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        _buildDetailRow("اسم العميل", order['name']),
                        const Divider(),
                        _buildDetailRow("رقم الهاتف", order['phone']),
                        const Divider(),
                        _buildDetailRow("المبلغ الإجمالي", "${order['amount']} د.ع"),
                        const Divider(),
                        _buildDetailRow("طريقة الدفع", order['type'] ?? "Zain Cash"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // === زر تأكيد الطلب الأحمر بالأسفل ===
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: GestureDetector(
                onTap: () {
                  // هنا نضع منطق التأكيد مع Firebase لاحقاً
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("تم تأكيد الطلب بنجاح", style: TextStyle(fontFamily: 'IBMPlexSansArabic'))),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4757), // اللون الأحمر الأساسي
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFFFF4757).withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8)),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      "تأكيد الطلب الآن",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'IBMPlexSansArabic'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontFamily: 'IBMPlexSansArabic')),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2F3542), fontFamily: 'IBMPlexSansArabic')),
        ],
      ),
    );
  }
}