import 'package:flutter/material.dart';

class AudioService {
  
  static const List<String> defaultTones = [
    'Gentle Bells',
    'Ocean Waves',
    'Rain Sounds',
    'Forest Ambience',
    'Soft Piano',
    'Wind Chimes',
    'White Noise',
    'Bird Songs',
  ];

  static Future<List<String>> getAvailableTones() async {
    // For demo purposes, return default tones
    // In a real app, you would scan the assets/music folder
    return defaultTones;
  }

  static Future<String?> pickCustomTone() async {
    try {
      // For demo purposes, simulate file picker
      debugPrint('File picker would open here');
      // Return a simulated custom file name
      return 'My_Custom_Song.mp3';
    } catch (e) {
      return null;
    }
  }

  static Future<void> playPreview(String toneName) async {
    try {
      // For demo purposes, we'll use a system sound
      // In a real app, you would load the actual audio file
      if (defaultTones.contains(toneName)) {
        // Play a short preview of the selected tone
        // This would load from assets/music/tone_name.mp3
        // For now, we'll skip actual audio playback since we don't have audio files
        // await _audioPlayer.setAsset('assets/music/preview.mp3');
        // await _audioPlayer.play();
        
        // Simulate preview duration
        await Future.delayed(const Duration(milliseconds: 500));
        // await _audioPlayer.stop();
      }
    } catch (e) {
      // Handle error silently for demo
    }
  }

  static Future<void> stopPreview() async {
    debugPrint('Audio preview stopped');
  }
}
