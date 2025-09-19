import 'package:flutter/material.dart';

class SleepTimer {
  final TimeOfDay time;
  final String selectedAudioId;
  final String? customAudioPath;
  final bool isEnabled;

  const SleepTimer({
    required this.time,
    required this.selectedAudioId,
    this.customAudioPath,
    this.isEnabled = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'hour': time.hour,
      'minute': time.minute,
      'selectedAudioId': selectedAudioId,
      'customAudioPath': customAudioPath,
      'isEnabled': isEnabled,
    };
  }

  factory SleepTimer.fromJson(Map<String, dynamic> json) {
    return SleepTimer(
      time: TimeOfDay(
        hour: json['hour'] as int,
        minute: json['minute'] as int,
      ),
      selectedAudioId: json['selectedAudioId'] as String,
      customAudioPath: json['customAudioPath'] as String?,
      isEnabled: json['isEnabled'] as bool? ?? true,
    );
  }

  SleepTimer copyWith({
    TimeOfDay? time,
    String? selectedAudioId,
    String? customAudioPath,
    bool? isEnabled,
  }) {
    return SleepTimer(
      time: time ?? this.time,
      selectedAudioId: selectedAudioId ?? this.selectedAudioId,
      customAudioPath: customAudioPath ?? this.customAudioPath,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}
