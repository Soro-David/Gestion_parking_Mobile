import 'package:dio/dio.dart';

class DioErrorHandler {
  DioErrorHandler._();

  static String message(DioException e, {String fallback = 'Erreur de communication'}) {
    if (e.response != null && e.response?.data != null) {
      final errorData = e.response?.data;
      if (errorData is Map<String, dynamic>) {
        return errorData['message'] ?? errorData['error'] ?? 'Erreur serveur';
      }
    }
    if (e.type == DioExceptionType.connectionTimeout) {
      return 'Délai d\'attente dépassé';
    }
    if (e.type == DioExceptionType.receiveTimeout) {
      return 'Délai de réponse du serveur dépassé';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Erreur de connexion internet';
    }
    return e.message ?? fallback;
  }

  static String loginMessage(DioException e) {
    var errorMessage = 'Erreur de connexion';
    if (e.response != null && e.response?.data != null) {
      final errorData = e.response?.data;
      if (errorData is Map<String, dynamic>) {
        errorMessage = errorData['message'] ?? errorData['error'] ?? errorMessage;
      }
    } else {
      if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Délai d\'attente dépassé lors de la connexion au serveur';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Délai de réponse du serveur dépassé';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Impossible de se connecter au serveur. Vérifiez votre connexion Internet';
      } else {
        errorMessage = e.message ?? errorMessage;
      }
    }
    return errorMessage;
  }
}
