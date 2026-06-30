// Data source pour les appels API notifications
import 'package:dio/dio.dart';
import 'package:parking_mobile/core/network/dio_client.dart';
import 'package:parking_mobile/core/network/dio_error_handler.dart';
import 'package:parking_mobile/core/network/remote_api_helper.dart';
import 'package:parking_mobile/shared/notifications/domain/entities/app_notification.dart';

class NotificationRemoteDataSource {
  NotificationRemoteDataSource({Dio? dio})
      : _dio = DioClient.create(dio),
        _api = RemoteApiHelper(DioClient.create(dio));

  final Dio _dio;
  final RemoteApiHelper _api;

  /// Envoie le token FCM au serveur Laravel pour stockage
  Future<void> saveToken(String token) async {
    try {
      final options = await _api.authOptions();
      await _dio.post(
        '/api/notifications/token',
        data: {'fcm_token': token},
        options: options,
      );
    } on DioException catch (e) {
      // Ne pas bloquer si le serveur est injoignable (première connexion offline)
      throw Exception(DioErrorHandler.message(e));
    }
  }

  /// Supprime le token FCM du serveur (lors de la déconnexion)
  Future<void> removeToken() async {
    try {
      final options = await _api.authOptions();
      await _dio.delete('/api/notifications/token', options: options);
    } on DioException catch (e) {
      throw Exception(DioErrorHandler.message(e));
    }
  }

  /// Récupère l'historique des notifications depuis Laravel
  Future<List<AppNotification>> getNotificationHistory() async {
    try {
      final options = await _api.authOptions();
      final response = await _api.getWithFallback(
        '/notifications/history',
        options: options,
      );
      if (response.statusCode == 200) {
        final list = RemoteApiHelper.extractList(
          response.data,
          keys: const ['data', 'notifications', 'results'],
        );
        return list.map(AppNotification.fromJson).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(DioErrorHandler.message(e));
    }
  }

  /// Marque une notification comme lue
  Future<void> markAsRead(String notificationId) async {
    try {
      final options = await _api.authOptions();
      await _dio.post(
        '/api/notifications/mark-read/$notificationId',
        options: options,
      );
    } on DioException catch (e) {
      throw Exception(DioErrorHandler.message(e));
    }
  }

  /// Marque toutes les notifications comme lues
  Future<void> markAllAsRead() async {
    try {
      final options = await _api.authOptions();
      await _dio.post('/api/notifications/mark-all-read', options: options);
    } on DioException catch (e) {
      throw Exception(DioErrorHandler.message(e));
    }
  }
}
