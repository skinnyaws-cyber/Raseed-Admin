import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; 
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
    _setupNotifications();
  }

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
                ? Tween<double>(begin: 1, end: 0.75).animate(anim) 
                : Tween<double>(begin: 0.75, end: 1).animate(anim),
              child: ScaleTransition(scale: anim, child: child),
            ),
            child: _isDrawerOpen
                ? const Icon(Icons.emergency_rounded, color: Color(0xFFFF4757), key: ValueKey('icon2'))
                : const Icon(Icons.menu_rounded, color: Color(0xFF2F3542), key: ValueKey('icon1')),
          ),
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
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
            onPressed: () {},
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
                Navigator.pop(context);
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
