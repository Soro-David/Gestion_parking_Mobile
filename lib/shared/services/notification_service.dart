// Service central de gestion des notifications Firebase (FCM)
// Ce service gère : init Firebase, permissions, foreground/background,
// token management (save + refresh), et la navigation par data payload.

import 'dart:convert';
import 'dart:io';
import 'dart:ui' show Color;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:parking_mobile/core/routes/route_names.dart';
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

/// Handler isolé pour le tap sur une notification locale en background
/// DOIT être une fonction top-level
@pragma('vm:entry-point')
void _onBackgroundLocalNotificationTap(NotificationResponse details) {
  // En background, on ne peut pas naviguer directement ici.
  // La navigation sera déclenchée au prochain démarrage via onDidReceiveNotificationResponse.
  debugPrint('[LocalNotif Background Tap] payload: ${details.payload}');
}

class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();
  static AppNotification? pendingNotification;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Callback de navigation appelé quand l'utilisateur tape une notification
  /// Doit être injecté depuis main.dart (GoRouter n'est pas accessible ici)
  Function(String route, Map<String, dynamic>? data)? onNotificationTapped;

  // Canal Android pour les notifications foreground et background avec haute priorité et son
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'parking_high_importance_v3',
    'Notifications du Parking',
    description: 'Notifications importantes du parking',
    importance: Importance.max,
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
        // Tap depuis l'état foreground ou background → navigation vers le détail
        debugPrint('[LocalNotif] Tap reçu, payload: ${response.payload}');
        if (response.payload != null && response.payload!.isNotEmpty) {
          _navigateFromPayload(response.payload!);
        }
      },
      onDidReceiveBackgroundNotificationResponse: _onBackgroundLocalNotificationTap,
    );

    // Créer le canal Android haute priorité
    if (Platform.isAndroid) {
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(_channel);
      // Demander explicitement la permission d'afficher des notifications (requis sur Android 13+)
      await androidPlugin?.requestNotificationsPermission();
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
    final type = message.data['type'] as String?;

    // Vérifier si la catégorie est activée
    if (type != null && !await _isCategoryEnabled(type)) {
      debugPrint('[FCM Foreground] Catégorie $type désactivée, notification ignorée');
      return;
    }

    // Récupérer titre/corps depuis message.notification OU depuis message.data
    // (certains serveurs envoient des messages "data-only" sans objet notification)
    final title = message.notification?.title
        ?? message.data['title'] as String?
        ?? 'Nouvelle notification';
    final body = message.notification?.body
        ?? message.data['body'] as String?
        ?? '';

    debugPrint('[FCM Foreground] Affichage bannière: $title');

    // Construire le payload complet pour la navigation au tap
    final notifId = message.messageId
        ?? DateTime.now().millisecondsSinceEpoch.toString();
    final payloadMap = {
      'id': notifId,
      'title': title,
      'body': body,
      'type': type ?? '',
      'data': message.data,
    };

    // Ajouter dans le stream temps réel → badge de cloche
    try {
      final repo = NotificationRepositoryImpl();
      final appNotification = AppNotification(
        id: notifId,
        title: title,
        body: body,
        type: type,
        data: message.data,
        createdAt: DateTime.now(),
        isRead: false,
      );
      await repo.addRealtimeNotification(appNotification);
    } catch (e) {
      debugPrint('[FCM Foreground] Erreur ajout temps réel: $e');
    }

    // Afficher la bannière système via flutter_local_notifications
    await _localNotifications.show(
      id: notifId.hashCode,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFF2D6A4F),
          ticker: title,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(payloadMap),
    );
  }

  /// Gère le tap sur une notification (app en background ou terminée)
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('[FCM] Notification tappée: ${message.data}');
    final title = message.notification?.title ?? message.data['title'] ?? 'Notification';
    final body = message.notification?.body ?? message.data['body'] ?? '';
    final type = message.data['type'] ?? '';
    final payloadMap = {
      'id': message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'body': body,
      'type': type,
      'data': message.data,
    };
    _navigateFromPayload(jsonEncode(payloadMap));
  }

  /// Navigue vers le bon écran selon le type de notification
  void _navigateFromPayload(String payloadString) {
    try {
      final decoded = jsonDecode(payloadString) as Map<String, dynamic>;
      onNotificationTapped?.call(AppRoutes.notificationDetail, decoded);
    } catch (e) {
      debugPrint('[FCM] Erreur lors du parsing du payload de notification: $e');
      onNotificationTapped?.call('/notifications/history', null);
    }
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
