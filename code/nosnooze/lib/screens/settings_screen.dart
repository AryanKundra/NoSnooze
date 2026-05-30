import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/analog_clock.dart';
import '../providers/locale_provider.dart';
import '../generated/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(l10n.settingsTab),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.language,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                DropdownButton<Locale>(
                  value: localeProvider.locale,
                  dropdownColor: const Color(0xFF1C1C1E),
                  style: const TextStyle(color: Colors.white),
                  items: const [
                    DropdownMenuItem(value: Locale('en'), child: Text('English')),
                    DropdownMenuItem(value: Locale('es'), child: Text('Español')),
                  ],
                  onChanged: (loc) {
                    if (loc != null) localeProvider.setLocale(loc);
                  },
                ),
              ],
            ),
            const SizedBox(height: 40),
            Center(
              child: Column(
                children: [
                  Text(
                    l10n.analogClock,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  const AnalogClockWidget(size: 180),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}