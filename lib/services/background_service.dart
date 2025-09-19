import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class BackgroundService {
  static final Random _random = Random();

  // Keys for storing background indices in SharedPreferences
  static const String _welcomeIndexKey = 'welcome_bg_index';
  static const String _nightIndexKey = 'night_bg_index';
  static const String _morningIndexKey = 'morning_bg_index';
  static const String _completionIndexKey = 'completion_bg_index';

  /// Background images for Welcome Page (inspirational/peaceful themes)
  static const List<String> _welcomeBackgrounds = [
    'images/backgrounds/welcome_sunset.jpg',
    'images/backgrounds/welcome_mountains.jpg',
    'images/backgrounds/welcome_forest.jpg',
    'images/backgrounds/welcome_clouds.jpg',
    'images/backgrounds/welcome_lake.jpg',
  ];

  /// Background images for Night Timer Page (evening/night themes)
  static const List<String> _nightBackgrounds = [
    'images/backgrounds/night_stars.jpg',
    'images/backgrounds/night_moon.jpg',
    'images/backgrounds/night_aurora.jpg',
    'images/backgrounds/night_cityscape.jpg',
    'images/backgrounds/night_forest.jpg',
  ];

  /// Background images for Morning Timer Page (dawn/morning themes)
  static const List<String> _morningBackgrounds = [
    'images/backgrounds/morning_sunrise.jpg',
    'images/backgrounds/morning_meadow.jpg',
    'images/backgrounds/morning_beach.jpg',
    'images/backgrounds/morning_mountains.jpg',
    'images/backgrounds/morning_garden.jpg',
  ];

  /// Background images for Completion Page (achievement/success themes)
  static const List<String> _completionBackgrounds = [
    'images/backgrounds/completion_celebration.jpg',
    'images/backgrounds/completion_victory.jpg',
    'images/backgrounds/completion_peaceful.jpg',
    'images/backgrounds/completion_nature.jpg',
    'images/backgrounds/completion_zen.jpg',
  ];

  /// Fallback gradient colors if images are not available
  static const List<List<int>> _fallbackGradients = [
    [0xFF1A202C, 0xFF2D3748, 0xFF4A90E2], // Welcome - deep blue
    [0xFF2D1B69, 0xFF11998E, 0xFF38EF7D], // Night - purple to teal
    [0xFFFF9A9E, 0xFFFFAD0F, 0xFFFF6B95], // Morning - warm sunrise
    [0xFF667EEA, 0xFF764BA2, 0xFF6B73FF], // Completion - celebration purple
  ];

  /// Get next background for Welcome Page (cycles through list)
  static Future<String> getWelcomeBackground() async {
    return await _getNextBackground(_welcomeBackgrounds, _welcomeIndexKey);
  }

  /// Get next background for Night Timer Page (cycles through list)
  static Future<String> getNightBackground() async {
    return await _getNextBackground(_nightBackgrounds, _nightIndexKey);
  }

  /// Get next background for Morning Timer Page (cycles through list)
  static Future<String> getMorningBackground() async {
    return await _getNextBackground(_morningBackgrounds, _morningIndexKey);
  }

  /// Get next background for Completion Page (cycles through list)
  static Future<String> getCompletionBackground() async {
    return await _getNextBackground(_completionBackgrounds, _completionIndexKey);
  }

  /// Internal method to get next background and update index
  static Future<String> _getNextBackground(List<String> backgrounds, String indexKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int currentIndex = prefs.getInt(indexKey) ?? 0;

      // Get the background at current index
      String background = backgrounds[currentIndex];

      // Move to next index (cycle back to 0 if at end)
      int nextIndex = (currentIndex + 1) % backgrounds.length;
      await prefs.setInt(indexKey, nextIndex);

      return background;
    } catch (e) {
      // Fallback to random if SharedPreferences fails
      return backgrounds[_random.nextInt(backgrounds.length)];
    }
  }

  /// Get fallback gradient colors for a specific page
  static List<int> getFallbackGradient(BackgroundType type) {
    switch (type) {
      case BackgroundType.welcome:
        return _fallbackGradients[0];
      case BackgroundType.night:
        return _fallbackGradients[1];
      case BackgroundType.morning:
        return _fallbackGradients[2];
      case BackgroundType.completion:
        return _fallbackGradients[3];
    }
  }

  /// Get all backgrounds for a specific page (useful for debugging)
  static List<String> getAllBackgrounds(BackgroundType type) {
    switch (type) {
      case BackgroundType.welcome:
        return List.from(_welcomeBackgrounds);
      case BackgroundType.night:
        return List.from(_nightBackgrounds);
      case BackgroundType.morning:
        return List.from(_morningBackgrounds);
      case BackgroundType.completion:
        return List.from(_completionBackgrounds);
    }
  }

  /// Check if background image exists (for development)
  static Future<bool> backgroundExists(String path) async {
    try {
      // This is a placeholder - in a real app you might want to check
      // if the asset exists before using it
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Generate a seed-based background (consistent per day)
  static String getDailyBackground(BackgroundType type) {
    final now = DateTime.now();
    final seed = now.year * 1000 + now.month * 100 + now.day;
    final random = Random(seed);

    switch (type) {
      case BackgroundType.welcome:
        return _welcomeBackgrounds[random.nextInt(_welcomeBackgrounds.length)];
      case BackgroundType.night:
        return _nightBackgrounds[random.nextInt(_nightBackgrounds.length)];
      case BackgroundType.morning:
        return _morningBackgrounds[random.nextInt(_morningBackgrounds.length)];
      case BackgroundType.completion:
        return _completionBackgrounds[random.nextInt(_completionBackgrounds.length)];
    }
  }

  /// Reset all background indices (useful for testing or reset functionality)
  static Future<void> resetAllBackgrounds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_welcomeIndexKey);
      await prefs.remove(_nightIndexKey);
      await prefs.remove(_morningIndexKey);
      await prefs.remove(_completionIndexKey);
    } catch (e) {
      print('Error resetting backgrounds: $e');
    }
  }

  /// Get current background index for debugging
  static Future<int> getCurrentIndex(BackgroundType type) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String key;
      switch (type) {
        case BackgroundType.welcome:
          key = _welcomeIndexKey;
          break;
        case BackgroundType.night:
          key = _nightIndexKey;
          break;
        case BackgroundType.morning:
          key = _morningIndexKey;
          break;
        case BackgroundType.completion:
          key = _completionIndexKey;
          break;
      }
      return prefs.getInt(key) ?? 0;
    } catch (e) {
      return 0;
    }
  }
}

/// Enum to identify different page types
enum BackgroundType {
  welcome,
  night,
  morning,
  completion,
}
