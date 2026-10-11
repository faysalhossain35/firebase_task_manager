import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';

class FirebaseTaskManager extends StatelessWidget {
  const FirebaseTaskManager({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Task Manager',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF3F4F7),
        fontFamily: 'SF Pro Display',
        textTheme: const TextTheme(
          titleLarge: TextStyle(color: Color(0xFF1D2433)),
          bodyLarge: TextStyle(color: Color(0xFF1D2433)),
          bodyMedium: TextStyle(color: Color(0xFF1D2433)),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
