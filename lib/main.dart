import 'package:flutter/material.dart';
import 'screens/welcome_page.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notification service
  await NotificationService.initialize();

  runApp(const SleepCycleApp());
}

class SleepCycleApp extends StatelessWidget {
  const SleepCycleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sleep Cycle Improvement',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D3748), // Dark blue-gray
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF1A202C),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2D3748),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4A90E2),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF2D3748),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          headlineMedium: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: TextStyle(
            color: Colors.white70,
            fontSize: 16,
            height: 1.5,
          ),
          bodyMedium: TextStyle(
            color: Colors.white60,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ),
      home: const WelcomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}