// Service central de gestion des notifications Firebase (FCM)
// Ce service gère : init Firebase, permissions, foreground/background,
// token management (save + refresh), et la navigation par data payload.

import 'dart:io';
import 'dart:ui' show Color;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:parking_mobile/shared/notifications/data/repositories/notification_repository_impl.dart';
import 'package:parking_mobile/shared/notifications/domain/entities/app_notification.dart';


/// Handler isolé pour les messages reçus en background (terminé ou suspendu)
/// DOIT être une fonction top-level (pas une méthode de classe)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // En background, Android affiche automatiquement la notification si
  // elle contient un champ "notification". Pas besoin de flutter_local_notifications.
  debugPrint('[FCM Background] ${message.notification?.title}');
}

class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Callback de navigation appelé quand l'utilisateur tape une notification
  /// Doit être injecté depuis main.dart (GoRouter n'est pas accessible ici)
  Function(String route, Map<String, dynamic>? data)? onNotificationTapped;

  // Canal Android pour les notifications foreground
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'parking_high_importance',
    'Parking Notifications',
    description: 'Notifications importantes du parking',
    importance: Importance.high,
    playSound: true,
  );

  /// Initialise Firebase, demande les permissions, configure les handlers
  Future<void> initialize() async {
    // 1. Demander les permissions (iOS + Android 13+)
    await _requestPermissions();

    // 2. Configurer les notifications locales (pour le foreground)
    await _initLocalNotifications();

    // 3. Enregistrer le handler background AVANT tout autre appel
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 4. Handler foreground — afficher une notification locale
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 5. Handler quand l'app est ouverte depuis une notification (background)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // 6. Vérifier si l'app a été ouverte depuis une notification terminée
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    // 7. Obtenir et sauvegarder le token FCM
    await getAndSaveToken();

    // 8. Écouter le renouvellement du token
    _setupTokenRefreshListener();

    debugPrint('[FCM] NotificationService initialisé');
  }

  /// Demande les permissions de notification
  Future<void> _requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );
    debugPrint('[FCM] Permissions: ${settings.authorizationStatus}');
  }

  /// Configure flutter_local_notifications pour afficher en foreground
  Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // L'utilisateur a tapé une notification locale
        if (response.payload != null) {
          _navigateFromPayload(response.payload!);
        }
      },
    );

    // Créer le canal Android haute priorité
    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);
    }

    // Forcer l'affichage des notifications en foreground sur iOS
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// Affiche une notification locale quand un message arrive en foreground
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('[FCM Foreground] ${message.notification?.title}');

    final notification = message.notification;
    if (notification == null) return;

    // Vérifier si la catégorie est activée
    final type = message.data['type'] as String?;
    if (type != null && !await _isCategoryEnabled(type)) {
      debugPrint('[FCM] Catégorie $type désactivée, notification ignorée');
      return;
    }

    // Ajouter aux notifications en temps réel localement
    try {
      final repo = NotificationRepositoryImpl();
      final appNotification = AppNotification(
        id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: notification.title ?? '',
        body: notification.body ?? '',
        type: type,
        data: message.data,
        createdAt: DateTime.now(),
        isRead: false,
      );
      await repo.addRealtimeNotification(appNotification);
    } catch (e) {
      debugPrint('[FCM] Erreur lors de l\'ajout de la notification en temps réel: $e');
    }

    await _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFF2D6A4F),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: _buildPayload(message.data),
    );
  }

  /// Gère le tap sur une notification (app en background ou terminée)
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('[FCM] Notification tappée: ${message.data}');
    final payload = _buildPayload(message.data);
    if (payload.isNotEmpty) {
      _navigateFromPayload(payload);
    }
  }

  /// Construit une string payload depuis les data du message
  String _buildPayload(Map<String, dynamic> data) {
    if (data.isEmpty) return '';
    final type = data['type'] ?? '';
    final id = data['id'] ?? '';
    return '$type:$id';
  }

  /// Navigue vers le bon écran selon le type de notification
  void _navigateFromPayload(String payload) {
    final parts = payload.split(':');
    final type = parts.isNotEmpty ? parts[0] : '';
    final id = parts.length > 1 ? parts[1] : '';

    final data = {'type': type, 'id': id};

    // Mapper le type vers la route go_router
    String route = '/notifications/history';
    switch (type) {
      case 'entree':
        route = '/notifications/history';
        break;
      case 'sortie':
        route = '/notifications/history';
        break;
      case 'versement':
        route = '/notifications/history';
        break;
      case 'paiement':
        route = '/notifications/history';
        break;
    }

    onNotificationTapped?.call(route, data);
  }

  /// Vérifie si une catégorie de notification est activée
  Future<bool> _isCategoryEnabled(String type) async {
    final repo = NotificationRepositoryImpl();
    final categories = await repo.getCategories();
    // Mapper le type FCM vers la catégorie locale
    final categoryMap = {
      'entree': 'entrees',
      'sortie': 'sorties',
      'paiement': 'paiements',
      'versement': 'versements',
      'rapport': 'rapports',
    };
    final category = categoryMap[type] ?? type;
    return categories[category] ?? true;
  }

  /// Obtient le token FCM et l'envoie au serveur Laravel
  Future<void> getAndSaveToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        debugPrint('[FCM] Token obtenu: ${token.substring(0, 20)}...');
        // Sauvegarder via le repository (qui appelle l'API Laravel)
        final repo = NotificationRepositoryImpl();
        await repo.saveToken(token);
      }
    } catch (e) {
      // Silencieux — la connexion peut ne pas être disponible au lancement
      debugPrint('[FCM] Impossible de sauvegarder le token: $e');
    }
  }

  /// Écoute les renouvellements de token et les envoie au serveur
  void _setupTokenRefreshListener() {
    _messaging.onTokenRefresh.listen((newToken) async {
      debugPrint('[FCM] Token renouvelé: ${newToken.substring(0, 20)}...');
      try {
        final repo = NotificationRepositoryImpl();
        await repo.saveToken(newToken);
      } catch (e) {
        debugPrint('[FCM] Erreur lors du renouvellement du token: $e');
      }
    });
  }

  /// Appeler à la connexion — met à jour le token sur le serveur
  Future<void> onUserLogin() async {
    await getAndSaveToken();
  }

  /// Appeler à la déconnexion — supprime le token du serveur
  Future<void> onUserLogout() async {
    try {
      final repo = NotificationRepositoryImpl();
      await repo.removeToken();
    } catch (e) {
      debugPrint('[FCM] Erreur lors de la suppression du token: $e');
    }
  }
}
