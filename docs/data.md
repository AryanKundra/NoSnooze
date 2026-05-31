Data Desing/Data Flow

Data Design:
Alarm
the core data model is found in the alarm class in lib/models/alarm.dart

class Alarm {
  final String id;          // UUID v4 — unique identifier
  final String label;       // User-defined name (may be empty)
  final int hour;           // 0–23
  final int minute;         // 0–59
  final bool isEnabled;     // Whether the alarm is active
  final Set<Weekday> repeatDays; // Empty = one-time alarm
  final PuzzleType puzzleType;   // math | trivia | pattern
}

enums:
Weekday - mon, tue, wed, thu, fri, sat, sun
PuzzleType - math, trivia, pattern

the model is immutable, any and all mutations have to go through copyWith() which returns a new instances which allows for snapshot based undo/redo safe since each snapshot is an indepent copy of the list

Serialization: Alarm.toJson and Alarm.fromJson() convert to/from Map<String, dynamic>. the full alarm list is serialized as a JSON array via Alarm.listToJson()/Alarm.listFromJson() and stored as a single string in SharedPreferences

Puzzle: 
Defined in lib/models/puzzle.dart is transiennt and does not persist.

class Puzzle {
  final String question;
  final String answer;
  final String? hint;
  final PuzzleCategory category; // math | trivia | pattern
}

puzzle.check(String input) performs a case-insenstive/whitspace trimmed comparison making answer validation consistent across the various puzzle types

Data Flow:

Provider Archtiectures: 

The app uses the provider packing for reactive state management. Two ChangeNotifier providers are registered at the root of the widget tree in main.dart via MultiProvider:

AlarmProvider is App Wide and is responsible for the Alarm list, persistence, scheduling and the undo/redo

LocaleProvider is app wide aswell and is responsible for finding the current locale of the user and is persisted to shared preferences

AlarmProvider - Alarm state

AlarmProvider is the single source of trhough for all alarms, its flow for any mutation operation is 

User action (add / edit / delete / toggle)
  → _snapshot()          — push current list onto undo stack, clear redo stack
  → _apply(newState)     — update _alarms, call notifyListeners()
  → _persist()           — write JSON to SharedPreferences
  → _rescheduleAll()     — cancel all existing alarms, re-schedule enabled ones

On app startup AlarmProvider.load() is called before runApp() so the UI always has data availbe on the first frame. after loading _rescheduleAll() is called to make sure the alarms that were scheudled before a restart are still registered with the alarm package

Undo/Redo is implmeneted through tow List<List<Alarm>> stacks(_undoStack,_redoStack). each mutation calle pushes a snapshot of the current list before applying any changes. The undo pops from the undo stack and pushes to the redo stack. redo does the opposite. because alarm is immutable snapshots are safe shallow copies

LocalProvider - Locale State
LocaleProvider laods the saved locale from SharedPreferences on construction and exposes setLocale(Locale). calling setLocale updates the in-memory local, persists the language code and calls notifyListeners(). the MaterialApp in main.dart consumes the LocaleProvider via Consuemr and then passes its locale down to flutters localisation system

Alarm Scheduling Flow:
When an alarm is due to fire the alarm package handles audio, wake locks, and the foreground service. The flutter side is responisble for 
1. Scheduling: NotificationHelper._scheduleAt() creates an AlarmSettings object with the alarms UUID stored in the payload field then calls Alarm.set()

2. Detection: main.dart subscribes to Alarm.ringing (a stream). when it fires the UUID is extracted from settings.paylaod and passed directly to AlarmDismissScreen as alarmUuid

3. Lookup: AlarmDismissScreen._loadAlarmAndPuzzle() uses alarmUuid to call AlarmProvider.getAlarmById() directly. 

4. Dismissal: after a correct answer Alarm.stop() is called and if  the alarm repeats NotificationHelper.schduleNext() schdules the next occurence.


Puzzle Generation Flow

AlarmDismissScreen loads
  → PuzzleService.generate(puzzleType)
      → math:    generated locally using Random
      → pattern: generated locally using Random
      → trivia:  HTTP GET to opentdb.com/api.php
                   → on success: parse and return Puzzle
                   → on failure/timeout: fall back to math puzzle
  → setState({ _puzzle, _loading: false })
  → UI renders puzzle card

  the trivia API needs no key and is called with a 5 second timeout. the local fallback makes sure that the dismiss screen always loads successfully regarless of a network connection.
  

