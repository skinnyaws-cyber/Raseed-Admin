import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // نحتاجها لجلب ID المدير الحالي
import 'package:raseed_admin/screens/order_details_screen.dart';

class OrdersTab extends StatelessWidget {
  const OrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final String? currentAdminId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          "طلباتك المخصصة",
          style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF2F3542)),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            // شرط 1: الطلبات الجاهزة للموافقة
            .where('status', isEqualTo: 'waiting_admin_confirmation') 
            // شرط 2: الطلبات المخصصة لك فقط (منع التكرار)
            .where('assignedTo', isEqualTo: currentAdminId) 
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("خطأ في البيانات"));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.docs.isEmpty) return _buildEmptyState();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              Map<String, dynamic> order = doc.data() as Map<String, dynamic>;
              order['id'] = doc.id;
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
          Icon(Icons.assignment_turned_in_rounded, size: 60, color: Colors.grey),
          SizedBox(height: 16),
          Text("لا توجد طلبات مخصصة لك حالياً", style: TextStyle(fontFamily: 'IBMPlexSansArabic', color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]),
      child: ListTile(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => OrderDetailsScreen(order: order))),
        leading: const CircleAvatar(backgroundColor: Color(0xFFF5F6FA), child: Icon(Icons.person_pin_rounded, color: Color(0xFFFF4757))),
        title: Text(order['userFullName'] ?? "طلب جديد", style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontWeight: FontWeight.bold)),
        subtitle: Text("${order['amount']} د.ع - ${order['userPhone']}"),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
      ),
    );
  }
}