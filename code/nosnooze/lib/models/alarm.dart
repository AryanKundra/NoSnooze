import 'dart:convert';

enum PuzzleType {math, trivia, pattern}

enum Weekday {mon,tue,wed,thu,fri,sat,sun}

class Alarm {
  final String id;
  final String label;
  final int hour;
  final int minute;
  final bool isEnabled;
  final Set<Weekday> repeatDays;
  final PuzzleType puzzleType;

  const Alarm({
    required this.id,
    required this.label,
    required this.hour,
    required this.minute,
    this.isEnabled = true,
    this.repeatDays = const {},
    this.puzzleType = PuzzleType.math,

  });

  String get timeLabel {
    final period = hour <12 ? 'AM' : 'PM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour -12 : hour);
    final displayMinute = minute.toString().padLeft(2, '0');
    return '$displayHour:$displayMinute $period';
  }

  String get repeatLabel {
    if (repeatDays.isEmpty) return 'Once';
    if (repeatDays.length == 7) return 'Every day';
    final weekdays = {Weekday.mon, Weekday.tue, Weekday.wed, Weekday.thu, Weekday.fri};
    final weekend = {Weekday.sat, Weekday.sun};
    if (repeatDays.containsAll(weekdays) && repeatDays.length == 5) return 'Weekdays';
    if (repeatDays.containsAll(weekend) && repeatDays.length == 2) return 'Weekends';
    const names = {
      Weekday.mon: 'Mon', Weekday.tue: 'Tue', Weekday.wed: 'Wed', Weekday.thu: 'Thu', Weekday.fri: 'Fri', Weekday.sat: 'Sat', Weekday.sun: "Sun",

    };
    return repeatDays.map((d) => names[d]!).join(', ');

  }

  Alarm copyWith({
    String? label, 
    int? hour,
    int? minute,
    bool? isEnabled,
    Set<Weekday>? repeatDays,
    PuzzleType? puzzleType,
  }) {
    return Alarm(
      id: id,
      label: label ?? this.label,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      isEnabled: isEnabled ?? this.isEnabled,
      repeatDays: repeatDays ?? this.repeatDays,
      puzzleType: puzzleType ?? this.puzzleType,


    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'hour': hour,
    'minute': minute, 
    'isEnabled': isEnabled,
    'repeatDays': repeatDays.map((d) => d.index).toList(),
    'puzzleType': puzzleType.index,
  };

  factory Alarm.fromJson(Map<String, dynamic> json) => Alarm(
    id: json['id'] as String,
    label: json['label'] as String,
    hour: json['hour'] as int,
    minute: json['minute'] as int,
    isEnabled: json['isEnabled'] as bool,
    repeatDays: (json['repeatDays'] as List).map((i) => Weekday.values[i as int]).toSet(),
    puzzleType: PuzzleType.values[json['puzzleType'] as int],
  );

  static List<Alarm> listFromJson(String source){
    final list = jsonDecode(source) as List;
    return list.map((e) => Alarm.fromJson(e as Map<String, dynamic>)).toList();

  }

  static String listToJson(List<Alarm> alarms) => jsonEncode(alarms.map((a) => a.toJson()).toList());
}