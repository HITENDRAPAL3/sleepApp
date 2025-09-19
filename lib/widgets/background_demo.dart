import 'package:flutter/material.dart';
import '../services/background_service.dart';

class BackgroundDemo extends StatelessWidget {
  const BackgroundDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Background Themes Demo'),
        backgroundColor: const Color(0xFF2D3748),
      ),
      body: PageView(
        children: [
          _buildThemeDemo('welcome', 'Welcome Page Theme', 
              'Dark night sky with animated stars'),
          _buildThemeDemo('sleep', 'Sleep Timer Theme', 
              'Calming evening with floating particles'),
          _buildThemeDemo('wake', 'Wake Timer Theme', 
              'Energizing morning with sun rays'),
          _buildThemeDemo('completion', 'Completion Theme', 
              'Celebratory success with colorful particles'),
        ],
      ),
    );
  }

  Widget _buildThemeDemo(String theme, String title, String description) {
    return BackgroundService.buildPatternBackground(
      theme: theme,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Swipe left to see other themes',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Usage: Add this route to main.dart for testing backgrounds
// '/demo': (context) => const BackgroundDemo(),
