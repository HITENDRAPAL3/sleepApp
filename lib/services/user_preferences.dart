import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static const String _isFirstTimeKey = 'is_first_time';
  static const String _sleepTimeKey = 'sleep_time';
  static const String _wakeTimeKey = 'wake_time';
  static const String _sleepToneKey = 'sleep_tone';
  static const String _wakeToneKey = 'wake_tone';
  static const String _sleepReminderEnabledKey = 'sleep_reminder_enabled';
  static const String _wakeReminderEnabledKey = 'wake_reminder_enabled';

  static Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isFirstTimeKey) ?? true;
  }

  static Future<void> setFirstTimeComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isFirstTimeKey, false);
  }

  static Future<String?> getSleepTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sleepTimeKey);
  }

  static Future<void> setSleepTime(String time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sleepTimeKey, time);
  }

  static Future<String?> getWakeTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_wakeTimeKey);
  }

  static Future<void> setWakeTime(String time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_wakeTimeKey, time);
  }

  static Future<String?> getSleepTone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sleepToneKey);
  }

  static Future<void> setSleepTone(String tone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sleepToneKey, tone);
  }

  static Future<String?> getWakeTone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_wakeToneKey);
  }

  static Future<void> setWakeTone(String tone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_wakeToneKey, tone);
  }

  static Future<bool> isSleepReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_sleepReminderEnabledKey) ?? true;
  }

  static Future<void> setSleepReminderEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_sleepReminderEnabledKey, enabled);
  }

  static Future<bool> isWakeReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_wakeReminderEnabledKey) ?? true;
  }

  static Future<void> setWakeReminderEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_wakeReminderEnabledKey, enabled);
  }
}
