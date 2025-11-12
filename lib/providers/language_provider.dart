import 'package:flutter/material.dart';

/// Provider to manage language/locale state across the app
class LanguageProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('en');

  Locale get currentLocale => _currentLocale;

  /// Set the locale and notify listeners
  void setLocale(Locale locale) {
    if (_currentLocale != locale) {
      _currentLocale = locale;
      notifyListeners();
    }
  }

  /// Toggle between English and Bengali
  void toggleLanguage() {
    if (_currentLocale.languageCode == 'en') {
      setLocale(const Locale('bn'));
    } else {
      setLocale(const Locale('en'));
    }
  }
}
