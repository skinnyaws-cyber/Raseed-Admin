import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // مكتبة المصادقة
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:raseed_admin/screens/onboarding_screen.dart';
import 'package:raseed_admin/screens/home_screen.dart'; // الواجهة الرئيسية

void main() async {
  // ضمان تهيئة مكونات فلاتر قبل تشغيل التطبيق
  WidgetsFlutterBinding.ensureInitialized();
  
  // تهيئة فايربيس
  await Firebase.initializeApp();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // إخفاء شريط Debug
      title: 'Raseed Admin',
      
      // === إعدادات اللغة العربية ===
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', 'AE'), // اللغة العربية هي الأساس
      ],
      locale: const Locale('ar', 'AE'), // إجبار التطبيق على البدء بالعربية

      // === إعدادات الثيم والتصميم ===
      theme: ThemeData(
        fontFamily: 'IBMPlexSansArabic', // الخط الرسمي للتطبيق
        useMaterial3: true,
        
        // الألوان الأساسية
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF4757), // اللون الأحمر الأساسي
          primary: const Color(0xFFFF4757),
          secondary: const Color(0xFF2F3542),
          surface: const Color(0xFFF5F6FA), // لون الخلفيات الفاتح
        ),
        
        // تخصيص النصوص الافتراضية
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'IBMPlexSansArabic', fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(fontFamily: 'IBMPlexSansArabic'),
          labelLarge: TextStyle(fontFamily: 'IBMPlexSansArabic'),
        ),
        
        // ثيم الأزرار
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF4757),
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontWeight: FontWeight.bold),
          ),
        ),
      ),
      
      // === نقطة البداية الذكية (Smart Router) ===
      // هذا الكود يفحص: هل المستخدم مسجل دخول أم لا؟
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // 1. إذا كان هناك بيانات مستخدم (مسجل دخول) -> اذهب للرئيسية فوراً
          if (snapshot.hasData && snapshot.data != null) {
            return const HomeScreen();
          }
          
          // 2. إذا لم يكن مسجلاً -> ابدأ من الترحيب
          return const OnboardingScreen();
        },
      ),
    );
  }
}
