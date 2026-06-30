import 'package:flutter/material.dart';
import '../services/settings_manager.dart';

class AppTranslations {
  static const Map<String, Map<String, String>> _localizedValues = {
    'fr': {
      'settings': 'Paramètres',
      'settings_agent': 'Paramètres Agent',
      'settings_caissier': 'Paramètres Caissier',
      'preferences_desc': 'Préférences et sécurité de l\'application.',
      'language': 'Langue',
      'language_desc': 'Langue sélectionnée : ',
      'appearance': 'Apparence',
      'appearance_desc': 'Thème sélectionné : ',
      'light_theme': 'Thème clair',
      'dark_theme': 'Thème sombre',
      'french': 'Français',
      'english': 'English',
      'save_success': 'Préférences enregistrées avec succès',
      'save_error': 'Erreur lors de l\'enregistrement',
      'loading': 'Enregistrement...',
      'profile': 'Profil',
      'notifications': 'Notifications',
      'security': 'Sécurité',
      'logout': 'Déconnexion',
      'cancel': 'Annuler',
      'confirm': 'Confirmer',
      'account_security_section': 'Compte & Sécurité',
      'preferences_section': 'Préférences',
      'actions_section': 'Actions',
      'logout_confirm_title': 'Déconnexion',
      'logout_confirm_desc': 'Êtes-vous sûr de vouloir vous déconnecter ?',
      'profile_agent': 'Profil agent',
      'profile_caissier': 'Profil caissier',
    },
    'en': {
      'settings': 'Settings',
      'settings_agent': 'Agent Settings',
      'settings_caissier': 'Cashier Settings',
      'preferences_desc': 'Application preferences and security.',
      'language': 'Language',
      'language_desc': 'Selected language: ',
      'appearance': 'Appearance',
      'appearance_desc': 'Selected theme: ',
      'light_theme': 'Light Theme',
      'dark_theme': 'Dark Theme',
      'french': 'French',
      'english': 'English',
      'save_success': 'Preferences saved successfully',
      'save_error': 'Error while saving',
      'loading': 'Saving...',
      'profile': 'Profile',
      'notifications': 'Notifications',
      'security': 'Security',
      'logout': 'Logout',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'account_security_section': 'Account & Security',
      'preferences_section': 'Preferences',
      'actions_section': 'Actions',
      'logout_confirm_title': 'Logout',
      'logout_confirm_desc': 'Are you sure you want to log out ?',
      'profile_agent': 'Agent profile',
      'profile_caissier': 'Cashier profile',
    }
  };

  static String translate(BuildContext context, String key) {
    final langCode = AppSettingsManager.instance.languageCode;
    return _localizedValues[langCode]?[key] ?? key;
  }
}

extension TranslationExtension on BuildContext {
  String translate(String key) => AppTranslations.translate(this, key);
}
