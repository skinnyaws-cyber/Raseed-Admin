import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart'; // مكتبة السحب السائل
import 'package:raseed_admin/tabs/orders_tab.dart';
import 'package:raseed_admin/tabs/notifications_tab.dart';
import 'package:raseed_admin/tabs/analytics_tab.dart';
import 'package:raseed_admin/tabs/settings_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // قائمة الواجهات المربوطة
  final List<Widget> _pages = [
    const OrdersTab(),        // 0: الطلبات
    const NotificationsTab(), // 1: الإشعارات
    const AnalyticsTab(),     // 2: الخزنة والإحصائيات
    const SettingsTab(),      // 3: الإعدادات والحساب
  ];

  // دالة تحديث الطلبات (عند السحب)
  Future<void> _handleRefresh() async {
    // هنا نضع منطق تحديث البيانات الحقيقي
    // بما أننا نستخدم StreamBuilder في الواجهات، فالتحديث تلقائي
    // لكن هذا التأخير يعطي وقتاً للمدير للاستمتاع بالأنيميشن :)
    return await Future.delayed(const Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA), // خلفية التطبيق الموحدة
      extendBody: true, // مهم جداً لكي يظهر المحتوى خلف الشريط الزجاجي
      
      // === جسم التطبيق مع ميزة السحب السائل ===
      body: _currentIndex == 0 // تفعيل السحب فقط في صفحة الطلبات
          ? LiquidPullToRefresh(
              onRefresh: _handleRefresh,
              color: const Color(0xFFFF4757), // لون "السائل" الأحمر
              backgroundColor: Colors.white,  // لون الخلفية أثناء السحب
              height: 200, // مدى نزول السائل
              animSpeedFactor: 2, // سرعة الحركة
              showChildOpacityTransition: false,
              child: _pages[_currentIndex],
            )
          : _pages[_currentIndex], // باقي الصفحات بدون سحب

      // === الشريط السفلي العائم الزجاجي (لم يتم تغيير التصميم) ===
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: GlassmorphicContainer(
          width: double.infinity,
          height: 75,
          borderRadius: 40,
          blur: 20,
          alignment: Alignment.center,
          border: 2,
          linearGradient: LinearGradient(
            colors: [
              const Color(0xFF2F3542).withOpacity(0.9),
              const Color(0xFF2F3542).withOpacity(0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderGradient: LinearGradient(
            colors: [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.05)],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(0, Icons.dashboard_rounded, "الطلبات"),
              _buildNavItem(1, Icons.notifications_active_rounded, "تنبيه"),
              _buildNavItem(2, Icons.analytics_rounded, "الخزنة"),
              _buildNavItem(3, Icons.manage_accounts_rounded, "حسابي"),
            ],
          ),
        ),
      ),
    );
  }

  // دالة بناء عناصر الشريط السفلي
  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuad,
        padding: isSelected 
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 12) 
            : const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF4757) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'IBMPlexSansArabic',
                  fontSize: 12,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
