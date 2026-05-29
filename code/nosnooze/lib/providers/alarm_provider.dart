import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/alarm.dart';

class AlarmProvider extends ChangeNotifier {
  static const _storageKey = 'nosnooze_alarms';

  List<Alarm> _alarms = [];

  final List<List<Alarm>> _undoStack = [];
  final List<List<Alarm>> _redoStack = [];

  List<Alarm> get alarms => List.unmodifiable(_alarms);

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  Future<void> load() async{
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      _alarms = Alarm.listFromJson(raw);
      notifyListeners();
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, Alarm.listToJson(_alarms));
  }

  void _snapshot() {
    _undoStack.add(List.of(_alarms));
    _redoStack.clear();
  }

  void _apply(List<Alarm> newState) {
    _alarms = newState;
    notifyListeners();
    _persist();
  }

  void addAlarm(Alarm alarm) {
    _snapshot();
    _apply([..._alarms, alarm]);
  }

  void updateAlarm(Alarm updated) {
    _snapshot();
    _apply(_alarms.map((a) => a.id == updated.id ? updated: a).toList());
  }

  void deleteAlarm(String id){
    _snapshot();
    _apply(_alarms.where((a) => a.id != id).toList());

  }

  void toggleAlarm(String id) {
    _snapshot();
    _apply(_alarms.map((a) => a.id == id ? a.copyWith(isEnabled: !a.isEnabled): a).toList());
  }

  void undo(){
    if (!canUndo) return;
    _redoStack.add(List.of(_alarms));
    _apply(_undoStack.removeLast());
  }

  void redo(){
    if (!canRedo) return;
    _undoStack.add(List.of(_alarms));
    _apply(_redoStack.removeLast());
  }
}