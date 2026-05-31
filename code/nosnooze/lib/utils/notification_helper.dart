import 'package:alarm/alarm.dart' as alarm_pkg;
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/alarm.dart';

// Class for low-level changes and algorithmic timeline execution allowing alarm queueing in OS.
// Interlinks the background notifications with timezone tracking, and schedules recurrence loops
// for repeated alarms.
class NotificationHelper {
  // Private constructor keeping external initialization of a static utility class.
  NotificationHelper._();

  // An instance wrapper that will collaborate with the system notifications.
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // Method that implements platform channels, local timezones, and prepares the visual layout.
  // Returns: A Future post proper localization and registration.
  static Future<void> init() async {
    // We'll exit if the application gets into a web sandbox.
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

  // Method that obtains the OS permission so we can make background alarms.
  // Returns: A Future post prompting the user for OS permission.
  static Future<void> requestPermissions() async {
    if (kIsWeb) return;
    // See if notifications are denied and and request permission if so.
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
    // Check and request access to exact alarm scheduling.
    if (!(await Permission.scheduleExactAlarm.isGranted)) {
      await Permission.scheduleExactAlarm.request();
    }
  }

  // Method that replaces all active alarms on the native device and sequentially updates the OS
  // with current active alarms.
  // Parameters:
  //   - alarms - The alarms the user has configured themselves.
  // Returns: A Future post terminating the native alarms.
  static Future<void> scheduleAllAlarms(List<Alarm> alarms) async {
    if (kIsWeb) return;
    await alarm_pkg.Alarm.stopAll();
    // Go through the records and schedule each enabled alarm.
    for (final a in alarms) {
      if (a.isEnabled) await _scheduleNext(a);
    }
  }

  // Method for scheduling the next alarm object onto queue as prompted by internal properties.
  // Parameters:
  //   - alarm - The configuration determining the mapping.
  // Returns: A Future post completing the native registration.
  static Future<void> scheduleNext(Alarm alarm) async {
    if (kIsWeb) return;
    if (!alarm.isEnabled) return;
    await _scheduleNext(alarm);
  }

  // Private calculator method for routing execution times to native frameworks.
  // Parameters:
  //   - alarm - The configuration determining the execution.
  // Returns: A Future post calculating alarm lifecycles.
  static Future<void> _scheduleNext(Alarm alarm) async {
    final next = _nextTrigger(alarm);
    if (next == null) return;
    await _scheduleAt(alarm, next);
  }

  // Method that calculates the next calendar day matching the repeat day.
  // Parameters:
  //   - alarm - The specific alarm we need to reference data of the repeated execution days.
  //   - now: Optional mock status record for algorithmic evaluation.
  // Returns: A DateTime instance correlating with the repeated scheduling, or null.
  static DateTime? _nextTrigger(Alarm alarm, [DateTime? now]) {
    final ref = now ?? tz.TZDateTime.now(tz.local);
    final base = DateTime(
        ref.year, ref.month, ref.day, alarm.hour, alarm.minute);

    // If there aren't repeat days, schedule for today, and if not, tomorrow.
    if (alarm.repeatDays.isEmpty) {
      return base.isAfter(ref) ? base : base.add(const Duration(days: 1));
    }

    // Check through calendar days one by one to get the closest correlating activation day.
    for (var i = 0; i < 8; i++) {
      final candidate = base.add(Duration(days: i));
      // Adjust indexing bounds from a starting value of 1 to a 0-based array index.
      final idx = (candidate.weekday - 1) % 7;
      // Return the generated date if it maps directly into user bounds and sits ahead of now.
      if (alarm.repeatDays.contains(Weekday.values[idx]) &&
          candidate.isAfter(ref)) {
        return candidate;
      }
    }
    return null;
  }

  // Method that interacts with native platform packages to solidify the physical OS timers.
  // Parameters:
  //   - alarm - The alarm serving as a blueprint record of supporting details.
  //   - when - The configured calendar time of execution.
  // Returns: A Future tracking the system pipeline submission execution path.
  static Future<void> _scheduleAt(Alarm alarm, DateTime when) async {
    // We'll have a bitwise mask so arbitrary hashCodes can be nicely converted into 32-bit 
    // positive integer IDs for native OS.
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

  // Method for canceling pending background alerts matching an alarm.
  // Parameters:
  //   - alarm - The reference to the specific alarm.
  // Returns: A Future updating state registers.
  static Future<void> cancelAlarm(Alarm alarm) async {
    if (kIsWeb) return;
    final id = alarm.id.hashCode & 0x7FFFFFFF;
    await alarm_pkg.Alarm.stop(id);
  }

  // Clears out every background alarm on the OS system registry.
  // Returns: A Future completing when system queues purge.
  static Future<void> cancelAll() async {
    if (kIsWeb) return;
    await alarm_pkg.Alarm.stopAll();
  }
}