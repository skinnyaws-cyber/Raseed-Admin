import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; 
import 'package:raseed_admin/tabs/orders_tab.dart';
import 'package:raseed_admin/tabs/notifications_tab.dart';
import 'package:raseed_admin/tabs/analytics_tab.dart';
import 'package:raseed_admin/tabs/settings_tab.dart';
import 'package:raseed_admin/screens/order_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isDrawerOpen = false;

  final List<Widget> _pages = [
    const OrdersTab(),        
    const NotificationsTab(), 
    const AnalyticsTab(),     
  ];

  @override
  void initState() {
    super.initState();
    _setupNotifications(); // تهيئة إشعارات التطبيق [cite: 179-180]
  }

  // إعداد استقبال الإشعارات في المقدمة والخلفية [cite: 180-184]
  Future<void> _setupNotifications() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token = await messaging.getToken();
      debugPrint("Device FCM Token: $token");
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "${message.notification!.title}: ${message.notification!.body}",
              style: const TextStyle(fontFamily: 'IBMPlexSansArabic'),
            ),
            backgroundColor: const Color(0xFFFF4757),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF5F6FA),
      
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) => RotationTransition(
              turns: child.key == const ValueKey('icon1') 
                ? Tween<double>(begin: 0, end: 1).animate(anim) 
                : Tween<double>(begin: 1, end: 0).animate(anim),
              child: ScaleTransition(scale: anim, child: child),
            ),
            child: _isDrawerOpen
                ? const Icon(Icons.emergency_rounded, color: Color(0xFFFF4757), key: ValueKey('icon2'))
                : const Icon(Icons.menu_rounded, color: Color(0xFF2F3542), key: ValueKey('icon1')),
          ),
          onPressed: () => _scaffoldKey.currentState!.openDrawer(),
        ),
        title: const Text(
          "رصيد آدمن",
          style: TextStyle(
            color: Color(0xFF2F3542),
            fontFamily: 'IBMPlexSansArabic',
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Color(0xFF2F3542)),
            onPressed: () {
              // تفعيل واجهة البحث الاحترافية
              showSearch(
                context: context,
                delegate: OrderSearchDelegate(),
              );
            },
          ),
        ],
      ),

      onDrawerChanged: (isOpen) => setState(() => _isDrawerOpen = isOpen),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFFF5F6FA)),
              child: Center(
                child: Text("إدارة رصيد", style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontWeight: FontWeight.bold)),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings_suggest_rounded, color: Color(0xFFFF4757)),
              title: const Text("الإعدادات العامة", style: TextStyle(fontFamily: 'IBMPlexSansArabic')),
              onTap: () {
                Navigator.pop(context); // إغلاق القائمة الجانبية [cite: 194-195]
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsTab()),
                );
              },
            ),
          ],
        ),
      ),

      body: _pages[_currentIndex],

      bottomNavigationBar: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(0, Icons.dashboard_rounded, "الطلبات"),
            _buildNavItem(1, Icons.notifications_active_rounded, "تنبيه"),
            _buildNavItem(2, Icons.analytics_rounded, "الخزنة"),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF4757).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFFFF4757) : const Color(0xFF2F3542).withOpacity(0.5),
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFFFF4757) : const Color(0xFF2F3542).withOpacity(0.5),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// === محرك البحث الخاص بالطلبات (مع إصلاح نوع البيانات) ===
class OrderSearchDelegate extends SearchDelegate {
  @override
  String get searchFieldLabel => "ابحث باسم المستخدم...";

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear_rounded),
        onPressed: () => query = "",
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_new_rounded),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults();

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(
        child: Text("ابدأ بكتابة اسم العميل للبحث", style: TextStyle(fontFamily: 'IBMPlexSansArabic', color: Colors.grey)),
      );
    }
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('userFullName', isGreaterThanOrEqualTo: query)
          .where('userFullName', isLessThanOrEqualTo: query + '\uf8ff')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        var results = snapshot.data!.docs;

        if (results.isEmpty) {
          return const Center(child: Text("لا توجد نتائج مطابقة", style: TextStyle(fontFamily: 'IBMPlexSansArabic')));
        }

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            var doc = results[index];
            var data = doc.data() as Map<String, dynamic>;

            return ListTile(
              title: Text(data['userFullName'] ?? "بدون اسم", style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'IBMPlexSansArabic')),
              subtitle: Text("${data['amount']} د.ع - ${data['status']}", style: const TextStyle(fontSize: 12)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              onTap: () {
                // الحل: تمرير الـ QueryDocumentSnapshot مباشرة لحل خطأ Type Mismatch
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OrderDetailsScreen(order: doc)),
                );
              },
            );
          },
        );
      },
    );
  }
}
