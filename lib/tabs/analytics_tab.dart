import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:intl/intl.dart'; // لتنسيق الأرقام والتواريخ

class AnalyticsTab extends StatefulWidget {
  const AnalyticsTab({super.key});

  @override
  State<AnalyticsTab> createState() => _AnalyticsTabState();
}

class _AnalyticsTabState extends State<AnalyticsTab> {
  // للتحكم في إدخال رأس المال
  final TextEditingController _capitalController = TextEditingController();
  
  // قيم افتراضية للمتغيرات (سيتم تحديثها من القاعدة)
  double _currentCapital = 0.0;
  double _alertThreshold = 50000.0; // حد التنبيه الافتراضي
  bool _isLoadingCapital = false;

  // حالة المدير
  String _myStatus = "available"; // available, busy, away
  String? _forwardToAdminId; // ID المدير الذي حولت له الطلبات

  final NumberFormat _currencyFormatter = NumberFormat("#,##0", "en_US");

  @override
  void initState() {
    super.initState();
    _fetchFinancialData();
  }

  // جلب بيانات رأس المال من Firestore
  void _fetchFinancialData() {
    FirebaseFirestore.instance
        .collection('financials')
        .doc('daily_capital')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        setState(() {
          _currentCapital = (snapshot.data()?['current_amount'] ?? 0).toDouble();
          _alertThreshold = (snapshot.data()?['alert_threshold'] ?? 50000).toDouble();
        });
      }
    });
  }

  // تحديث رأس المال (Reset)
  Future<void> _setCapital() async {
    final amount = double.tryParse(_capitalController.text.replaceAll(',', ''));
    if (amount == null) return;

    setState(() => _isLoadingCapital = true);
    try {
      await FirebaseFirestore.instance.collection('financials').doc('daily_capital').set({
        'current_amount': amount,
        'start_amount': amount, // نحتفظ بقيمة البداية للمقارنة
        'alert_threshold': _alertThreshold,
        'last_updated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      _capitalController.clear();
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم تحديث رأس المال اليومي")));
    } catch (e) {
      // Error handling
    } finally {
      if(mounted) setState(() => _isLoadingCapital = false);
    }
  }

  // تحديث حد التنبيه (Slider)
  Future<void> _updateThreshold(double value) async {
    setState(() => _alertThreshold = value);
    // تحديث في القاعدة (Debounce يمكن إضافته لتحسين الأداء)
    await FirebaseFirestore.instance.collection('financials').doc('daily_capital').update({
      'alert_threshold': value,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "الخزنة والعمليات",
          style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontWeight: FontWeight.bold, color: Color(0xFF2F3542)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === 1. بطاقات الإحصائيات (Grid) ===
            const Text("الملخص المالي (الصافي)", style: TextStyle(fontFamily: 'IBMPlexSansArabic', color: Colors.grey)),
            const SizedBox(height: 10),
            _buildStatsGrid(),

            const SizedBox(height: 30),

            // === 2. إدارة رأس المال (The Vault) ===
            const Text("إدارة رأس المال اليومي", style: TextStyle(fontFamily: 'IBMPlexSansArabic', color: Colors.grey)),
            const SizedBox(height: 10),
            _buildCapitalSection(),

            const SizedBox(height: 30),

            // === 3. غرفة العمليات (Admin Ops) ===
            const Text("توزيع المهام والتحويل", style: TextStyle(fontFamily: 'IBMPlexSansArabic', color: Colors.grey)),
            const SizedBox(height: 10),
            _buildAdminOpsSection(),
          ],
        ),
      ),
    );
  }

  // --- Widget: شبكة الإحصائيات ---
  Widget _buildStatsGrid() {
    return StreamBuilder<QuerySnapshot>(
      // نستمع لكل الطلبات الناجحة لحساب المجموع (في التطبيق الفعلي يفضل استخدام Aggregation Queries لتقليل التكلفة)
      stream: FirebaseFirestore.instance.collection('orders').where('status', isEqualTo: 'success').snapshots(),
      builder: (context, snapshot) {
        double daily = 0;
        double weekly = 0;
        double monthly = 0;
        double yearly = 0;

        if (snapshot.hasData) {
          final now = DateTime.now();
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final amount = (data['net_amount'] ?? 0).toDouble(); // نستخدم الصافي كما طلبت
            final timestamp = (data['completed_at'] as Timestamp?)?.toDate() ?? now;

            if (timestamp.year == now.year) {
              yearly += amount;
              if (timestamp.month == now.month) {
                monthly += amount;
                // أسبوعي تقريبي
                if (now.difference(timestamp).inDays < 7) weekly += amount;
                if (timestamp.day == now.day) daily += amount;
              }
            }
          }
        }

        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard("اليومي", daily, Colors.blueAccent),
            _buildStatCard("الأسبوعي", weekly, Colors.purpleAccent),
            _buildStatCard("الشهري", monthly, Colors.orangeAccent),
            _buildStatCard("السنوي", yearly, const Color(0xFFFF4757)),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, double amount, Color color) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: double.infinity,
      borderRadius: 15,
      blur: 15,
      alignment: Alignment.center,
      border: 1,
      linearGradient: LinearGradient(colors: [color.withOpacity(0.2), color.withOpacity(0.05)]),
      borderGradient: LinearGradient(colors: [color.withOpacity(0.5), Colors.transparent]),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontFamily: 'IBMPlexSansArabic', color: Colors.black54)),
          const SizedBox(height: 5),
          Text(
            _currencyFormatter.format(amount),
            style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
          const Text("د.ع", style: TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  // --- Widget: قسم رأس المال ---
  Widget _buildCapitalSection() {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 320,
      borderRadius: 20,
      blur: 20,
      alignment: Alignment.center,
      border: 1,
      linearGradient: LinearGradient(
        colors: [Colors.white.withOpacity(0.9), Colors.white.withOpacity(0.6)],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      ),
      borderGradient: LinearGradient(colors: [Colors.white.withOpacity(0.5), Colors.white.withOpacity(0.1)]),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // إدخال رأس المال
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _capitalController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "أدخل رأس المال (مثلاً 250000)",
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.5),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _isLoadingCapital ? null : _setCapital,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: _isLoadingCapital 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("تحديث"),
                ),
              ],
            ),
            
            const Divider(height: 30),

            // عرض المتبقي
            const Text("الميزانية المتوفرة الآن", style: TextStyle(fontFamily: 'IBMPlexSansArabic', color: Colors.grey)),
            Text(
              "${_currencyFormatter.format(_currentCapital)} د.ع",
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: _currentCapital < _alertThreshold ? Colors.red : const Color(0xFF2F3542), // أحمر إذا تحت الحد
              ),
            ),

            const SizedBox(height: 20),

            // السلايدر (Range Slider Logic)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("تنبيه انخفاض الميزانية عند:", style: TextStyle(fontSize: 12)),
                Text("${_currencyFormatter.format(_alertThreshold)} د.ع", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF4757))),
              ],
            ),
            Slider(
              value: _alertThreshold,
              min: 0,
              max: 500000, // نصف مليون كحد أقصى للسلايدر
              divisions: 500, // خطوات كل 1000 دينار (500000 / 500 = 1000)
              activeColor: const Color(0xFFFF4757),
              inactiveColor: Colors.grey.shade300,
              onChanged: (val) {
                _updateThreshold(val);
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- Widget: قسم المدراء ---
  Widget _buildAdminOpsSection() {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 300,
      borderRadius: 20,
      blur: 20,
      alignment: Alignment.center,
      border: 1,
      linearGradient: LinearGradient(
        colors: [const Color(0xFF2F3542).withOpacity(0.05), const Color(0xFF2F3542).withOpacity(0.1)], // لون مختلف قليلاً للتمييز
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      ),
      borderGradient: LinearGradient(colors: [Colors.grey.withOpacity(0.3), Colors.transparent]),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // حالتي
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("حالتي الآن:", style: TextStyle(fontWeight: FontWeight.bold)),
                DropdownButton<String>(
                  value: _myStatus,
                  underline: Container(),
                  items: const [
                    DropdownMenuItem(value: "available", child: Text("🟢 متاح للعمل")),
                    DropdownMenuItem(value: "busy", child: Text("🟠 مشغول")),
                    DropdownMenuItem(value: "away", child: Text("🔴 خارج الخدمة")),
                  ],
                  onChanged: (val) {
                    setState(() => _myStatus = val!);
                    // TODO: Update Admin Doc in Firestore
                  },
                ),
              ],
            ),

            const Divider(height: 20),

            const Align(alignment: Alignment.centerRight, child: Text("تحويل الطلبات (الطوارئ)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red))),
            const SizedBox(height: 10),
            
            // قائمة المدراء (تخيلية من القاعدة)
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('admins').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  
                  // استثناء نفسي من القائمة
                  // var otherAdmins = snapshot.data!.docs.where((doc) => doc.id != myId).toList();
                  // للآن سنعرض مثالاً للكود
                  
                  return ListView(
                    children: [
                      _buildAdminItem("مدير 2 (علي)", "available"),
                      _buildAdminItem("مدير 3 (سارة)", "busy"),
                    ],
                  );
                },
              ),
            ),
            
            // زر فك الشراكة
            if (_forwardToAdminId != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                     setState(() => _forwardToAdminId = null);
                     // Logic to stop forwarding
                  },
                  icon: const Icon(Icons.link_off),
                  label: const Text("استعادة استلام الطلبات (فك التحويل)"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminItem(String name, String status) {
    bool isAvailable = status == "available";
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: isAvailable ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
        child: Icon(Icons.person, color: isAvailable ? Colors.green : Colors.orange),
      ),
      title: Text(name, style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 14)),
      subtitle: Text(isAvailable ? "متاح للاستلام" : "مشغول", style: const TextStyle(fontSize: 10)),
      trailing: ElevatedButton(
        onPressed: isAvailable ? () {
          // Logic to transfer
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("تم تحويل طلباتك إلى $name")));
          setState(() => _forwardToAdminId = "some_id");
        } : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          minimumSize: const Size(60, 30)
        ),
        child: const Text("تحويل لي", style: TextStyle(fontSize: 10)),
      ),
    );
  }
}
