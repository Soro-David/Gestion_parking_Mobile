import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsManager extends ChangeNotifier {
  static final AppSettingsManager instance = AppSettingsManager._();
  AppSettingsManager._();

  static const String _themeKey = 'app_theme_mode';
  static const String _langKey = 'app_language';

  ThemeMode _themeMode = ThemeMode.dark; // Par défaut sombre
  String _languageCode = 'fr'; // Par défaut français

  ThemeMode get themeMode => _themeMode;
  String get languageCode => _languageCode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Charge les préférences enregistrées localement au démarrage.
  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Chargement du thème
      final themeStr = prefs.getString(_themeKey);
      if (themeStr == 'light') {
        _themeMode = ThemeMode.light;
      } else {
        _themeMode = ThemeMode.dark;
      }

      // Chargement de la langue
      _languageCode = prefs.getString(_langKey) ?? 'fr';
      
      notifyListeners();
    } catch (e) {
      debugPrint('AppSettingsManager: Erreur lors du chargement des paramètres : $e');
    }
  }

  /// Change le thème de l'application et le sauvegarde localement.
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, mode == ThemeMode.light ? 'light' : 'dark');
    } catch (e) {
      debugPrint('AppSettingsManager: Erreur lors de la sauvegarde du thème : $e');
    }
  }

  /// Change la langue de l'application et la sauvegarde localement.
  Future<void> setLanguage(String langCode) async {
    if (_languageCode == langCode) return;
    _languageCode = langCode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_langKey, langCode);
    } catch (e) {
      debugPrint('AppSettingsManager: Erreur lors de la sauvegarde de la langue : $e');
    }
  }
}
