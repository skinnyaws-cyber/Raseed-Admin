import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AnalyticsTab extends StatefulWidget {
  const AnalyticsTab({super.key});

  @override
  State<AnalyticsTab> createState() => _AnalyticsTabState();
}

class _AnalyticsTabState extends State<AnalyticsTab> {
  bool _isMenuOpen = false;
  String _selectedPeriod = "اليومي";
  final List<String> _periods = ["اليومي", "الأسبوعي", "الشهري", "السنوي"];

  final TextEditingController _capitalController = TextEditingController();
  double _currentCapital = 0.0;
  double _alertThreshold = 50000.0;
  bool _isLoadingCapital = false;
  
  String _myStatus = "available";
  String? _forwardToAdminId; // منطق تحويل المهام المعاد 

  final NumberFormat _currencyFormatter = NumberFormat("#,##0", "en_US");

  @override
  void initState() {
    super.initState();
    _fetchFinancialData();
    _fetchAdminStatus();
  }

  // جلب حالة المدير الحالية وإعدادات التحويل
  void _fetchAdminStatus() async {
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

  // تحديث الحالة والتحويل في Firestore
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) => RotationTransition(
              // إصلاح: جعل الخطوط تبقى أفقية عبر دورة كاملة
              turns: child.key == const ValueKey('icon1') 
                ? Tween<double>(begin: 0, end: 1).animate(anim) 
                : Tween<double>(begin: 1, end: 0).animate(anim),
              child: ScaleTransition(scale: anim, child: child),
            ),
            child: _isMenuOpen
                ? const Icon(Icons.emergency_rounded, color: Color(0xFFFF4757), key: ValueKey('icon2'))
                : const Icon(Icons.menu_rounded, color: Color(0xFF2F3542), key: ValueKey('icon1')),
          ),
          onPressed: () => setState(() => _isMenuOpen = !_isMenuOpen),
        ),
        title: const Text("الخزنة والعمليات", style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontWeight: FontWeight.bold, fontSize: 18)),
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
            _buildAdminOpsCard(), // البطاقة المعاد هندستها لتشمل التحويل
          ],
        ),
      ),
    );
  }

  Widget _buildAdminOpsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF2F3542), borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("حالتي الآن:", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'IBMPlexSansArabic')),
              DropdownButton<String>(
                value: _myStatus,
                dropdownColor: const Color(0xFF2F3542),
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: "available", child: Text("🟢 متاح", style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(value: "busy", child: Text("🟠 مشغول", style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(value: "away", child: Text("🔴 غائب", style: TextStyle(color: Colors.white))),
                ],
                onChanged: (val) => _updateAdminSettings(val!, _forwardToAdminId),
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 24),
          // إعادة ميزة تحويل الطلبات لمدير آخر 
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("تحويل الطلبات إلى:", style: TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'IBMPlexSansArabic')),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('admins').where(FieldPath.documentId, isNotEqualTo: FirebaseAuth.instance.currentUser?.uid).snapshots(),
                builder: (context, snapshot) {
                  List<DropdownMenuItem<String>> items = [
                    const DropdownMenuItem(value: null, child: Text("تعطيل التحويل", style: TextStyle(color: Colors.white70, fontSize: 12))),
                  ];
                  if (snapshot.hasData) {
                    for (var doc in snapshot.data!.docs) {
                      items.add(DropdownMenuItem(
                        value: doc.id,
                        child: Text(doc['adminName'] ?? "مدير آخر", style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ));
                    }
                  }
                  return DropdownButton<String?>(
                    value: _forwardToAdminId,
                    dropdownColor: const Color(0xFF2F3542),
                    underline: const SizedBox(),
                    items: items,
                    onChanged: (val) => _updateAdminSettings(_myStatus, val),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ... (دوال _buildProfitSection و _buildCapitalCard تبقى كما هي دون تغيير في المنطق)
  Widget _buildProfitSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("صافي الأرباح", style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontWeight: FontWeight.bold)),
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
            stream: FirebaseFirestore.instance.collection('orders').where('status', isEqualTo: 'success').snapshots(),
            builder: (context, snapshot) {
              double total = 0;
              if (snapshot.hasData) {
                final now = DateTime.now();
                for (var doc in snapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final amount = (data['net_amount'] ?? 0).toDouble();
                  final timestamp = (data['completed_at'] as Timestamp?)?.toDate() ?? now;
                  if (_selectedPeriod == "السنوي" && timestamp.year == now.year) total += amount;
                  else if (_selectedPeriod == "الشهري" && timestamp.month == now.month) total += amount;
                  else if (_selectedPeriod == "الأسبوعي" && now.difference(timestamp).inDays < 7) total += amount;
                  else if (_selectedPeriod == "اليومي" && timestamp.day == now.day) total += amount;
                }
              }
              return Column(
                children: [
                  Text("${_currencyFormatter.format(total)} د.ع", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2ED573), fontFamily: 'IBMPlexSansArabic')),
                  const Text("إجمالي الأرباح للفترة المختارة", style: TextStyle(fontSize: 12, color: Colors.grey)),
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
          const Text("الميزانية الحالية المتوفرة", style: TextStyle(fontSize: 12, color: Colors.grey)),
          Slider(value: _alertThreshold, min: 0, max: 500000, activeColor: const Color(0xFFFF4757), onChanged: (val) => setState(() => _alertThreshold = val)),
        ],
      ),
    );
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
}
