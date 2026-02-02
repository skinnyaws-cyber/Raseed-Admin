import 'package:flutter/material.dart';
// تم إزالة مكتبات السحب والزجاج لزيادة الأداء 
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
  
  // متحكم لأنيميشن الأيقونة (من 3 خطوط إلى نجمة)
  bool _isDrawerOpen = false;

  // القائمة أصبحت 3 تبويبات فقط، والإعدادات انتقلت للقائمة الجانبية 
  final List<Widget> _pages = [
    const OrdersTab(),        
    const NotificationsTab(), 
    const AnalyticsTab(),     
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF5F6FA),
      
      // === 1. الشريط العلوي الرصين (AppBar) ===
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5, // ظل خفيف جداً لإعطاء عمق جاد
        centerTitle: true,
        // أيقونة القائمة المتحولة
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
                ? const Icon(Icons.emergency_rounded, color: Color(0xFFFF4757), key: ValueKey('icon2')) // شكل النجمة *
                : const Icon(Icons.menu_rounded, color: Color(0xFF2F3542), key: ValueKey('icon1')), // 3 خطوط
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
          // عدسة البحث للمستقبل
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Color(0xFF2F3542)),
            onPressed: () {
              // منطق البحث مستقبلاً
            },
          ),
        ],
      ),

      // === 2. القائمة الجانبية (Drawer) لتقليل الفراغات وتضمين الإعدادات ===
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
                // التوجه لواجهة الإعدادات
                Navigator.pop(context);
                // هنا نفتح الـ SettingsTab كشاشة كاملة
              },
            ),
          ],
        ),
      ),

      // === 3. جسم التطبيق (تم إزالة السحب السائل لزيادة السلاسة) [cite: 7] ===
      body: _pages[_currentIndex],

      // === 4. الشريط السفلي الصلب (بدون زجاج) [cite: 9, 10] ===
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
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, [cite: 11]
          children: [
            _buildNavItem(0, Icons.dashboard_rounded, "الطلبات"), [cite: 11]
            _buildNavItem(1, Icons.notifications_active_rounded, "تنبيه"), [cite: 11]
            _buildNavItem(2, Icons.analytics_rounded, "الخزنة"), [cite: 11]
          ],
        ),
      ),
    );
  }

  // دالة بناء العناصر (تم تبسيط الحواف والظلال لتكون أكثر جدية) [cite: 14, 15]
  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index), [cite: 14]
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF4757).withOpacity(0.1) : Colors.transparent, // خلفية بسيطة جداً
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFFFF4757) : const Color(0xFF2F3542).withOpacity(0.5), [cite: 15]
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFFFF4757) : const Color(0xFF2F3542).withOpacity(0.5), [cite: 17]
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
