import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/alarm.dart';
 
class NotificationHelper {
  NotificationHelper._();
 
  static final _plugin = FlutterLocalNotificationsPlugin();
 
  static const _channel = AndroidNotificationChannel(
    'nosnooze_alarms',
    'NoSnooze Alarms',
    description: 'Alarm notifications that require puzzle dismissal',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );
 
  static Future<void> init() async {
    tz.initializeTimeZones();
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    await _plugin.initialize(
      const InitializationSettings(
          android: androidSettings, iOS: iosSettings),
    );
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_channel);
  }
 
  static Future<void> scheduleAlarm(Alarm alarm) async {
    if (!alarm.isEnabled) return;
 
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, alarm.hour, alarm.minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
 
    
    await _plugin.zonedSchedule(
      alarm.id.hashCode,
      'NoSnooze: ${alarm.label}',
      'Time to wake up! Solve a puzzle to dismiss.',
      scheduled,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.max,
          priority: Priority.max,
          fullScreenIntent: true,
          ongoing: true,
          autoCancel: false,
        ),
        iOS: const DarwinNotificationDetails(
            presentAlert: true, presentSound: true),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: alarm.id,
    );
  }
 
  static Future<void> cancelAlarm(Alarm alarm) async {
    await _plugin.cancel(alarm.id.hashCode);
  }
 
  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}