import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raseed_admin/screens/order_details_screen.dart';

class OrdersTab extends StatelessWidget {
  const OrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          "طلبات بانتظار التحويل",
          style: TextStyle(
            fontFamily: 'IBMPlexSansArabic',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color(0xFF2F3542),
          ),
        ),
      ),
      // الاستماع اللحظي للطلبات الجاهزة فقط
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('status', isEqualTo: 'waiting_admin_confirmation') // الحالة الصحيحة من الـ Helper
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("خطأ في جلب البيانات"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFF4757)));
          }

          if (snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              Map<String, dynamic> order = doc.data() as Map<String, dynamic>;
              order['id'] = doc.id; // تمرير الـ ID لعملية التأكيد لاحقاً

              return _buildOrderCard(order, context);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.done_all_rounded, size: 60, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "كل شيء نظيف! لا توجد طلبات معلقة",
            style: TextStyle(fontFamily: 'IBMPlexSansArabic', color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => OrderDetailsScreen(order: order)),
          );
        },
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFF5F6FA),
          child: Icon(Icons.receipt_long_rounded, color: Color(0xFFFF4757)),
        ),
        title: Text(
          order['name'] ?? "عميل رصيد",
          style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontWeight: FontWeight.bold),
        ),
        subtitle: Text("${order['amount']} د.ع - ${order['phone']}"),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
      ),
    );
  }
}
