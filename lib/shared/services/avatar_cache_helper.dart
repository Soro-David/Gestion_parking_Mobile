import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AvatarCacheHelper {
  static const String _avatarUrlKey = 'cached_avatar_url';
  static const String _avatarLocalPathKey = 'cached_avatar_local_path';

  static String? _localPathCache;
  static String? _urlCache;

  /// Initialise le cache mémoire synchrone au démarrage
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _localPathCache = prefs.getString(_avatarLocalPathKey);
      _urlCache = prefs.getString(_avatarUrlKey);
      
      // Nettoyage de sécurité si le fichier n'existe plus physiquement
      if (_localPathCache != null) {
        final file = File(_localPathCache!);
        if (!file.existsSync()) {
          _localPathCache = null;
          _urlCache = null;
          await prefs.remove(_avatarUrlKey);
          await prefs.remove(_avatarLocalPathKey);
        }
      }
      debugPrint('[AvatarCache] Initialisé avec URL: $_urlCache et chemin local: $_localPathCache');
    } catch (e) {
      debugPrint('[AvatarCache] Erreur initialisation: $e');
    }
  }

  /// Retourne un FileImage provider si l'avatar est en cache locale
  static ImageProvider? getLocalAvatarProvider() {
    if (_localPathCache != null && _localPathCache!.isNotEmpty) {
      final file = File(_localPathCache!);
      if (file.existsSync()) {
        return FileImage(file);
      }
    }
    return null;
  }

  /// Fournit le meilleur ImageProvider (priorité cache local, puis réseau)
  static ImageProvider getAvatarImageProvider(String? url) {
    final localProvider = getLocalAvatarProvider();
    if (localProvider != null) {
      return localProvider;
    }
    if (url != null && url.isNotEmpty) {
      return NetworkImage(url);
    }
    // Fallback pour typage, le widget affichera l'icône de toute façon
    return const AssetImage('assets/logos/app_icon_padded.png');
  }

  /// Télécharge et met en cache l'avatar si l'URL réseau a changé
  static Future<ImageProvider?> cacheAvatarIfNeeded(String? url) async {
    if (url == null || url.isEmpty) {
      await invalidateCache();
      return null;
    }

    // Si l'URL correspond à notre cache et que le fichier est valide
    if (url == _urlCache && _localPathCache != null) {
      final file = File(_localPathCache!);
      if (file.existsSync()) {
        return FileImage(file);
      }
    }

    // Sinon, téléchargement
    try {
      final dio = Dio();
      final directory = await getApplicationDocumentsDirectory();
      
      // Extension de l'image
      String ext = 'png';
      try {
        final uri = Uri.parse(url);
        final pathSegments = uri.pathSegments;
        if (pathSegments.isNotEmpty) {
          final fileNamePart = pathSegments.last;
          if (fileNamePart.contains('.')) {
            ext = fileNamePart.split('.').last;
          }
        }
      } catch (_) {}

      final localPath = '${directory.path}/avatar_${DateTime.now().millisecondsSinceEpoch}.$ext';

      debugPrint('[AvatarCache] Téléchargement de la nouvelle image: $url vers $localPath');
      await dio.download(url, localPath);

      // Suppression de l'ancienne image
      if (_localPathCache != null) {
        final oldFile = File(_localPathCache!);
        if (oldFile.existsSync()) {
          oldFile.deleteSync();
        }
      }

      // Mise à jour de shared preferences et des caches
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_avatarUrlKey, url);
      await prefs.setString(_avatarLocalPathKey, localPath);

      _localPathCache = localPath;
      _urlCache = url;

      return FileImage(File(localPath));
    } catch (e) {
      debugPrint('[AvatarCache] Échec téléchargement / mise en cache: $e');
      // Retourner le cache existant s'il y en a un
      return getLocalAvatarProvider();
    }
  }

  /// Invalide et supprime le cache local
  static Future<void> invalidateCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_localPathCache != null) {
        final file = File(_localPathCache!);
        if (file.existsSync()) {
          file.deleteSync();
        }
      }
      await prefs.remove(_avatarUrlKey);
      await prefs.remove(_avatarLocalPathKey);
      _localPathCache = null;
      _urlCache = null;
      debugPrint('[AvatarCache] Cache invalidé avec succès');
    } catch (e) {
      debugPrint('[AvatarCache] Erreur lors de l\'invalidation: $e');
    }
  }
}
