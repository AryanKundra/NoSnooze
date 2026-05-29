import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'generated/app_localizations.dart';

import 'providers/alarm_provider.dart';
import 'screens/home_screen.dart';
import 'utils/notification_helper.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationHelper.init();
  runApp(const NoSnoozeApp());
}

class NoSnoozeApp extends StatelessWidget {
  const NoSnoozeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AlarmProvider()..load(),
      child: MaterialApp(
        title: 'NoSnooze',
        debugShowCheckedModeBanner: false,

        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('es'),
        ],

        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF000000),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFFF9F0A),
            surface: Color(0xFF1C1C1E),
            background: Color(0xFF000000),
          ),
          useMaterial3: true,
          listTileTheme: const ListTileThemeData(
            tileColor: Colors.transparent,
          ),
          dividerColor: const Color(0xFF38383A),
          dividerTheme: const DividerThemeData(
            color: Color(0xFF38383A),
            thickness: 0.5,
            space: 1,
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}