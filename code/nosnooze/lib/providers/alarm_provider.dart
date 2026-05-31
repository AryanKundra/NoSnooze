import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/alarm.dart';
import '../utils/notification_helper.dart';

// Class for managing our alarms, including local disk persistence, syncing notifications, 
// and allowing undo/redo via cache recording.
// Also creates the ChangeNotifier pattern for UI rebuilding.
class AlarmProvider extends ChangeNotifier {
  // Key identifier for locating alarm payload data in our local storage.
  static const _storageKey = 'nosnooze_alarms';
  // List of active alarms.
  List<Alarm> _alarms = [];
  // List stack holding history of the alarm's state for reversing changes.
  final List<List<Alarm>> _undoStack = [];
  // List stack holding history of the alarm's state for reimplementing changes.
  final List<List<Alarm>> _redoStack = [];

  // Getter for a read-only view of our current alarms.
  // Returns: Immutable list of alarms preventing external mutation.
  List<Alarm> get alarms => List.unmodifiable(_alarms);

  // Getter for checking if undoing is possible.
  // Returns: True if the stack history allows for us to reverse a change, False if not.
  bool get canUndo => _undoStack.isNotEmpty;
  
  // Getter for checking if redoing is possible.
  // Returns: True if the stack history allows for us to reimplement a change, False if not.
  bool get canRedo => _redoStack.isNotEmpty;

  // Method that keeps alarm by accessing our local storage and then syncing system schedules.
  // Returns: A Future post parsing the local data and scheduling routines.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      _alarms = Alarm.listFromJson(raw);
      notifyListeners();
      await _rescheduleAll();
    }
  }

  // Method that allocates our actively running list of alarms directly to disk storage.
  // Returns: A Future post local platform write.
  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, Alarm.listToJson(_alarms));
  }

  // Method for recording the status of an alarm onto the undo stack. 
  // This should also clear our redo history stack.
  void _snapshot() {
    _undoStack.add(List.of(_alarms));
    _redoStack.clear();
  }

  // Method that updates the overall status of our alarms, updating both disk storage and UI.
  // Parameters:
  //   - newState - The new list of alarms currently active.
  // Returns: A Future post serializing and system scheduling.
  Future<void> _apply(List<Alarm> newState) async {
    _alarms = newState;
    notifyListeners();
    await _persist();
    await _rescheduleAll();
  }

  // Method for allowing the operating system to sync background timers with our application data.
  // Returns: A Future post updating the notifications.
  Future<void> _rescheduleAll() async {
    await NotificationHelper.scheduleAllAlarms(_alarms);
  }

  // Method for posting another alarm to our records.
  // Parameters:
  //   - alarm - The new alarm to record.
  void addAlarm(Alarm alarm) {
    _snapshot();
    _apply([..._alarms, alarm]);
  }

  // Method for changing old alarm parameters with new ones.
  // Parameters:
  //   - updated - The alarm with the new properties.
  void updateAlarm(Alarm updated) {
    _snapshot();
    // Map the overall list with the new alarm in the correlating spot.
    _apply(_alarms.map((a) => a.id == updated.id ? updated : a).toList());
  }

  // Method for removing an alarm's record from memory.
  // Parameters:
  //   - id - Our identifier for locating the alarm to remove.
  void deleteAlarm(String id) {
    _snapshot();
    _apply(_alarms.where((a) => a.id != id).toList());
  }

  // Method for changing the active status of an existing alarm.
  // Parameters:
  //   - id: Our identifier for locating the alarm to toggle on/off.
  void toggleAlarm(String id) {
    _snapshot();
    // If there is a correlating ID, remake the state with the new status.
    _apply(_alarms.map((a) => a.id == id ? a.copyWith(isEnabled: !a.isEnabled) : a).toList());
  }

  // Method for revivng the data of the alarm just before the most recent change.
  void undo() {
    if (!canUndo) return;
    // Must save the current state to redo history before.
    _redoStack.add(List.of(_alarms));
    _apply(_undoStack.removeLast());
  }

  // Method for reimplementing the most recent change that was taken back via undo.
  void redo() {
    if (!canRedo) return;
    // Keep track of the stack history of undo before redoing.
    _undoStack.add(List.of(_alarms));
    _apply(_redoStack.removeLast());
  }

  // Method for getting an alarm using the identifier.
  // Parameters:
  //   - id - Our unqiue identifier for locating a specific alarm.
  // Returns: The correlating Alarm if there is one, null if not.
  Alarm? getAlarmById(String id) {
    try {
      return _alarms.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }
}