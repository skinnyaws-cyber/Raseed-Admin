import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart'; // مكتبة البصمة

class AnalyticsTab extends StatefulWidget {
  const AnalyticsTab({super.key});

  @override
  State<AnalyticsTab> createState() => _AnalyticsTabState();
}

class _AnalyticsTabState extends State<AnalyticsTab> {
  final LocalAuthentication auth = LocalAuthentication();
  String _selectedPeriod = "اليومي";
  final List<String> _periods = ["اليومي", "الأسبوعي", "الشهري", "السنوي"];

  final TextEditingController _capitalController = TextEditingController();
  double _currentCapital = 0.0;
  double _alertThreshold = 50000.0;
  bool _isLoadingCapital = false;
  
  String _myStatus = "available";
  String? _forwardToAdminId;

  final NumberFormat _currencyFormatter = NumberFormat("#,##0", "en_US");

  @override
  void initState() {
    super.initState();
    _fetchFinancialData();
    _fetchAdminStatus();
  }

  void _fetchAdminStatus() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      FirebaseFirestore.instance.collection('admins').doc(uid).snapshots().listen((snap) {
        if (snap.exists && mounted) {
          setState(() {
            _myStatus = snap.data()?['status'] ?? "available";
            _forwardToAdminId = snap.data()?['forwardTo'];
          });
        }
      });
    }
  }

  void _fetchFinancialData() {
    FirebaseFirestore.instance.collection('financials').doc('daily_capital').snapshots().listen((snapshot) {
      if (snapshot.exists && mounted) {
        setState(() {
          _currentCapital = (snapshot.data()?['current_amount'] ?? 0).toDouble();
          _alertThreshold = (snapshot.data()?['alert_threshold'] ?? 50000).toDouble();
        });
      }
    });
  }

  // منطق البصمة وتغيير الحالة
  Future<void> _updateStatusWithAuth(String newStatus) async {
    // إذا كان يحاول العودة من الغياب إلى متاح، اطلب البصمة
    if (_myStatus == "away" && newStatus == "available") {
      bool authenticated = false;
      try {
        authenticated = await auth.authenticate(
          localizedReason: 'يرجى تأكيد الهوية للعودة إلى وضع استلام الطلبات',
          options: const AuthenticationOptions(stickyAuth: true, biometricOnly: true),
        );
      } catch (e) {
        _showError("جهازك لا يدعم البصمة أو حدث خطأ.");
        return;
      }

      if (!authenticated) return; // توقف إذا فشل التحقق
    }

    _updateAdminSettings(newStatus, _forwardToAdminId);
  }

  Future<void> _updateAdminSettings(String status, String? forwardId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance.collection('admins').doc(uid).update({
        'status': status,
        'forwardTo': forwardId,
        'isActive': status == "available",
      });
    }
  }

  Future<void> _setCapital() async {
    final amount = double.tryParse(_capitalController.text.replaceAll(',', ''));
    if (amount == null) return;
    setState(() => _isLoadingCapital = true);
    await FirebaseFirestore.instance.collection('financials').doc('daily_capital').set({
      'current_amount': amount,
      'alert_threshold': _alertThreshold,
      'last_updated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    _capitalController.clear();
    if(mounted) setState(() => _isLoadingCapital = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: const Text("الخزنة والعمليات", style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF2F3542))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfitSection(),
            const SizedBox(height: 24),
            _buildCapitalCard(),
            const SizedBox(height: 24),
            const Text("توزيع المهام وحالة النشاط", style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 12),
            _buildStatusSelector(), // اختيار حالتي
            const SizedBox(height: 16),
            _buildAdminsList(), // قائمة المدراء للتحويل
          ],
        ),
      ),
    );
  }

  Widget _buildProfitSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("إجمالي أرباح النظام", style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: _selectedPeriod,
                underline: const SizedBox(),
                items: _periods.map((p) => DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 13)))).toList(),
                onChanged: (val) => setState(() => _selectedPeriod = val!),
              ),
            ],
          ),
          const Divider(height: 24),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('orders').where('status', isEqualTo: 'successful').snapshots(),
            builder: (context, snapshot) {
              double totalCommission = 0;
              if (snapshot.hasData) {
                final now = DateTime.now();
                for (var doc in snapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final commission = (data['commission'] ?? 0).toDouble();
                  final timestamp = (data['completed_at'] as Timestamp?)?.toDate() ?? now;
                  
                  if (_selectedPeriod == "السنوي" && timestamp.year == now.year) totalCommission += commission;
                  else if (_selectedPeriod == "الشهري" && timestamp.month == now.month) totalCommission += commission;
                  else if (_selectedPeriod == "الأسبوعي" && now.difference(timestamp).inDays < 7) totalCommission += commission;
                  else if (_selectedPeriod == "اليومي" && timestamp.day == now.day && timestamp.month == now.month) totalCommission += commission;
                }
              }
              return Column(
                children: [
                  Text("${_currencyFormatter.format(totalCommission)} د.ع", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2ED573), fontFamily: 'IBMPlexSansArabic')),
                  const Text("صافي عمولات كافة المدراء", style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCapitalCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Column(
        children: [
          TextField(
            controller: _capitalController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "تحديث رأس المال اليومي",
              filled: true, fillColor: const Color(0xFFF5F6FA),
              suffixIcon: IconButton(icon: const Icon(Icons.check_circle, color: Color(0xFFFF4757)), onPressed: _setCapital),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 20),
          Text("${_currencyFormatter.format(_currentCapital)} د.ع", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _currentCapital < _alertThreshold ? Colors.red : const Color(0xFF2F3542))),
          const Text("الميزانية الحالية (تخصم تلقائياً عند النجاح)", style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 10),
          Slider(value: _alertThreshold, min: 0, max: 1000000, activeColor: const Color(0xFFFF4757), onChanged: (val) => setState(() => _alertThreshold = val)),
          Text("تنبيه عند الوصول لـ: ${_currencyFormatter.format(_alertThreshold)}", style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildStatusSelector() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF2F3542), borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatusBtn("available", "متاح", Colors.green),
          _buildStatusBtn("busy", "مشغول", Colors.orange),
          _buildStatusBtn("away", "غائب", Colors.red),
        ],
      ),
    );
  }

  Widget _buildStatusBtn(String status, String label, Color color) {
    bool isMe = _myStatus == status;
    return GestureDetector(
      onTap: () => _updateStatusWithAuth(status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: isMe ? color : Colors.transparent, borderRadius: BorderRadius.circular(10)),
        child: Text(label, style: TextStyle(color: isMe ? Colors.white : Colors.white60, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildAdminsList() {
    return Container(
      height: 300,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text("تحويل الطلبات لمدير آخر", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('admins').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                
                var docs = snapshot.data!.docs.where((d) => d.id != FirebaseAuth.instance.currentUser?.uid).toList();
                
                return ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var data = docs[index].data() as Map<String, dynamic>;
                    String status = data['status'] ?? "away";
                    bool isSelected = _forwardToAdminId == docs[index].id;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getStatusColor(status).withOpacity(0.2),
                        child: Icon(Icons.person, color: _getStatusColor(status), size: 18),
                      ),
                      title: Text(data['adminName'] ?? "مدير", style: const TextStyle(fontSize: 14)),
                      subtitle: Text(_getStatusText(status), style: TextStyle(fontSize: 11, color: _getStatusColor(status))),
                      trailing: isSelected 
                        ? IconButton(icon: const Icon(Icons.cancel, color: Colors.red), onPressed: () => _updateAdminSettings(_myStatus, null))
                        : IconButton(icon: const Icon(Icons.forward_to_inbox, color: Colors.blue), onPressed: () => _updateAdminSettings(_myStatus, docs[index].id)),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status == "available") return Colors.green;
    if (status == "busy") return Colors.orange;
    return Colors.red;
  }

  String _getStatusText(String status) {
    if (status == "available") return "متاح لاستلام الطلبات";
    if (status == "busy") return "مشغول حالياً";
    return "خارج العمل (غائب)";
  }

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}
