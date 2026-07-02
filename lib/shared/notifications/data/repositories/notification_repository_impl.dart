// Implémentation du repository notifications (data layer)
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:parking_mobile/shared/notifications/data/datasources/notification_remote_datasource.dart';
import 'package:parking_mobile/shared/notifications/domain/entities/app_notification.dart';
import 'package:parking_mobile/shared/notifications/domain/repositories/notification_repository.dart';

/// Catégories de notifications disponibles
class NotificationCategories {
  static const String entrees = 'entrees';
  static const String sorties = 'sorties';
  static const String paiements = 'paiements';
  static const String versements = 'versements';
  static const String rapports = 'rapports';

  static const List<String> all = [
    entrees,
    sorties,
    paiements,
    versements,
    rapports,
  ];
}

class NotificationRepositoryImpl implements NotificationRepository {
  static final NotificationRepositoryImpl _instance = NotificationRepositoryImpl._internal();

  factory NotificationRepositoryImpl({NotificationRemoteDataSource? dataSource}) {
    if (dataSource != null) {
      return NotificationRepositoryImpl._internal(dataSource: dataSource);
    }
    return _instance;
  }

  NotificationRepositoryImpl._internal({NotificationRemoteDataSource? dataSource})
      : _dataSource = dataSource ?? NotificationRemoteDataSource();

  final NotificationRemoteDataSource _dataSource;

  // Internal list storing current notifications
  // STATIC — partagée entre toutes les instances (singleton ou non)
  static final List<AppNotification> _notifications = [];

  // Broadcast stream controller for real‑time updates
  // STATIC — partagé entre toutes les instances pour que tout abonné (NotificationCubit)
  // reçoive les événements émis par NotificationService (foreground FCM handler).
  static final StreamController<List<AppNotification>> _controller =
      StreamController<List<AppNotification>>.broadcast();

  static const String _prefixCategory = 'notif_category_';

  @override
  Stream<List<AppNotification>> get realtimeStream => _controller.stream;

  @override
  Future<void> addRealtimeNotification(AppNotification notification) async {
    _notifications.insert(0, notification);
    _controller.add(_notifications);
  }

  @override
  Future<void> saveToken(String token) async {
    await _dataSource.saveToken(token);
  }

  @override
  Future<void> removeToken() async {
    await _dataSource.removeToken();
  }

  static const String _deletedIdsKey = 'notif_deleted_ids';

  @override
  Future<List<AppNotification>> getNotificationHistory() async {
    try {
      final list = await _dataSource.getNotificationHistory();
      final prefs = await SharedPreferences.getInstance();
      final deletedIds = prefs.getStringList(_deletedIdsKey) ?? [];
      
      final filteredList = list.where((n) => !deletedIds.contains(n.id)).toList();
      
      // Update internal list and notify listeners
      _notifications
        ..clear()
        ..addAll(filteredList);
      _controller.add(_notifications);
      return filteredList;
    } catch (_) {
      // On error, clear list and emit empty list
      _notifications.clear();
      _controller.add(_notifications);
      return [];
    }
  }


  @override
  Future<void> markAsRead(String notificationId) async {
    await _dataSource.markAsRead(notificationId);
    // Also mark locally
    for (int i = 0; i < _notifications.length; i++) {
      if (_notifications[i].id == notificationId) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
    _controller.add(_notifications);
  }

  @override
  Future<void> markAllAsRead() async {
    await _dataSource.markAllAsRead();
    // Also mark locally
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    _controller.add(_notifications);
  }

  @override
  Future<Map<String, bool>> getCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final result = <String, bool>{};
    for (final category in NotificationCategories.all) {
      // Par défaut toutes les catégories sont activées
      result[category] = prefs.getBool('$_prefixCategory$category') ?? true;
    }
    return result;
  }

  @override
  Future<void> updateCategory(String category, bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_prefixCategory$category', enabled);
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    final prefs = await SharedPreferences.getInstance();
    final deletedIds = prefs.getStringList(_deletedIdsKey) ?? [];
    if (!deletedIds.contains(notificationId)) {
      deletedIds.add(notificationId);
      await prefs.setStringList(_deletedIdsKey, deletedIds);
    }
    _notifications.removeWhere((n) => n.id == notificationId);
    _controller.add(_notifications);
  }

  @override
  Future<void> deleteMultipleNotifications(List<String> notificationIds) async {
    final prefs = await SharedPreferences.getInstance();
    final deletedIds = prefs.getStringList(_deletedIdsKey) ?? [];
    for (final id in notificationIds) {
      if (!deletedIds.contains(id)) {
        deletedIds.add(id);
      }
    }
    await prefs.setStringList(_deletedIdsKey, deletedIds);
    _notifications.removeWhere((n) => notificationIds.contains(n.id));
    _controller.add(_notifications);
  }
}
