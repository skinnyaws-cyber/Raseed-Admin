import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:raseed_admin/tabs/orders_tab.dart'; // سننشئه بالأسفل
// import 'package:raseed_admin/tabs/notifications_tab.dart'; // لاحقاً
// import 'package:raseed_admin/tabs/analytics_tab.dart'; // لاحقاً

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // قائمة الواجهات (سنضيف البقية تدريجياً)
  final List<Widget> _pages = [
    const OrdersTab(),         // 0: الطلبات (الرئيسية)
    const Center(child: Text("Notifications Page")), // 1: الإشعارات (مؤقت)
    const Center(child: Text("Analytics Page")),     // 2: الإحصائيات ورأس المال (مؤقت)
    const Center(child: Text("Settings Page")),      // 3: الإعدادات والمدراء (مؤقت)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA), // خلفية موحدة
      extendBody: true, // للسماح للمحتوى بالظهور خلف الشريط الزجاجي
      body: _pages[_currentIndex],
      
      // === الشريط السفلي العائم الزجاجي ===
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20), // مسافة من الأسفل والجوانب ليكون عائماً
        child: GlassmorphicContainer(
          width: double.infinity,
          height: 75,
          borderRadius: 40, // حواف دائرية بالكامل
          blur: 20,
          alignment: Alignment.center,
          border: 2,
          linearGradient: LinearGradient(
            colors: [
              const Color(0xFF2F3542).withOpacity(0.9), // لون داكن فخم للشريط
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
              _buildNavItem(3, Icons.manage_accounts_rounded, "المدراء"),
            ],
          ),
        ),
      ),
    );
  }

  // دالة لبناء أيقونات الشريط بتفاعل Bubble
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
          color: isSelected ? const Color(0xFFFF4757) : Colors.transparent, // الفقاعة الحمراء عند التحديد
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
