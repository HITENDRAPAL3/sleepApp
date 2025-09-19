import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import '../models/audio_file.dart';

class AudioService {
  static List<AudioFile>? _audioFiles;
  static final AudioPlayer _audioPlayer = AudioPlayer();

  static Future<List<AudioFile>> _loadAudioFiles() async {
    if (_audioFiles != null) return _audioFiles!;

    try {
      final String audioJson = await rootBundle.loadString('assets/audio/audio_files.json');
      final List<dynamic> audioData = json.decode(audioJson);
      _audioFiles = audioData.map((json) => AudioFile.fromJson(json)).toList();
      return _audioFiles!;
    } catch (e) {
      // Fallback audio files in case of error
      _audioFiles = [
        const AudioFile(
          id: 'gentle_bell',
          name: 'Gentle Bell',
          filename: 'gentle_bell.mp3',
          type: 'tone',
          description: 'A soft, calming bell sound',
        ),
        const AudioFile(
          id: 'ocean_waves',
          name: 'Ocean Waves',
          filename: 'ocean_waves.mp3',
          type: 'nature',
          description: 'Relaxing ocean wave sounds',
        ),
      ];
      return _audioFiles!;
    }
  }

  static Future<List<AudioFile>> getAvailableAudioFiles() async {
    return await _loadAudioFiles();
  }

  static Future<AudioFile?> getAudioFileById(String id) async {
    final audioFiles = await _loadAudioFiles();
    try {
      return audioFiles.firstWhere((audio) => audio.id == id);
    } catch (e) {
      return null;
    }
  }

  static Future<void> playAudio(String audioId, {String? customPath}) async {
    try {
      await _audioPlayer.stop();

      if (customPath != null) {
        await _audioPlayer.play(DeviceFileSource(customPath));
      } else {
        final audioFile = await getAudioFileById(audioId);
        if (audioFile != null) {
          // Note: In a real app, you would have actual audio files
          // For this demo, we'll simulate audio playback
          await _audioPlayer.play(AssetSource('audio/${audioFile.filename}'));
        }
      }
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  static Future<void> stopAudio() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      print('Error stopping audio: $e');
    }
  }

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
      print('Error picking audio file: $e');
      return null;
    }
  }

  static void dispose() {
    _audioPlayer.dispose();
  }
}
