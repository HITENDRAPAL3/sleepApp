import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sleep_timer.dart';

class PreferencesService {
  static const String _keyIsFirstTime = 'is_first_time';
  static const String _keyNightTimer = 'night_timer';
  static const String _keyMorningTimer = 'morning_timer';
  static const String _keySetupCompleted = 'setup_completed';

  static Future<bool> isFirstTimeUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsFirstTime) ?? true;
  }

  static Future<void> setFirstTimeUserFlag(bool isFirstTime) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsFirstTime, isFirstTime);
  }

  static Future<bool> isSetupCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySetupCompleted) ?? false;
  }

  static Future<void> setSetupCompleted(bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySetupCompleted, completed);
  }

  static Future<SleepTimer?> getNightTimer() async {
    final prefs = await SharedPreferences.getInstance();
    final timerJson = prefs.getString(_keyNightTimer);
    if (timerJson != null) {
      try {
        final timerData = json.decode(timerJson);
        return SleepTimer.fromJson(timerData);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static Future<void> saveNightTimer(SleepTimer timer) async {
    final prefs = await SharedPreferences.getInstance();
    final timerJson = json.encode(timer.toJson());
    await prefs.setString(_keyNightTimer, timerJson);
  }

  static Future<SleepTimer?> getMorningTimer() async {
    final prefs = await SharedPreferences.getInstance();
    final timerJson = prefs.getString(_keyMorningTimer);
    if (timerJson != null) {
      try {
        final timerData = json.decode(timerJson);
        return SleepTimer.fromJson(timerData);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static Future<void> saveMorningTimer(SleepTimer timer) async {
    final prefs = await SharedPreferences.getInstance();
    final timerJson = json.encode(timer.toJson());
    await prefs.setString(_keyMorningTimer, timerJson);
  }

  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}