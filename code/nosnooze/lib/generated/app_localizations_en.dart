// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'NoSnooze';

  @override
  String get alarmsTab => 'Alarms';

  @override
  String get settingsTab => 'Settings';

  @override
  String get addAlarm => 'Add Alarm';

  @override
  String get editAlarm => 'Edit Alarm';

  @override
  String get deleteAlarm => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get puzzleTitle => 'Solve to Dismiss';

  @override
  String get puzzleInstructions => 'Solve the puzzle to turn off your alarm';

  @override
  String get correct => 'Correct! Alarm dismissed.';

  @override
  String get incorrect => 'Wrong answer — try again!';

  @override
  String get snoozeNotAllowed => 'No snooze. Solve the puzzle!';

  @override
  String get alarmLabel => 'Label';

  @override
  String get alarmTime => 'Time';

  @override
  String get repeatDays => 'Repeat';

  @override
  String get puzzleType => 'Puzzle Type';

  @override
  String get mathPuzzle => 'Math';

  @override
  String get triviaPuzzle => 'Trivia';

  @override
  String get patternPuzzle => 'Pattern';

  @override
  String get shakeHint => 'Shake for a hint!';

  @override
  String get noAlarmsYet => 'No alarms set.\nTap + to add one.';

  @override
  String get alarmEnabled => 'Alarm enabled';

  @override
  String get alarmDisabled => 'Alarm disabled';
}
