import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// The name of the application
  ///
  /// In en, this message translates to:
  /// **'NoSnooze'**
  String get appTitle;

  /// No description provided for @alarmsTab.
  ///
  /// In en, this message translates to:
  /// **'Alarms'**
  String get alarmsTab;

  /// No description provided for @settingsTab.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTab;

  /// No description provided for @addAlarm.
  ///
  /// In en, this message translates to:
  /// **'Add Alarm'**
  String get addAlarm;

  /// No description provided for @editAlarm.
  ///
  /// In en, this message translates to:
  /// **'Edit Alarm'**
  String get editAlarm;

  /// No description provided for @deleteAlarm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteAlarm;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @puzzleTitle.
  ///
  /// In en, this message translates to:
  /// **'Solve to Dismiss'**
  String get puzzleTitle;

  /// No description provided for @puzzleInstructions.
  ///
  /// In en, this message translates to:
  /// **'Solve the puzzle to turn off your alarm'**
  String get puzzleInstructions;

  /// No description provided for @correct.
  ///
  /// In en, this message translates to:
  /// **'Correct! Alarm dismissed.'**
  String get correct;

  /// No description provided for @incorrect.
  ///
  /// In en, this message translates to:
  /// **'Wrong answer — try again!'**
  String get incorrect;

  /// No description provided for @snoozeNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'No snooze. Solve the puzzle!'**
  String get snoozeNotAllowed;

  /// No description provided for @alarmLabel.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get alarmLabel;

  /// No description provided for @alarmLabelHint.
  ///
  /// In en, this message translates to:
  /// **'Alarm'**
  String get alarmLabelHint;

  /// No description provided for @alarmTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get alarmTime;

  /// No description provided for @repeatDays.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeatDays;

  /// No description provided for @puzzleType.
  ///
  /// In en, this message translates to:
  /// **'Puzzle'**
  String get puzzleType;

  /// No description provided for @mathPuzzle.
  ///
  /// In en, this message translates to:
  /// **'Math'**
  String get mathPuzzle;

  /// No description provided for @triviaPuzzle.
  ///
  /// In en, this message translates to:
  /// **'Trivia'**
  String get triviaPuzzle;

  /// No description provided for @patternPuzzle.
  ///
  /// In en, this message translates to:
  /// **'Pattern'**
  String get patternPuzzle;

  /// No description provided for @shakeHint.
  ///
  /// In en, this message translates to:
  /// **'Shake for a hint!'**
  String get shakeHint;

  /// No description provided for @noAlarmsYet.
  ///
  /// In en, this message translates to:
  /// **'No alarms set.\nTap + to add one.'**
  String get noAlarmsYet;

  /// No description provided for @alarmEnabled.
  ///
  /// In en, this message translates to:
  /// **'Alarm enabled'**
  String get alarmEnabled;

  /// No description provided for @alarmDisabled.
  ///
  /// In en, this message translates to:
  /// **'Alarm disabled'**
  String get alarmDisabled;

  /// No description provided for @dismissAlarm.
  ///
  /// In en, this message translates to:
  /// **'Dismiss Alarm'**
  String get dismissAlarm;

  /// No description provided for @yourAnswer.
  ///
  /// In en, this message translates to:
  /// **'Your answer...'**
  String get yourAnswer;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @analogClock.
  ///
  /// In en, this message translates to:
  /// **'Analog Clock'**
  String get analogClock;

  /// No description provided for @alarmSectionHeader.
  ///
  /// In en, this message translates to:
  /// **'ALARM'**
  String get alarmSectionHeader;

  /// No description provided for @repeatNever.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get repeatNever;

  /// No description provided for @repeatEveryDay.
  ///
  /// In en, this message translates to:
  /// **'Every Day'**
  String get repeatEveryDay;

  /// No description provided for @repeatWeekdays.
  ///
  /// In en, this message translates to:
  /// **'Weekdays'**
  String get repeatWeekdays;

  /// No description provided for @repeatWeekends.
  ///
  /// In en, this message translates to:
  /// **'Weekends'**
  String get repeatWeekends;

  /// No description provided for @repeatOnce.
  ///
  /// In en, this message translates to:
  /// **'Once'**
  String get repeatOnce;

  /// No description provided for @dayMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get dayMon;

  /// No description provided for @dayTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get dayTue;

  /// No description provided for @dayWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get dayWed;

  /// No description provided for @dayThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get dayThu;

  /// No description provided for @dayFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get dayFri;

  /// No description provided for @daySat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get daySat;

  /// No description provided for @daySun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get daySun;

  /// No description provided for @dayMonAbbr.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get dayMonAbbr;

  /// No description provided for @dayTueAbbr.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get dayTueAbbr;

  /// No description provided for @dayWedAbbr.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get dayWedAbbr;

  /// No description provided for @dayThuAbbr.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get dayThuAbbr;

  /// No description provided for @dayFriAbbr.
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get dayFriAbbr;

  /// No description provided for @daySatAbbr.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get daySatAbbr;

  /// No description provided for @daySunAbbr.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get daySunAbbr;

  /// No description provided for @periodAm.
  ///
  /// In en, this message translates to:
  /// **'AM'**
  String get periodAm;

  /// No description provided for @periodPm.
  ///
  /// In en, this message translates to:
  /// **'PM'**
  String get periodPm;

  /// No description provided for @alarmNotFound.
  ///
  /// In en, this message translates to:
  /// **'Alarm not found'**
  String get alarmNotFound;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
