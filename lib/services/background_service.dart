import 'package:flutter/material.dart';

class BackgroundService {
  // Define background themes for different pages
  static const Map<String, BackgroundTheme> themes = {
    'welcome': BackgroundTheme(
      gradientColors: [
        Color(0xFF0F0C29),
        Color(0xFF302B63),
        Color(0xFF24243e),
      ],
      imagePath: 'assets/images/night_sky.png',
      overlayOpacity: 0.7,
    ),
    'sleep': BackgroundTheme(
      gradientColors: [
        Color(0xFF2D3748),
        Color(0xFF4A5568),
        Color(0xFF1A202C),
      ],
      imagePath: 'assets/images/bedroom_night.png',
      overlayOpacity: 0.8,
    ),
    'wake': BackgroundTheme(
      gradientColors: [
        Color(0xFF48BB78),
        Color(0xFF38A169),
        Color(0xFF2F855A),
      ],
      imagePath: 'assets/images/morning_sunrise.png',
      overlayOpacity: 0.6,
    ),
    'completion': BackgroundTheme(
      gradientColors: [
        Color(0xFF667EEA),
        Color(0xFF764BA2),
        Color(0xFF48BB78),
      ],
      imagePath: 'assets/images/peaceful_dawn.png',
      overlayOpacity: 0.7,
    ),
  };

  static Widget buildBackground({
    required String theme,
    required Widget child,
    bool useImage = true,
  }) {
    final backgroundTheme = themes[theme] ?? themes['welcome']!;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: backgroundTheme.gradientColors,
        ),
      ),
      child: useImage ? Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(backgroundTheme.imagePath),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(backgroundTheme.overlayOpacity),
              BlendMode.darken,
            ),
            onError: (exception, stackTrace) {
              // Gracefully handle missing image files
            },
          ),
        ),
        child: child,
      ) : child,
    );
  }

  // Alternative pattern backgrounds for when images are not available
  static Widget buildPatternBackground({
    required String theme,
    required Widget child,
  }) {
    final backgroundTheme = themes[theme] ?? themes['welcome']!;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: backgroundTheme.gradientColors,
        ),
      ),
      child: Stack(
        children: [
          // Subtle pattern overlay
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/subtle_pattern.png'),
                fit: BoxFit.cover,
                opacity: 0.1,
                onError: null,
              ),
            ),
          ),
          // Additional visual elements based on theme
          if (theme == 'welcome') ..._buildStarField(),
          if (theme == 'sleep') ..._buildFloatingElements(),
          if (theme == 'wake') ..._buildSunRays(),
          if (theme == 'completion') ..._buildCelebrationElements(),
          child,
        ],
      ),
    );
  }

  static List<Widget> _buildStarField() {
    return List.generate(50, (index) {
      return Positioned(
        top: (index * 17) % 800.0,
        left: (index * 23) % 400.0,
        child: Container(
          width: 2,
          height: 2,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            shape: BoxShape.circle,
          ),
        ),
      );
    });
  }

  static List<Widget> _buildFloatingElements() {
    return List.generate(20, (index) {
      return Positioned(
        top: (index * 40) % 800.0,
        left: (index * 30) % 400.0,
        child: Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
        ),
      );
    });
  }

  static List<Widget> _buildSunRays() {
    return List.generate(8, (index) {
      return Positioned(
        top: 100,
        right: 50,
        child: Transform.rotate(
          angle: (index * 0.785), // 45 degrees in radians
          child: Container(
            width: 2,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.yellow.withOpacity(0.3),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
      );
    });
  }

  static List<Widget> _buildCelebrationElements() {
    return List.generate(30, (index) {
      return Positioned(
        top: (index * 25) % 800.0,
        left: (index * 15) % 400.0,
        child: Container(
          width: 3,
          height: 3,
          decoration: BoxDecoration(
            color: [
              Colors.yellow.withOpacity(0.4),
              Colors.orange.withOpacity(0.4),
              Colors.pink.withOpacity(0.4),
            ][index % 3],
            shape: BoxShape.circle,
          ),
        ),
      );
    });
  }
}

class BackgroundTheme {
  final List<Color> gradientColors;
  final String imagePath;
  final double overlayOpacity;

  const BackgroundTheme({
    required this.gradientColors,
    required this.imagePath,
    this.overlayOpacity = 0.7,
  });
}
