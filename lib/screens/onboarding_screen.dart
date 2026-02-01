import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // تأكد أنك أضفت المكتبة أو استخدم الخط المحلي
import 'package:raseed_admin/screens/signup_screen.dart'; // سننشئ هذه الصفحة لاحقاً

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  // متحكمات الأنيميشن
  late AnimationController _introController; // لظهور الشمس بدايةً
  late AnimationController _exitController;  // للخروج عند ضغط الزر

  late Animation<Offset> _cloudLeftMove;
  late Animation<Offset> _cloudRightMove;
  late Animation<Offset> _sunMove;
  late Animation<double> _textFade;
  
  @override
  void initState() {
    super.initState();

    // 1. إعداد أنيميشن الدخول (الغيوم تبتعد قليلاً لتظهر الشمس)
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // 2. إعداد أنيميشن الخروج (الغيوم تختفي والشمس تهبط)
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // الغيوم تبدأ من المنتصف وتنزاح قليلاً في البداية
    _cloudLeftMove = Tween<Offset>(
      begin: const Offset(0.2, 0), // تبدأ متداخلة قليلاً
      end: const Offset(-0.3, 0),  // تنزاح لليسار قليلاً
    ).animate(CurvedAnimation(parent: _introController, curve: Curves.easeInOut));

    _cloudRightMove = Tween<Offset>(
      begin: const Offset(-0.2, 0),
      end: const Offset(0.3, 0),
    ).animate(CurvedAnimation(parent: _introController, curve: Curves.easeInOut));

    // النص يظهر ببطء
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _introController, curve: const Interval(0.5, 1.0)),
    );

    // تشغيل الافتتاحية
    _introController.forward();
  }

  @override
  void dispose() {
    _introController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  // دالة الخروج عند ضغط الزر
  void _onReadyPressed() async {
    // 1. تشغيل أنيميشن الخروج
    await _exitController.forward();
    
    // 2. الانتقال لصفحة التسجيل
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const SignUpScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // تعريف أنيميشن الخروج السريع (Override)
    // عند الخروج: الغيمة اليسرى تذهب لأقصى اليسار
    final exitLeft = Tween<Offset>(begin: Offset.zero, end: const Offset(-2.0, 0))
        .animate(CurvedAnimation(parent: _exitController, curve: Curves.easeInOutBack));
    
    // عند الخروج: الغيمة اليمنى تذهب لأقصى اليمين
    final exitRight = Tween<Offset>(begin: Offset.zero, end: const Offset(2.0, 0))
        .animate(CurvedAnimation(parent: _exitController, curve: Curves.easeInOutBack));

    // عند الخروج: الشمس تهبط للأسفل
    final exitSun = Tween<Offset>(begin: Offset.zero, end: const Offset(0, 3.0))
        .animate(CurvedAnimation(parent: _exitController, curve: Curves.easeInOut));

    return Scaffold(
      backgroundColor: const Color(0xFF87CEEB), // لون السماء الأزرق السماوي
      body: Stack(
        alignment: Alignment.center,
        children: [
          
          // === 1. الشمس (The Sun) ===
          SlideTransition(
            position: exitSun, // تتأثر فقط بالخروج
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.yellow,
                boxShadow: [
                  BoxShadow(color: Colors.orange.withOpacity(0.5), blurRadius: 40, spreadRadius: 10),
                  BoxShadow(color: Colors.yellowAccent.withOpacity(0.8), blurRadius: 20, spreadRadius: 5),
                ],
              ),
            ),
          ),

          // === 2. الغيمة اليسرى (Left Cloud) ===
          SlideTransition(
            position: exitLeft, // أنيميشن الخروج
            child: SlideTransition(
              position: _cloudLeftMove, // أنيميشن الدخول
              child: Align(
                alignment: Alignment.centerLeft,
                child: Transform.scale(
                  scale: 2.5,
                  child: const Icon(Icons.cloud, color: Colors.white, size: 200),
                  // ملاحظة: استبدل Icon بـ Image.asset('assets/images/cloud_left.png') لاحقاً
                ),
              ),
            ),
          ),

          // === 3. الغيمة اليمنى (Right Cloud) ===
          SlideTransition(
            position: exitRight,
            child: SlideTransition(
              position: _cloudRightMove,
              child: Align(
                alignment: Alignment.centerRight,
                child: Transform.scale(
                  scale: 2.8,
                  child: const Icon(Icons.cloud, color: Colors.white, size: 200),
                  // استبدل Icon بـ Image.asset('assets/images/cloud_right.png') لاحقاً
                ),
              ),
            ),
          ),

          // === 4. النصوص والزر (UI Layer) ===
          FadeTransition(
            opacity: _textFade, // يظهر بعد انقشاع الغيوم
            child: AnimatedBuilder(
              animation: _exitController,
              builder: (context, child) {
                // يختفي عند الخروج
                return Opacity(
                  opacity: 1.0 - _exitController.value,
                  child: child,
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // جملة الترحيب
                    Text(
                      "أهلاً بك أيها المدير",
                      style: TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 2))
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "هل أنت جاهز للبدء؟",
                      style: TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        fontSize: 18,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 50),

                    // === زر الفقاعة الأحمر (Red Bubble Button) ===
                    GestureDetector(
                      onTap: _onReadyPressed,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF4757), // أحمر حيوي
                          borderRadius: BorderRadius.circular(50), // حواف دائرية كاملة (Bubble)
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF4757).withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                            BoxShadow(
                              color: Colors.white.withOpacity(0.2),
                              blurRadius: 5,
                              offset: const Offset(0, -2), // إضاءة علوية لتعطي تجسيم
                            ),
                          ],
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFFF6B81), // أحمر فاتح
                              Color(0xFFFF4757), // أحمر غامق
                            ],
                          ),
                        ),
                        child: const Text(
                          "أنا جاهز",
                          style: TextStyle(
                            fontFamily: 'IBMPlexSansArabic',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
