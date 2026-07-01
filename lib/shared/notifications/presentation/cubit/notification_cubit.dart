// Cubit de gestion des notifications
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_mobile/shared/notifications/data/repositories/notification_repository_impl.dart';
import 'package:parking_mobile/shared/notifications/domain/repositories/notification_repository.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit({NotificationRepository? repository})
      : _repository = repository ?? NotificationRepositoryImpl(),
        super(const NotificationInitial()) {
    _subscription = _repository.realtimeStream.listen((notifications) {
      final current = state;
      if (current is NotificationLoaded) {
        emit(current.copyWith(
          notifications: notifications,
          unreadCount: notifications.where((n) => !n.isRead).length,
        ));
      }
    });
    // Load initial notifications and categories
    loadNotifications();
  }

  final NotificationRepository _repository;
  late final StreamSubscription _subscription;

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }

  Future<void> loadNotifications() async {
    final current = state;
    if (current is! NotificationLoaded) {
      emit(const NotificationLoading());
    }
    try {
      final notifications = await _repository.getNotificationHistory();
      final categories = await _repository.getCategories();
      final unreadCount = notifications.where((n) => !n.isRead).length;

      emit(NotificationLoaded(
        notifications: notifications,
        categories: categories,
        unreadCount: unreadCount,
      ));
    } catch (e) {
      if (current is! NotificationLoaded) {
        emit(NotificationError(e.toString()));
      }
    }
  }

  /// Marque une notification comme lue
  Future<void> markAsRead(String notificationId) async {
    try {
      await _repository.markAsRead(notificationId);
      final current = state;
      if (current is NotificationLoaded) {
        final updated = current.notifications.map((n) {
          if (n.id == notificationId) return n.copyWith(isRead: true);
          return n;
        }).toList();
        emit(current.copyWith(
          notifications: updated,
          unreadCount: updated.where((n) => !n.isRead).length,
        ));
      }
    } catch (_) {}
  }

  /// Marque toutes les notifications comme lues
  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
      final current = state;
      if (current is NotificationLoaded) {
        final updated = current.notifications
            .map((n) => n.copyWith(isRead: true))
            .toList();
        emit(current.copyWith(notifications: updated, unreadCount: 0));
      }
    } catch (_) {}
  }

  /// Met à jour une catégorie de notification
  Future<void> updateCategory(String category, bool enabled) async {
    try {
      await _repository.updateCategory(category, enabled);
      final current = state;
      if (current is NotificationLoaded) {
        final updatedCategories = Map<String, bool>.from(current.categories);
        updatedCategories[category] = enabled;
        emit(current.copyWith(categories: updatedCategories));
      }
    } catch (_) {}
  }

  /// Charge uniquement les catégories
  Future<void> loadCategories() async {
    try {
      final categories = await _repository.getCategories();
      final current = state;
      if (current is NotificationLoaded) {
        emit(current.copyWith(categories: categories));
      } else {
        emit(NotificationLoaded(
          notifications: const [],
          categories: categories,
        ));
      }
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  /// Supprime une notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _repository.deleteNotification(notificationId);
      final current = state;
      if (current is NotificationLoaded) {
        final updated = current.notifications.where((n) => n.id != notificationId).toList();
        emit(current.copyWith(
          notifications: updated,
          unreadCount: updated.where((n) => !n.isRead).length,
        ));
      }
    } catch (_) {}
  }

  /// Supprime plusieurs notifications
  Future<void> deleteMultipleNotifications(List<String> notificationIds) async {
    try {
      await _repository.deleteMultipleNotifications(notificationIds);
      final current = state;
      if (current is NotificationLoaded) {
        final updated = current.notifications.where((n) => !notificationIds.contains(n.id)).toList();
        emit(current.copyWith(
          notifications: updated,
          unreadCount: updated.where((n) => !n.isRead).length,
        ));
      }
    } catch (_) {}
  }
}
