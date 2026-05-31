import 'dart:convert';

// A list of Puzzle types done by named enum constants.
// - math - Arithmetic math puzzle.
// - trivia - Questions and knowledge puzzle.
// - pattern - A tracing puzzle.
enum PuzzleType {math, trivia, pattern}

// A list of the days of the week done by short-named enum constants.
enum Weekday {mon,tue,wed,thu,fri,sat,sun}

// Class for an object that can schedule alarms, add alarm repetition, and a choice of puzzle
// to compliment the alarm.
// Class includes methods managing alarm labels, cloning, and JSON communication. 
class Alarm {
  // String field for identifying alarms.
  final String id;
  // String field for user inputted alarm captions.
  final String label;
  // Integer field for the hour of the day the alarm will ring in 24-hour, military format, so
  // including integers 0-23.
  final int hour;
  // Integer field for the minute within an hour the alarm rings, so including integers 0-59.
  final int minute;
  // Boolean field that identifies whether an alarm is active or not.
  final bool isEnabled;
  // A set field for the set of days the alarm will ring on by schedule.
  final Set<Weekday> repeatDays;
  // Field for the puzzle type of a specific alarm.
  final PuzzleType puzzleType;

  // Constructor for an alarm instance.
  // Parameters:
  // - id - The alarm's unique identifier.
  // - label - The caption inputted for the alarm.
  // - hour - The hour the alarm will go off in, an integer 0-23.
  // - minute - The minute within the hour the alarm will go off, an integer 0-59. 
  // - isEnabled - A checker to know whether the alarm is active or not. 
  // - repeatDays - The set of days the alarm will go off again, repeatedly.
  // - puzzleType - The type of puzzle needed to end the alarm.
  const Alarm({
    // The alarm must have an ID, caption (empty allowed), and a set hour and minute.
    required this.id,
    required this.label,
    required this.hour,
    required this.minute,
    this.isEnabled = true,
    this.repeatDays = const {},
    this.puzzleType = PuzzleType.math,
  });

  // Getter method that creates a formatted label for the time under 12-hour AM/PM representation.
  // Returns: The time in 00:00 AM/PM format. 
  String get timeLabel {
    // Determine whether the alarm should be set in AM or PM.
    final period = hour <12 ? 'AM' : 'PM';
    // If the hour is 0, it will be converted to 12.
    // Also ensure that hours greater than 12 will be converted correctly.
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour -12 : hour);
    // Makes sure the minutes are always displayed using two digits, with single digit minutes
    // having a preceding 0.
    final displayMinute = minute.toString().padLeft(2, '0');
    // Return the time in 00:00 AM/PM format.
    return '$displayHour:$displayMinute $period';
  }

  // Getter method that creates the label indicating what days an alarm is repeated.
  // Return: The days repeated in a manual list of strings, or as simplified phrases. 
  String get repeatLabel {
    // If there aren't any repeated days, then the alarm only alerts once.
    if (repeatDays.isEmpty) return 'Once';
    // If all 7 days are being repeated, then the alarm repeats everyday.
    if (repeatDays.length == 7) return 'Every day';
    // Identify the group of weekdays and weekends.
    final weekdays = {Weekday.mon, Weekday.tue, Weekday.wed, Weekday.thu, Weekday.fri};
    final weekend = {Weekday.sat, Weekday.sun};
    // If the repeated days are all weekdays and there are 5 repeated days, the label is weekdays.
    if (repeatDays.containsAll(weekdays) && repeatDays.length == 5) return 'Weekdays';
    // If the repeated days are the weekends and there are 2 repeated days, the label is weekends.
    if (repeatDays.containsAll(weekend) && repeatDays.length == 2) return 'Weekends';
    // Mapping the shortened abberviations with the day label.
    const names = {
      Weekday.mon: 'Mon', Weekday.tue: 'Tue', Weekday.wed: 'Wed', Weekday.thu: 'Thu', 
      Weekday.fri: 'Fri', Weekday.sat: 'Sat', Weekday.sun: "Sun",
    };
    // The return is a string combination of the days separated by commas.
    return repeatDays.map((d) => names[d]!).join(', ');
  }

  // Makes a copy of an alarm but with new properties.
  // Parameters:
  // - label - Optional new caption inputted for the alarm.
  // - hour - Optional new hour the alarm will go off in, an integer 0-23.
  // - minute - Optional new minute within the hour the alarm will go off, an integer 0-59. 
  // - isEnabled - Optional new status to whether the alarm is active or not. 
  // - repeatDays - Optional new set of days the alarm will go off again, repeatedly.
  // - puzzleType - Optional new type of puzzle needed to end the alarm.
  // Return: A new alarm with new properties.
  Alarm copyWith({
    String? label, 
    int? hour,
    int? minute,
    bool? isEnabled,
    Set<Weekday>? repeatDays,
    PuzzleType? puzzleType,
  }) {
    return Alarm(
      // Notice that the ID is still the same, because it is the same alarm,
      // but with new properties.
      id: id,
      label: label ?? this.label,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      isEnabled: isEnabled ?? this.isEnabled,
      repeatDays: repeatDays ?? this.repeatDays,
      puzzleType: puzzleType ?? this.puzzleType,
    );
  }

  // Method that serializes an alarm into a map so we can convert to JSON.
  // Return: The alarm converted to a map with primitive keys and values.
  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'hour': hour,
    'minute': minute, 
    'isEnabled': isEnabled,
    // Enum objects should be their respective primitive integer index.
    'repeatDays': repeatDays.map((d) => d.index).toList(),
    'puzzleType': puzzleType.index,
  };

  // Factory constructor that takes a decoded map structure and makes an alarm instance.
  // Parameters:
  //   - json - A Map containing raw key-value data retrieved from a storage layer.
  // Returns: An instance of alarm.
  factory Alarm.fromJson(Map<String, dynamic> json) => Alarm(
    id: json['id'] as String,
    label: json['label'] as String,
    hour: json['hour'] as int,
    minute: json['minute'] as int,
    isEnabled: json['isEnabled'] as bool,
    // Weekday enums will be reconstructed from our list of integer indices.
    repeatDays: (json['repeatDays'] as List).map((i) => Weekday.values[i as int]).toSet(),
    // The PuzzleType enum will be reconstructed from its integer index.
    puzzleType: PuzzleType.values[json['puzzleType'] as int],
  );

  // Method that creates a list of alarm objects from parsing a JSON string.
  // Parameters:
  //   - source - JSON string that is our array of alarm objects.
  // Returns: List of Alarm objects.
  static List<Alarm> listFromJson(String source){
    final list = jsonDecode(source) as List;
    return list.map((e) => Alarm.fromJson(e as Map<String, dynamic>)).toList();

  }

  // Creates a JSON string from a collection of Alarm objects.
  // Parameters:
  //   - alarms -  A List of Alarms.
  // Returns: A single JSON string.
  static String listToJson(List<Alarm> alarms) => jsonEncode(alarms.map((a) => a.toJson()).toList());
}