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

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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

  if (navigatorKey.currentState != null) {
    navigate();
  } else {
    WidgetsBinding.instance.addPostFrameCallback((_) => navigate());
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    await alarm_pkg.Alarm.init();

    try {
      await NotificationHelper.init();
      await NotificationHelper.requestPermissions();
    } catch (e) {
      debugPrint('Notification init error (non-fatal): $e');
    }
  }

  final alarmProvider = AlarmProvider();
  await alarmProvider.load();

  int? coldStartAlarmId;
  String? coldStartAlarmUuid;
  if (!kIsWeb) {
    try {
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

    alarm_pkg.Alarm.ringing.listen((alarmSet) {
      final alarms = alarmSet.alarms as Iterable;
      if (alarms.isNotEmpty) {
        final settings = alarms.first as alarm_pkg.AlarmSettings;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _goToDismiss(settings.id, uuid: settings.payload);
        });
      }
    });
  }

  runApp(NoSnoozeApp(
    alarmProvider: alarmProvider,
    coldStartAlarmId: coldStartAlarmId,
    coldStartAlarmUuid: coldStartAlarmUuid,
  ));
}

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