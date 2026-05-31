NoSnooze:
NoSnooze is a puzzle-based alarm app that forces you to wake your brain before you are able to silence our phone. Instead of tapping snooze you have to solve a short puzzle: math, puzzle, or triva to dismiss the alarm. The goal is to discourage passive moring scrolling, reducing sleep ineration and helping you start your day mentally engaged.


Build Instructions:
Requirements:
- Flutter SDK >= 3.38.4
- Dart SDK >= 3.11.0 < 4.0.0
- Android: minSdk as set by Flutter Gradle plugin
- IOS: not tested
- Internet connection at runtime (for Triva puzzle type though its not required as app will default to math puzzle)

Dependencies:

All dependencies are in pubspec.yaml. no api keys are needed. To fetch depednecies run: flutter pub get

Android-specific setup:
The AndroidManifest.xml has all the required permissions
- POST_NOTIFICATIOSN - notifcation delivery on ANDROID 13+
- SCHEDULE_EXACT_ALARM/USE_EXACT_ALARM - used for percies alarm scheduling
- USE_FULL_SCREEN_INTENT - shows alarm over the lock screen
- FOREGROUND_SERVICE - keeps the alarm alive in the background
- RECEIVE_BOOT_COMPLETED - rescheudle alarms after reboot
- VIBRATE/WAKE_LOCK - hardware access

there is no additional android config needed

IOS setup:
NOT TESTED

Running the app:
flutter run

Project Layout:
All application soruce lives under lib/

lib/main.dart:
Initializes the alarm package, notifcation permissons and timezone data. Listens to the Alarm.ringing stream inorder to navigate to the dismiss screen when an alarm fires, including cold starts.

lib/models/:
- alarm.dart: Alarm data model, defines PuzzleType and Weekday enums, serialisation to/from JSON and helper getters for the display labels

- puzzle.dart: Puzzle data model, hods the question, answer, optional hint and category. Includes a check() method for answer validation

- weekday.dart: Barrel export re-exporting Weekday from alarm.dart



/lib/providers/:

- alarm_provider.dart: ChangeNotifer that owns the alarm list, handles loading from and persisting to SharedPrefernces, scheduling via NotificationHelper and full undo/redo via snapshot stacks.

- locale_provider.dart: ChangeNotifier that persists and restores the users chosen locale across sessions



lib/screens/:
- home_screen.dart: Main alarm list, shows alarms with time AM/PM and repeat label. Supports edit mode with slide in delete buttons and undo/redo controls.

- add_edit_alarm_screen.dart: create or edit an alarm. Contains a CupertinoDatePicker for time, and expanding repeat day selector and a puzzle type segmented control

- alarm_dismiss_screen.dart: shown when alarm fiers, leads the matching alarm and generates a puzzle, supports shake to reveal hint and swipe down works aswell. Dismisses the alarm only on a correct answer

- settings_screen.dart:
language selector and analog clock demo



lib/utils/:
- notification_helper.dart: wraps the alarm package. Handles timezone initialisation permisson request schduing next alarm trigger and cancellation

- puzzle_service.dart: generates puzzles. math and patter puzzles are locally generated while triva puzzles are fetched from the OpenTrivaDB api with a local fallback



lib/widgets/:
- annlog_clock.dart: A CustomPainter based live analog clock widget used on settings screen, Draws tick marks hour minute and second hands using canvas API




lib/generated/:

Auto generated localization files produced by flutter gen-l10n, dont edit directly, edit lib/l10n/app_en.arb and lib/l10n/app_es.arb instead then rerun flutter gen-l10n

lib/l10n/ 
ARB translation files for english(app_en.arb) and spanish(app_es.arb)



