// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'NoSnooze';

  @override
  String get alarmsTab => 'Alarmas';

  @override
  String get settingsTab => 'Ajustes';

  @override
  String get addAlarm => 'Añadir alarma';

  @override
  String get editAlarm => 'Editar alarma';

  @override
  String get deleteAlarm => 'Eliminar';

  @override
  String get save => 'Guardar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get puzzleTitle => 'Resuelve para apagar';

  @override
  String get puzzleInstructions => 'Resuelve el acertijo para apagar la alarma';

  @override
  String get correct => '¡Correcto! Alarma apagada.';

  @override
  String get incorrect => 'Respuesta incorrecta — ¡inténtalo de nuevo!';

  @override
  String get snoozeNotAllowed => 'Sin posponer. ¡Resuelve el acertijo!';

  @override
  String get alarmLabel => 'Etiqueta';

  @override
  String get alarmTime => 'Hora';

  @override
  String get repeatDays => 'Repetir';

  @override
  String get puzzleType => 'Tipo de acertijo';

  @override
  String get mathPuzzle => 'Matemáticas';

  @override
  String get triviaPuzzle => 'Trivia';

  @override
  String get patternPuzzle => 'Patrón';

  @override
  String get shakeHint => '¡Agita para una pista!';

  @override
  String get noAlarmsYet => 'No hay alarmas.\nToca + para añadir una.';

  @override
  String get alarmEnabled => 'Alarma activada';

  @override
  String get alarmDisabled => 'Alarma desactivada';
}
