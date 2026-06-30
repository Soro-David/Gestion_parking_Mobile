// États du Cubit de notifications
import 'package:equatable/equatable.dart';
import 'package:parking_mobile/shared/notifications/domain/entities/app_notification.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

class NotificationLoaded extends NotificationState {
  final List<AppNotification> notifications;
  final Map<String, bool> categories;
  final int unreadCount;

  const NotificationLoaded({
    required this.notifications,
    required this.categories,
    this.unreadCount = 0,
  });

  NotificationLoaded copyWith({
    List<AppNotification>? notifications,
    Map<String, bool>? categories,
    int? unreadCount,
  }) {
    return NotificationLoaded(
      notifications: notifications ?? this.notifications,
      categories: categories ?? this.categories,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override
  List<Object?> get props => [notifications, categories, unreadCount];
}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}
