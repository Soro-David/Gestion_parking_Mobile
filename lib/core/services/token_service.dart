import 'package:shared_preferences/shared_preferences.dart';

/// Service pour stocker et récupérer le jeton d'authentification (JWT/Bearer token).
class TokenService {
  TokenService._();

  static const String _tokenKey = 'auth_token';

  /// Enregistre le token dans les préférences partagées.
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Récupère le token stocké.
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Supprime le token stocké (lors de la déconnexion).
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
