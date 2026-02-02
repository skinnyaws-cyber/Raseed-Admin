import 'package:flutter/material.dart';
import 'package:raseed_admin/screens/signup_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  // متحكمات الحركة
  late AnimationController _introController; 
  late AnimationController _exitController;  

  // المتغيرات التي كانت تسبب الشاشة البيضاء (تمت تهيئتها جميعاً)
  late Animation<Offset> _cloudLeftMove;
  late Animation<Offset> _cloudRightMove;
  late Animation<Offset> _sunMove;
  late Animation<double> _textFade;
  
  @override
  void initState() {
    super.initState();

    // 1. إعداد المتحكمات
    _introController = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _exitController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));

    // 2. حركة دخول الغيوم (تنزاح قليلاً لتكشف الوسط)
    _cloudLeftMove = Tween<Offset>(
      begin: const Offset(0.1, 0), 
      end: const Offset(-0.4, 0),
    ).animate(CurvedAnimation(parent: _introController, curve: Curves.easeInOut));

    _cloudRightMove = Tween<Offset>(
      begin: const Offset(-0.1, 0),
      end: const Offset(0.4, 0),
    ).animate(CurvedAnimation(parent: _introController, curve: Curves.easeInOut));

    // 3. حركة ظهور الشمس (ترتفع قليلاً لتستقر في الوسط)
    _sunMove = Tween<Offset>(
      begin: const Offset(0, 0.2), 
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _introController, curve: Curves.easeOutBack));

    // 4. ظهور النصوص بتأثير Fade
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _introController, curve: const Interval(0.6, 1.0)),
    );

    // بدء العرض الافتتاحي
    _introController.forward();
  }

  @override
  void dispose() {
    _introController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  void _onReadyPressed() async {
    // تشغيل أنيميشن الخروج (انسحاب الغيوم وهبوط الشمس)
    await _exitController.forward();
    
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
    // إعدادات حركة الخروج (الانسحاب الكلي)
    final exitLeft = Tween<Offset>(begin: Offset.zero, end: const Offset(-2.5, 0))
        .animate(CurvedAnimation(parent: _exitController, curve: Curves.easeInOutCubic));
    
    final exitRight = Tween<Offset>(begin: Offset.zero, end: const Offset(2.5, 0))
        .animate(CurvedAnimation(parent: _exitController, curve: Curves.easeInOutCubic));

    final exitSun = Tween<Offset>(begin: Offset.zero, end: const Offset(0, 4.0))
        .animate(CurvedAnimation(parent: _exitController, curve: Curves.easeInOutExpo));

    return Scaffold(
      backgroundColor: const Color(0xFF87CEEB), // لون السماء
      body: Stack(
        alignment: Alignment.center,
        children: [
          // === 1. الشمس (The Sun) ===
          SlideTransition(
            position: exitSun,
            child: SlideTransition(
              position: _sunMove,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.yellow,
                  boxShadow: [
                    BoxShadow(color: Colors.orange.withOpacity(0.6), blurRadius: 50, spreadRadius: 20),
                    BoxShadow(color: Colors.yellowAccent.withOpacity(0.4), blurRadius: 20, spreadRadius: 10),
                  ],
                ),
              ),
            ),
          ),

          // === 2. الغيوم الكثيفة ===
          // الغيمة اليسرى
          SlideTransition(
            position: exitLeft,
            child: SlideTransition(
              position: _cloudLeftMove,
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Icon(Icons.cloud, color: Colors.white, size: 350),
              ),
            ),
          ),

          // الغيمة اليمنى
          SlideTransition(
            position: exitRight,
            child: SlideTransition(
              position: _cloudRightMove,
              child: const Align(
                alignment: Alignment.centerRight,
                child: Icon(Icons.cloud, color: Colors.white, size: 400),
              ),
            ),
          ),

          // === 3. واجهة النصوص والزر ===
          FadeTransition(
            opacity: _textFade,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 80),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    "أهلاً بك أيها المدير",
                    style: TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [Shadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 3))],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 60),

                  // === زر الفقاعة الأحمر (Bubble Button) ===
                  GestureDetector(
                    onTap: _onReadyPressed,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B81), Color(0xFFFF4757)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF4757).withOpacity(0.5),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Text(
                        "I'm ready",
                        style: TextStyle(
                          fontFamily: 'IBMPlexSansArabic',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
