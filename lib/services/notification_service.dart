import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/sleep_timer.dart';
import 'audio_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  static const int bedtimeNotificationId = 1;
  static const int wakeupNotificationId = 2;

  static bool _isInitialized = false;

  /// Initialize the notification service
  static Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone data
    tz.initializeTimeZones();

    // Android initialization
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
  }

  /// Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) async {
    final payload = response.payload;
    if (payload != null) {
      // Parse the payload to get audio info
      final parts = payload.split('|');
      if (parts.length >= 2) {
        final audioId = parts[0];
        final customPath = parts.length > 2 ? parts[2] : null;

        // Play the selected audio
        await AudioService.playAudio(audioId, customPath: customPath);
      }
    }
  }

  /// Request notification permissions
  static Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      // For Android 13+, request notification permission
      final status = await Permission.notification.request();
      return status.isGranted;
    } else if (Platform.isIOS) {
      // For iOS, permissions are requested during initialization
      final result = await _notifications
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return result ?? false;
    }
    return true;
  }

  /// Schedule bedtime notification
  static Future<void> scheduleBedtimeNotification(SleepTimer timer) async {
    await _cancelNotification(bedtimeNotificationId);

    if (!timer.isEnabled) return;

    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'bedtime_channel',
        'Bedtime Notifications',
        channelDescription: 'Notifications for bedtime reminders',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(
        sound: 'default',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    // Create payload with audio information
    final payload = '${timer.selectedAudioId}|bedtime|${timer.customAudioPath ?? ''}';

    // Schedule daily repeating notification
    try {
      await _notifications.zonedSchedule(
        bedtimeNotificationId,
        '🌙 Time for Sleep',
        'It\'s time to wind down and prepare for a good night\'s rest.',
        _nextInstanceOfTime(timer.time),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );
    } catch (e) {
      // If exact alarms are not permitted, try with inexact scheduling
      print('Exact alarms not permitted, falling back to inexact scheduling: $e');
      try {
        await _notifications.zonedSchedule(
          bedtimeNotificationId,
          '🌙 Time for Sleep',
          'It\'s time to wind down and prepare for a good night\'s rest.',
          _nextInstanceOfTime(timer.time),
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexact,
          uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: payload,
        );
      } catch (e2) {
        print('Failed to schedule notification: $e2');
        // Continue without notification - don't block the user flow
      }
    }
  }

  /// Schedule wake-up notification
  static Future<void> scheduleWakeupNotification(SleepTimer timer) async {
    await _cancelNotification(wakeupNotificationId);

    if (!timer.isEnabled) return;

    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'wakeup_channel',
        'Wake-up Notifications',
        channelDescription: 'Notifications for wake-up alarms',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(
        sound: 'default',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    // Create payload with audio information
    final payload = '${timer.selectedAudioId}|wakeup|${timer.customAudioPath ?? ''}';

    // Schedule daily repeating notification
    try {
      await _notifications.zonedSchedule(
        wakeupNotificationId,
        '☀️ Good Morning!',
        'Rise and shine! Start your day with energy and positivity.',
        _nextInstanceOfTime(timer.time),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );
    } catch (e) {
      // If exact alarms are not permitted, try with inexact scheduling
      print('Exact alarms not permitted, falling back to inexact scheduling: $e');
      try {
        await _notifications.zonedSchedule(
          wakeupNotificationId,
          '☀️ Good Morning!',
          'Rise and shine! Start your day with energy and positivity.',
          _nextInstanceOfTime(timer.time),
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexact,
          uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: payload,
        );
      } catch (e2) {
        print('Failed to schedule wake-up notification: $e2');
        // Continue without notification - don't block the user flow
      }
    }
  }

  /// Cancel a specific notification
  static Future<void> _cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Cancel bedtime notification
  static Future<void> cancelBedtimeNotification() async {
    await _cancelNotification(bedtimeNotificationId);
  }

  /// Cancel wake-up notification
  static Future<void> cancelWakeupNotification() async {
    await _cancelNotification(wakeupNotificationId);
  }

  /// Helper to calculate next instance of a time
  static tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If the scheduled time has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  /// Check if notifications are enabled
  static Future<bool> areNotificationsEnabled() async {
    if (Platform.isAndroid) {
      return await Permission.notification.status == PermissionStatus.granted;
    } else if (Platform.isIOS) {
      final result = await _notifications
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
          ?.checkPermissions();
      return result?.isEnabled ?? false;
    }
    return true;
  }

  /// Get all pending notifications
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// Show immediate test notification
  static Future<void> showTestNotification() async {
    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'test_channel',
        'Test Notifications',
        channelDescription: 'Test notifications',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _notifications.show(
      999,
      'Test Notification',
      'This is a test notification to verify everything is working!',
      notificationDetails,
    );
  }
}