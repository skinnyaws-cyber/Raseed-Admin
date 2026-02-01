import 'package:flutter/material.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          "Sign Up Page",
          style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 24),
        ),
      ),
    );
  }
}
