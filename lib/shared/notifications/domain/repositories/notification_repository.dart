// Contrat du repository notifications (domain layer)
import '../entities/app_notification.dart';

abstract class NotificationRepository {
  /// Stream des nouvelles notifications reçues en temps réel
  Stream<List<AppNotification>> get realtimeStream;

  /// Ajoute une notification au stream (utilisé par le service FCM)
  Future<void> addRealtimeNotification(AppNotification notification);

  /// Sauvegarde le token FCM sur le serveur Laravel
  Future<void> saveToken(String token);

  /// Supprime le token FCM du serveur (à la déconnexion)
  Future<void> removeToken();

  /// Récupère l'historique des notifications depuis Laravel
  Future<List<AppNotification>> getNotificationHistory();

  /// Marque une notification comme lue
  Future<void> markAsRead(String notificationId);

  /// Marque toutes les notifications comme lues
  Future<void> markAllAsRead();

  /// Récupère les préférences de catégories (stockées localement)
  Future<Map<String, bool>> getCategories();

  /// Met à jour une catégorie de notification
  Future<void> updateCategory(String category, bool enabled);

  /// Supprime une notification localement
  Future<void> deleteNotification(String notificationId);

  /// Supprime plusieurs notifications localement
  Future<void> deleteMultipleNotifications(List<String> notificationIds);
}
