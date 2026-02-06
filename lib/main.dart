import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; 
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart'; // إضافة ضرورية
import 'package:raseed_admin/screens/onboarding_screen.dart';
import 'package:raseed_admin/screens/home_screen.dart';

// === دالة المعالجة في الخلفية (Background Handler) - لم تتغير ===
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("تم استلام إشعار في الخلفية: ${message.notification?.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. تهيئة فايربيس بالإعدادات الرسمية - لم تتغير
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyDNZxvs_hHmb2MWtcw4GLohNKRgPMeDCP4',
      appId: '1:764325356168:ios:c42aa893f53e0cf001753d',
      messagingSenderId: '764325356168',
      projectId: 'raseedapp-b442e',
      iosBundleId: 'com.raseed.admin',
    ),
  );

  // 2. منطق تصفير الجلسة عند أول تثبيت (الحل البرمجي)
  final prefs = await SharedPreferences.getInstance();
  bool isFirstRun = prefs.getBool('is_first_run') ?? true;

  if (isFirstRun) {
    // تسجيل خروج إجباري لمسح مخلفات النظام السابقة
    await FirebaseAuth.instance.signOut();
    await prefs.setBool('is_first_run', false);
  }

  // 3. ربط دالة الإشعارات في الخلفية - لم تتغير
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Raseed Admin',
      
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', 'AE'),
      ],
      locale: const Locale('ar', 'AE'),

      theme: ThemeData(
        fontFamily: 'IBMPlexSansArabic',
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF4757),
          primary: const Color(0xFFFF4757),
          secondary: const Color(0xFF2F3542),
          surface: const Color(0xFFF5F6FA),
        ),
      ),
      
      // منطق التوجيه التلقائي مع StreamBuilder - لم يتغير
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          // إذا وجد مستخدم (ولم نكن في أول تشغيل) يفتح HomeScreen
          if (snapshot.hasData && snapshot.data != null) {
            return const HomeScreen();
          }
          // غير ذلك يفتح OnboardingScreen كما تريد
          return const OnboardingScreen();
        },
      ),
    );
  }
}
