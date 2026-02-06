import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raseed_admin/screens/order_details_screen.dart';
import 'package:intl/intl.dart' as intl;

class OrdersTab extends StatefulWidget {
  const OrdersTab({super.key});

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
  final Color _primaryColor = const Color(0xFFFF4757);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: StreamBuilder<QuerySnapshot>(
        // جلب الطلبات وترتيبها من الأحدث إلى الأقدم [cite: 158-160]
        stream: FirebaseFirestore.instance
            .collection('orders')
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
              child: Text("لا توجد طلبات حالياً", 
                style: TextStyle(fontFamily: 'IBMPlexSansArabic', color: Colors.grey)),
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
    String status = data['status'] ?? 'pending';
    bool isPending = status == 'pending' || status == 'waiting_admin_confirmation';
    
    // تنسيق الوقت [cite: 155-156]
    String timeStr = "";
    if (data['createdAt'] != null) {
      DateTime dt = (data['createdAt'] as Timestamp).toDate();
      timeStr = intl.DateFormat('hh:mm a').format(dt);
    }

    return Container(
      // التصحيح: تم تغيير EdgeInsets.bottom إلى EdgeInsets.only(bottom: 12)
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
          // الحفاظ على التصحيح السابق: تمرير الـ doc (QueryDocumentSnapshot) [cite: 153-154]
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
            color: isPending ? _primaryColor.withOpacity(0.1) : Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isPending ? Icons.hourglass_empty_rounded : Icons.check_circle_outline_rounded,
            color: isPending ? _primaryColor : Colors.green,
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
