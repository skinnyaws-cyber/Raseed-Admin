import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // المكتبة المطلوبة للإشعارات
import 'package:raseed_admin/tabs/orders_tab.dart';
import 'package:raseed_admin/tabs/notifications_tab.dart';
import 'package:raseed_admin/tabs/analytics_tab.dart';
import 'package:raseed_admin/tabs/settings_tab.dart'; 

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
    // استدعاء دالة تهيئة الإشعارات عند بدء تشغيل الواجهة
    _setupNotifications();
  }

  // === دالة تهيئة الإشعارات وطلب الأذونات ===
  Future<void> _setupNotifications() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // 1. طلب إذن الإشعارات (ضروري جداً لنظام iOS)
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // 2. الحصول على الـ Token الفريد لهذا الجهاز
      String? token = await messaging.getToken();
      // ملاحظة: سنحتاج لطباعة هذا الـ Token لاحقاً لربطه في Firebase Console
      debugPrint("Device FCM Token: $token");
    }

    // 3. الاستماع للإشعارات أثناء فتح التطبيق (Foreground)
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
        elevation: 0.5, [cite: 53]
        centerTitle: true,
        leading: IconButton(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300), [cite: 54]
            transitionBuilder: (child, anim) => RotationTransition(
              turns: child.key == const ValueKey('icon1') 
                ? Tween<double>(begin: 1, end: 0.75).animate(anim) 
                : Tween<double>(begin: 0.75, end: 1).animate(anim), [cite: 54, 55]
              child: ScaleTransition(scale: anim, child: child),
            ),
            child: _isDrawerOpen
                ? const Icon(Icons.emergency_rounded, color: Color(0xFFFF4757), key: ValueKey('icon2')) [cite: 55]
                : const Icon(Icons.menu_rounded, color: Color(0xFF2F3542), key: ValueKey('icon1')), [cite: 55, 56]
          ),
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer(); [cite: 56]
          },
        ),
        title: const Text(
          "رصيد آدمن",
          style: TextStyle(
            color: Color(0xFF2F3542),
            fontFamily: 'IBMPlexSansArabic',
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ), [cite: 57, 58]
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Color(0xFF2F3542)), [cite: 59]
            onPressed: () {},
          ),
        ],
      ),

      onDrawerChanged: (isOpen) => setState(() => _isDrawerOpen = isOpen), [cite: 59]
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFFF5F6FA)), [cite: 60]
              child: Center(
                child: Text("إدارة رصيد", style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontWeight: FontWeight.bold)),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings_suggest_rounded, color: Color(0xFFFF4757)), [cite: 61]
              title: const Text("الإعدادات العامة", style: TextStyle(fontFamily: 'IBMPlexSansArabic')),
              onTap: () {
                Navigator.pop(context); [cite: 61]
              },
            ),
          ],
        ),
      ),

      body: _pages[_currentIndex], [cite: 62]

      bottomNavigationBar: Container(
        height: 70, [cite: 63]
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5), [cite: 63, 64]
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, [cite: 64]
          children: [
            _buildNavItem(0, Icons.dashboard_rounded, "الطلبات"), [cite: 64]
            _buildNavItem(1, Icons.notifications_active_rounded, "تنبيه"), [cite: 64]
            _buildNavItem(2, Icons.analytics_rounded, "الخزنة"), [cite: 65]
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _currentIndex == index; [cite: 66]
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index), [cite: 67]
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200), [cite: 67]
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF4757).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12), [cite: 67]
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFFFF4757) : const Color(0xFF2F3542).withOpacity(0.5), [cite: 68]
              size: 26,
            ),
            const SizedBox(height: 4), [cite: 69]
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFFFF4757) : const Color(0xFF2F3542).withOpacity(0.5), [cite: 69]
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, [cite: 69, 70]
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
