import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';

class WhiteNoiseService {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static Timer? _durationTimer;
  static bool _isPlaying = false;
  static String? _currentSoundId;
  static Duration? _totalDuration;
  static DateTime? _startTime;

  // Callbacks for UI updates
  static Function(bool)? onPlayingStateChanged;
  static Function(Duration)? onTimeRemaining;

  /// Get available white noise sounds
  static Future<List<WhiteNoiseSound>> getWhiteNoiseSounds() async {
    try {
      final String soundsJson = await rootBundle.loadString('assets/audio/white_noise_sounds.json');
      final List<dynamic> soundsData = json.decode(soundsJson);
      return soundsData.map((json) => WhiteNoiseSound.fromJson(json)).toList();
    } catch (e) {
      // Fallback sounds if JSON fails to load
      return _getFallbackSounds();
    }
  }

  /// Fallback white noise sounds
  static List<WhiteNoiseSound> _getFallbackSounds() {
    return [
      const WhiteNoiseSound(
        id: 'ocean_waves',
        name: 'Ocean Waves',
        filename: 'white_noise_ocean.mp3',
        description: 'Relaxing ocean wave sounds',
        category: 'nature',
      ),
      const WhiteNoiseSound(
        id: 'rain_forest',
        name: 'Rain Forest',
        filename: 'white_noise_rain.mp3',
        description: 'Gentle rain in the forest',
        category: 'nature',
      ),
      const WhiteNoiseSound(
        id: 'crackling_fire',
        name: 'Crackling Fire',
        filename: 'white_noise_fire.mp3',
        description: 'Cozy fireplace crackling',
        category: 'ambient',
      ),
      const WhiteNoiseSound(
        id: 'birds_chirping',
        name: 'Birds Chirping',
        filename: 'white_noise_birds.mp3',
        description: 'Peaceful bird sounds',
        category: 'nature',
      ),
      const WhiteNoiseSound(
        id: 'white_noise_static',
        name: 'White Noise',
        filename: 'white_noise_static.mp3',
        description: 'Pure white noise for focus',
        category: 'static',
      ),
      const WhiteNoiseSound(
        id: 'brown_noise',
        name: 'Brown Noise',
        filename: 'white_noise_brown.mp3',
        description: 'Deep brown noise',
        category: 'static',
      ),
      const WhiteNoiseSound(
        id: 'pink_noise',
        name: 'Pink Noise',
        filename: 'white_noise_pink.mp3',
        description: 'Balanced pink noise',
        category: 'static',
      ),
      const WhiteNoiseSound(
        id: 'atoms_vibrating',
        name: 'Atoms Vibrating',
        filename: 'white_noise_atoms.mp3',
        description: 'Atomic vibration sounds',
        category: 'ambient',
      ),
    ];
  }

  /// Play white noise with duration and looping
  static Future<void> playWhiteNoise({
    required String soundId,
    required Duration duration,
    String? customPath,
  }) async {
    try {
      await stopWhiteNoise();

      _currentSoundId = soundId;
      _totalDuration = duration;
      _startTime = DateTime.now();
      _isPlaying = true;

      // Configure audio player for looping
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);

      // Play the sound
      if (customPath != null) {
        await _audioPlayer.play(DeviceFileSource(customPath));
      } else {
        final sounds = await getWhiteNoiseSounds();
        final sound = sounds.firstWhere((s) => s.id == soundId,
            orElse: () => sounds.first);
        await _audioPlayer.play(AssetSource('audio/${sound.filename}'));
      }

      // Set up duration timer
      _setupDurationTimer(duration);

      // Notify UI
      onPlayingStateChanged?.call(true);

    } catch (e) {
      print('Error playing white noise: $e');
      _isPlaying = false;
      onPlayingStateChanged?.call(false);
    }
  }

  /// Set up timer to stop playback after specified duration
  static void _setupDurationTimer(Duration duration) {
    _durationTimer?.cancel();

    // Update remaining time every second
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPlaying || _startTime == null) {
        timer.cancel();
        return;
      }

      final elapsed = DateTime.now().difference(_startTime!);
      final remaining = duration - elapsed;

      if (remaining.inSeconds <= 0) {
        stopWhiteNoise();
        timer.cancel();
      } else {
        onTimeRemaining?.call(remaining);
      }
    });
  }

  /// Stop white noise playback
  static Future<void> stopWhiteNoise() async {
    try {
      await _audioPlayer.stop();
      _durationTimer?.cancel();
      _isPlaying = false;
      _currentSoundId = null;
      _totalDuration = null;
      _startTime = null;

      onPlayingStateChanged?.call(false);
      onTimeRemaining?.call(Duration.zero);
    } catch (e) {
      print('Error stopping white noise: $e');
    }
  }

  /// Pause/Resume white noise
  static Future<void> pauseResumeWhiteNoise() async {
    try {
      if (_audioPlayer.state == PlayerState.playing) {
        await _audioPlayer.pause();
        onPlayingStateChanged?.call(false);
      } else if (_audioPlayer.state == PlayerState.paused) {
        await _audioPlayer.resume();
        onPlayingStateChanged?.call(true);
      }
    } catch (e) {
      print('Error pausing/resuming white noise: $e');
    }
  }

  /// Check if currently playing
  static bool get isPlaying => _isPlaying;

  /// Get current sound ID
  static String? get currentSoundId => _currentSoundId;

  /// Get remaining time
  static Duration getRemainingTime() {
    if (_startTime == null || _totalDuration == null || !_isPlaying) {
      return Duration.zero;
    }

    final elapsed = DateTime.now().difference(_startTime!);
    final remaining = _totalDuration! - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Pick custom audio file
  static Future<String?> pickCustomAudio() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        return result.files.single.path;
      }
      return null;
    } catch (e) {
      print('Error picking custom audio: $e');
      return null;
    }
  }

  /// Dispose resources
  static void dispose() {
    _audioPlayer.dispose();
    _durationTimer?.cancel();
  }

  /// Get preset durations
  static List<Duration> getPresetDurations() {
    return [
      const Duration(minutes: 15),
      const Duration(minutes: 30),
      const Duration(hours: 1),
      const Duration(hours: 2),
      const Duration(hours: 4),
      const Duration(hours: 8),
    ];
  }

  /// Format duration for display
  static String formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }
}

/// Model for white noise sounds
class WhiteNoiseSound {
  final String id;
  final String name;
  final String filename;
  final String description;
  final String category;

  const WhiteNoiseSound({
    required this.id,
    required this.name,
    required this.filename,
    required this.description,
    required this.category,
  });

  factory WhiteNoiseSound.fromJson(Map<String, dynamic> json) {
    return WhiteNoiseSound(
      id: json['id'] as String,
      name: json['name'] as String,
      filename: json['filename'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'filename': filename,
      'description': description,
      'category': category,
    };
  }
}