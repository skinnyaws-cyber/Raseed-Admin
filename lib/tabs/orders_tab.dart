import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // إضافة استيراد Auth للتحقق من هوية المدير
import 'package:raseed_admin/screens/order_details_screen.dart';
import 'package:intl/intl.dart' as intl;

class OrdersTab extends StatefulWidget {
  const OrdersTab({super.key});

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
  final Color _primaryColor = const Color(0xFFFF4757);
  final String? _currentAdminUid = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: StreamBuilder<QuerySnapshot>(
        // تحديث الاستعلام: جلب الطلبات المخصصة لهذا المدير والتي تنتظر التأكيد المالي فقط 
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('assignedTo', isEqualTo: _currentAdminUid) // عرض الطلبات المخصصة لك فقط
            .where('status', isEqualTo: 'waiting_admin_confirmation') // استبعاد حالة pending تماماً
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("حدث خطأ في تحميل البيانات"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_turned_in_rounded, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "لا توجد طلبات بانتظار تأكيدك حالياً", 
                    style: TextStyle(fontFamily: 'IBMPlexSansArabic', color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var data = doc.data() as Map<String, dynamic>;

              return _buildOrderCard(doc, data);
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(QueryDocumentSnapshot doc, Map<String, dynamic> data) {
    // بما أننا قمنا بالفلترة في الاستعلام، فكل الطلبات هنا هي waiting_admin_confirmation [cite: 76]
    
    String timeStr = "";
    if (data['createdAt'] != null) {
      DateTime dt = (data['createdAt'] as Timestamp).toDate();
      timeStr = intl.DateFormat('hh:mm a').format(dt);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailsScreen(order: doc),
            ),
          );
        },
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.account_balance_wallet_rounded, // أيقونة تدل على انتظار التحويل المالي
            color: _primaryColor,
            size: 24,
          ),
        ),
        title: Text(
          data['userFullName'] ?? "عميل غير معروف",
          style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'IBMPlexSansArabic', fontSize: 15),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text("${data['amount'] ?? 0} د.ع", 
              style: TextStyle(color: _primaryColor, fontWeight: FontWeight.w600, fontSize: 13)),
            Text(timeStr, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
      ),
    );
  }
}