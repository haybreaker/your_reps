import 'package:flutter/material.dart';
import 'package:your_reps/data/settings/app_settings.dart';

class AppSettingsProvider extends ChangeNotifier {
  late ThemeData _theme;
  late Color _primaryColor;
  late bool _isDarkMode;
  late List<int> _pinnedExercises;
  late int _requiredReps;

  AppSettingsProvider() {
    loadFromPrefs();
  }

  /// Call this in your main after AppSettings.init()
  Future<void> loadFromPrefs() async {
    _theme = AppSettings.getTheme();
    _isDarkMode = _theme.brightness == Brightness.dark;
    _primaryColor = _theme.colorScheme.primary;
    _pinnedExercises = AppSettings.getPinnedExercises();
    _requiredReps = AppSettings.getRequiredReps();
    notifyListeners(); // Even if other consumers only use requiredReps
  }

  ThemeData get theme => _theme;
  Color get primaryColor => _primaryColor;
  bool get isDarkMode => _isDarkMode;
  List<int> get pinnedExercises => _pinnedExercises;
  int get requiredReps => _requiredReps;

  void setPinnedExercises(List<int> exercises) {
    _pinnedExercises = exercises;
    AppSettings.savePinnedExercises(exercises);
    notifyListeners();
  }

  void setTheme(Color color, bool darkMode) {
    _primaryColor = color;
    _isDarkMode = darkMode;
    _theme = ThemeData(
      colorSchemeSeed: _primaryColor,
      brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      useMaterial3: true,
    );
    AppSettings.saveTheme(isDark: _isDarkMode, primary: _primaryColor);
    notifyListeners();
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    setTheme(_primaryColor, _isDarkMode);
  }

  void setRequiredReps(int reps) {
    _requiredReps = reps;
    AppSettings.saveRequiredReps(reps);
    notifyListeners();
  }
}
