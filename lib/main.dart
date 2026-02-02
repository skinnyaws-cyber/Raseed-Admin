import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:raseed_admin/screens/onboarding_screen.dart';
import 'package:raseed_admin/screens/home_screen.dart';

void main() async {
  // ضمان تهيئة مكونات فلاتر
  WidgetsFlutterBinding.ensureInitialized();
  
  // تهيئة فايربيس يدوياً (الحل الجذري لنسخ TrollStore)
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyDNZxvs_hHmb2MWtcw4GLohNKRgPMeDCP4',
      appId: '1:764325356168:ios:c42aa893f53e0cf001753d',
      messagingSenderId: '764325356168',
      projectId: 'raseedapp-b442e',
      iosBundleId: 'com.raseed.admin', // المعرف الذي وضعناه في Info.plist
    ),
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Raseed Admin',
      
      // إعدادات اللغة العربية
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
      
      // فحص حالة المستخدم
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasData && snapshot.data != null) {
            return const HomeScreen();
          }
          return const OnboardingScreen();
        },
      ),
    );
  }
}
