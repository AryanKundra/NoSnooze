import 'package:alarm/alarm.dart' as alarm_pkg;
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/alarm.dart';

class NotificationHelper {
  NotificationHelper._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();


  static Future<void> init() async {
    if (kIsWeb) return;

    tz.initializeTimeZones();
    try {
      final tzInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(tzInfo.identifier));
    } catch (e) {
      debugPrint('Timezone error: $e — falling back to UTC.');
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        ),
      ),
    );
  }


  static Future<void> requestPermissions() async {
    if (kIsWeb) return;

    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
    if (!(await Permission.scheduleExactAlarm.isGranted)) {
      await Permission.scheduleExactAlarm.request();
    }
  }


  static Future<void> scheduleAllAlarms(List<Alarm> alarms) async {
    if (kIsWeb) return;
    await alarm_pkg.Alarm.stopAll();
    for (final a in alarms) {
      if (a.isEnabled) await _scheduleNext(a);
    }
  }

  static Future<void> scheduleNext(Alarm alarm) async {
    if (kIsWeb) return;
    if (!alarm.isEnabled) return;
    await _scheduleNext(alarm);
  }

  static Future<void> _scheduleNext(Alarm alarm) async {
    final next = _nextTrigger(alarm);
    if (next == null) return;
    await _scheduleAt(alarm, next);
  }

  static DateTime? _nextTrigger(Alarm alarm, [DateTime? now]) {
    final ref = now ?? tz.TZDateTime.now(tz.local);
    final base = DateTime(
        ref.year, ref.month, ref.day, alarm.hour, alarm.minute);

    if (alarm.repeatDays.isEmpty) {
      return base.isAfter(ref) ? base : base.add(const Duration(days: 1));
    }

    for (var i = 0; i < 8; i++) {
      final candidate = base.add(Duration(days: i));
      final idx = (candidate.weekday - 1) % 7;
      if (alarm.repeatDays.contains(Weekday.values[idx]) &&
          candidate.isAfter(ref)) {
        return candidate;
      }
    }
    return null;
  }

  static Future<void> _scheduleAt(Alarm alarm, DateTime when) async {
    final id = alarm.id.hashCode & 0x7FFFFFFF;

    final settings = alarm_pkg.AlarmSettings(
      id: id,
      dateTime: when,
      assetAudioPath: null,
      loopAudio: true,
      vibrate: true,
      androidFullScreenIntent: true,
      payload: alarm.id,
      volumeSettings: const alarm_pkg.VolumeSettings.fixed(volume: 1.0),
      notificationSettings: alarm_pkg.NotificationSettings(
        title: 'NoSnooze: ${alarm.label.isEmpty ? 'Alarm' : alarm.label}',
        body: 'Solve the puzzle to wake up!',
        stopButton: null,
      ),
    );

    try {
      await alarm_pkg.Alarm.set(alarmSettings: settings);
      debugPrint('✅ Alarm "${alarm.label}" scheduled for $when');
    } catch (e) {
      debugPrint('❌ Failed to schedule alarm "${alarm.label}": $e');
    }
  }


  static Future<void> cancelAlarm(Alarm alarm) async {
    if (kIsWeb) return;
    final id = alarm.id.hashCode & 0x7FFFFFFF;
    await alarm_pkg.Alarm.stop(id);
  }

  static Future<void> cancelAll() async {
    if (kIsWeb) return;
    await alarm_pkg.Alarm.stopAll();
  }
}