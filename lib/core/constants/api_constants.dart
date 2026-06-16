/// Configuration des URLs de l'API backend.
///
/// Pour basculer entre l'environnement local et la production,
/// changez simplement la valeur de [useLocal] à true ou false.
class ApiConstants {
  ApiConstants._();

  // ── URLs de base ────────────────────────────────────────────────
  /// URL du serveur local via ngrok
  static const String _localBaseUrl =
      'https://exclusively-untoppled-forest.ngrok-free.dev';

  /// URL du serveur en production (à définir)
    // ignore: unused_field
    static const String _productionBaseUrl =
      'https://votre-domaine-production.com';

  // ── URL active ──────────────────────────────────────────────────
  /// URL active utilisée dans toute l'application.
  /// Pour basculer, décommentez la ligne souhaitée :
  static const String baseUrl = _localBaseUrl; // Local
  // static const String baseUrl = _productionBaseUrl; // Production
}
