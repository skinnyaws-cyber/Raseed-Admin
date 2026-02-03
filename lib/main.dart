import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // المكتبة الجديدة
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:raseed_admin/screens/onboarding_screen.dart';
import 'package:raseed_admin/screens/home_screen.dart';

// === دالة المعالجة في الخلفية (Background Handler) ===
// يجب أن تكون خارج أي كلاس لتعمل بشكل مستقل عن واجهة التطبيق
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // تهيئة فايربيس هنا ضرورية لأن هذه الدالة تعمل في "عزل" عن التطبيق الرئيسي
  await Firebase.initializeApp();
  print("تم استلام إشعار في الخلفية: ${message.notification?.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); [cite: 58]

  // 1. تهيئة فايربيس (الحل الجذري المعتمد لديك)
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyDNZxvs_hHmb2MWtcw4GLohNKRgPMeDCP4',
      appId: '1:764325356168:ios:c42aa893f53e0cf001753d',
      messagingSenderId: '764325356168',
      projectId: 'raseedapp-b442e',
      iosBundleId: 'com.raseed.admin',
    ),
  ); [cite: 59]

  // 2. ربط دالة الإشعارات في الخلفية
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp()); [cite: 60]
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, [cite: 61]
      title: 'Raseed Admin',
      
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', 'AE'),
      ],
      locale: const Locale('ar', 'AE'), [cite: 62]

      theme: ThemeData(
        fontFamily: 'IBMPlexSansArabic',
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF4757),
          primary: const Color(0xFFFF4757),
          secondary: const Color(0xFF2F3542),
          surface: const Color(0xFFF5F6FA),
        ),
      ), [cite: 63]
      
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          } [cite: 64]
          if (snapshot.hasData && snapshot.data != null) {
            return const HomeScreen();
          } [cite: 65]
          return const OnboardingScreen();
        },
      ), [cite: 66]
    );
  }
}
