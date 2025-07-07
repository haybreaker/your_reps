import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A generic wrapper for managing app settings using SharedPreferences.
class AppSettings {
  static SharedPreferences? _prefs;

  // Keys
  static const _pinnedExercisesKey = 'pinned_exercise_ids';
  static const _requiredRepsKey = 'pr_required_reps';
  static const _themePrimaryKey = 'theme_primary_color';
  static const _themeDarkKey = 'theme_dark_mode';

  /// Call once on app start (before usage)
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static void _ensureInitialized() {
    if (_prefs == null) {
      throw StateError(
        'AppSettings has not been initialized. Call AppSettings.init() in your main() function.',
      );
    }
  }

  // ───── Pinned Exercises ─────
  static Future<void> savePinnedExercises(List<int> exerciseIds) async {
    _ensureInitialized();
    final stringIds = exerciseIds.map((id) => id.toString()).toList();
    await _prefs!.setStringList(_pinnedExercisesKey, stringIds);
  }

  static List<int> getPinnedExercises() {
    _ensureInitialized();
    final stringIds = _prefs!.getStringList(_pinnedExercisesKey);
    if (stringIds == null) return [];
    try {
      return stringIds.map(int.parse).toList();
    } catch (_) {
      return [];
    }
  }

  // ───── Required Reps ─────
  static Future<void> saveRequiredReps(int repCount) async {
    _ensureInitialized();
    await _prefs!.setInt(_requiredRepsKey, repCount);
  }

  static int getRequiredReps() {
    _ensureInitialized();
    return _prefs!.getInt(_requiredRepsKey) ?? 1;
  }

  // ───── Theme Settings ─────
  static Future<void> saveTheme({
    required Color primary,
    required bool isDark,
  }) async {
    _ensureInitialized();
    await _prefs!.setInt(_themePrimaryKey, primary.value);
    await _prefs!.setBool(_themeDarkKey, isDark);
  }

  static ThemeData getTheme() {
    _ensureInitialized();

    final primaryValue = _prefs!.getInt(_themePrimaryKey);
    final isDark = _prefs!.getBool(_themeDarkKey) ?? false;

    final primaryColor = primaryValue != null ? Color(primaryValue) : Colors.redAccent; // Default if not saved

    return ThemeData(
      fontFamily: "OpenSans",
      colorSchemeSeed: primaryColor,
      brightness: isDark ? Brightness.dark : Brightness.light,
      useMaterial3: true,
    );
  }
}
