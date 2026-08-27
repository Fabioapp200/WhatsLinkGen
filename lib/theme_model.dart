//theme_model.dart
import 'package:flutter/material.dart';

import 'theme_preference.dart';

class ThemeModel extends ChangeNotifier with WidgetsBindingObserver {
  bool _isDark;
  bool _hasManualPreference = false;
  final ThemePreferences _preferences = ThemePreferences();
  bool get isDark => _isDark;

  ThemeModel()
    : _isDark =
          WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark {
    WidgetsBinding.instance.addObserver(this);
    _loadPreference();
  }

  set isDark(bool value) {
    _isDark = value;
    _hasManualPreference = true;
    _preferences.setTheme(value);
    notifyListeners();
  }

  Future<void> _loadPreference() async {
    final savedTheme = await _preferences.getTheme();
    if (savedTheme != null) {
      _isDark = savedTheme;
      _hasManualPreference = true;
      notifyListeners();
    }
  }

  @override
  void didChangePlatformBrightness() {
    if (_hasManualPreference) {
      return;
    }

    _isDark =
        WidgetsBinding.instance.platformDispatcher.platformBrightness ==
        Brightness.dark;
    notifyListeners();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
