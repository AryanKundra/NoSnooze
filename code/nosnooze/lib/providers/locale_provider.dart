import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Class overseeing app localization and the status of our language settings.
// This provider changes the system language dynamically at runtime if needed, saving the preferred
// language to local disk data and notifying the UI so the text is updated.
class LocaleProvider extends ChangeNotifier {
  // What the local settings set the application language to, defaulting to english.
  Locale _locale = const Locale('en');

  // Getter for the active language and specified country status.
  // Returns: The locale being used currently.
  Locale get locale => _locale;

  // Creates the provider and starts a loading sequence so we can obtain the saved language 
  // settings from local disk.
  LocaleProvider() {
    _load();
  }

  // Method that reconfigures the apps locale status and locally preserves the change.
  // Parameters:
  //   - newLocale - User changes to the language and regional configuration.
  void setLocale(Locale newLocale) async {
    // Nothing to change if the both locales are the same.
    if (_locale == newLocale) return;
    _locale = newLocale;
    final prefs = await SharedPreferences.getInstance();
    // We will update the key-value list with the new language code.
    await prefs.setString('locale', newLocale.languageCode);
    notifyListeners();
  }

  // Method for bringing back the language payload that was saved to local disk storage.
  // Returns: A Future post observing the local disk and updating the app's state.
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('locale');
    // If there is a saved language code, remake the Locale and the UI.
    if (code != null) {
      _locale = Locale(code);
      notifyListeners();
    }
  }
}