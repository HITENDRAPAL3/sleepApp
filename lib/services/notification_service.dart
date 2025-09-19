import 'package:flutter/material.dart';

class NotificationService {
  static Future<void> init() async {
    // Simplified notification service for demo
    debugPrint('NotificationService initialized');
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    // For demo purposes, just log the notification
    debugPrint('Notification scheduled: $title at $scheduledTime');
  }

  static Future<void> cancelNotification(int id) async {
    debugPrint('Notification $id cancelled');
  }

  static Future<void> cancelAllNotifications() async {
    debugPrint('All notifications cancelled');
  }
}
