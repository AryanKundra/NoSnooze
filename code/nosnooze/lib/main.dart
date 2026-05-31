import 'package:alarm/alarm.dart' as alarm_pkg;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'generated/app_localizations.dart';
import 'providers/alarm_provider.dart';
import 'providers/locale_provider.dart';
import 'screens/home_screen.dart';
import 'screens/alarm_dismiss_screen.dart';
import 'utils/notification_helper.dart';

// Key for referencing the application's root navigator state across static contexts.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Method that shifts application focus to the puzzle-locking alarm termination view.
// Removes preceding navigation stacks up to the primary app to stop bypass.
// Parameters:
//   - alarmIntId - The hashed 32-bit positive integer identifier given by the underlying OS.
//   - uuid - Optional matching domain model String code payload for the unique alarm.
void _goToDismiss(int alarmIntId, {String? uuid}) {
  void navigate() {
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => AlarmDismissScreen(
          alarmIntId: alarmIntId,
          alarmUuid: uuid,
        ),
      ),
      (route) => route.isFirst,
    );
  }
  // Defer execution using frame callbacks if the visual context is not yet loaded.
  if (navigatorKey.currentState != null) {
    navigate();
  } else {
    WidgetsBinding.instance.addPostFrameCallback((_) => navigate());
  }
}

// Where the main program will be executed. Sets up the device bindings, loads 
// background hardware preferences, evaluates default start conditions, hooks runtime event 
// stream listeners, and mounts the base widget trees.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Establish local OS configurations when deployed inside device application instead of web.
  if (!kIsWeb) {
    await alarm_pkg.Alarm.init();

    try {
      await NotificationHelper.init();
      await NotificationHelper.requestPermissions();
    } catch (e) {
      debugPrint('Notification init error (non-fatal): $e');
    }
  }
  // Instantiate the provider and load back the localized system logs.
  final alarmProvider = AlarmProvider();
  await alarmProvider.load();

  int? coldStartAlarmId;
  String? coldStartAlarmUuid;
  if (!kIsWeb) {
    try {
      // Check whether the app boot sequence was called by an OS wake alarm.
      final ringing = await alarm_pkg.Alarm.getAlarms();
      for (final s in ringing) {
        if (await alarm_pkg.Alarm.isRinging(s.id)) {
          coldStartAlarmId = s.id;
          coldStartAlarmUuid = s.payload;
          break;
        }
      }
    } catch (e) {
      debugPrint('Cold-start alarm check error (non-fatal): $e');
    }
    // Subscribe to stream hooks evaluating hardware timer interrupt signals at runtime.
    alarm_pkg.Alarm.ringing.listen((alarmSet) {
      final alarms = alarmSet.alarms as Iterable;
      if (alarms.isNotEmpty) {
        final settings = alarms.first as alarm_pkg.AlarmSettings;
        // Schedule navigation as a macro task.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _goToDismiss(settings.id, uuid: settings.payload);
        });
      }
    });
  }

  // Wrapper for the framework managing fundamental structural app setups.
  // Registers top-tier app states, localizations, layout designs, and intercepts device 
  // system startup hooks.
  runApp(NoSnoozeApp(
    alarmProvider: alarmProvider,
    coldStartAlarmId: coldStartAlarmId,
    coldStartAlarmUuid: coldStartAlarmUuid,
  ));
}

// Constructor for the application root widget profile state.
// Parameters:
//   - alarmProvider - The provider with the app's reactive business logic engine.
//   - coldStartAlarmId - Optional target key from boot sequences.
//   - coldStartAlarmUuid - Optional targeting tracking payload.
class NoSnoozeApp extends StatefulWidget {
  final AlarmProvider alarmProvider;
  final int? coldStartAlarmId;
  final String? coldStartAlarmUuid;

  const NoSnoozeApp({
    super.key,
    required this.alarmProvider,
    this.coldStartAlarmId,
    this.coldStartAlarmUuid,
  });

  @override
  State<NoSnoozeApp> createState() => _NoSnoozeAppState();
}

// Manages the mutable operational tracking lifecycles given to the root widget components.
class _NoSnoozeAppState extends State<NoSnoozeApp> {
  @override
  void initState() {
    super.initState();
    if (widget.coldStartAlarmId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _goToDismiss(widget.coldStartAlarmId!, uuid: widget.coldStartAlarmUuid);
      });
    }
  }

  // Build for the functional component tree including translation services, themes, 
  // and multi-provider dependencies.
  // Parameters:
  //   - context - Structural contextual location data inside the element hierarchy.
  // Returns: A localized MaterialApp widget tree structure.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AlarmProvider>.value(value: widget.alarmProvider),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: Consumer<LocaleProvider>(
        builder: (ctx, localeProvider, _) {
          return MaterialApp(
            title: 'NoSnooze',
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            locale: localeProvider.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('es')],
            theme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xFF000000),
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFFFF9F0A),
                surface: Color(0xFF1C1C1E),
              ),
              useMaterial3: true,
            ),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}