import 'package:flutter/material.dart';
import 'pages/welcome_page.dart';
import 'pages/sleep_timer_page.dart';
import 'pages/wake_timer_page.dart';
import 'pages/completion_page.dart';

void main() {
  runApp(const SleepCycleApp());
}

class SleepCycleApp extends StatelessWidget {
  const SleepCycleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sleep Cycle',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        fontFamily: 'Roboto',
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2D3748),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4A5568),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomePage(),
        '/sleep-timer': (context) => const SleepTimerPage(),
        '/wake-timer': (context) => const WakeTimerPage(),
        '/completion': (context) => const CompletionPage(),
      },
    );
  }
}
