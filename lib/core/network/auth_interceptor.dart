import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:parking_mobile/main.dart';
import 'package:parking_mobile/core/services/token_service.dart';
import 'package:parking_mobile/core/routes/app_router.dart';
import 'package:parking_mobile/core/routes/route_names.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await TokenService.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;
    if (statusCode == 401 || statusCode == 403) {
      final message = statusCode == 401 
          ? 'Votre session a expiré. Veuillez vous reconnecter.'
          : 'Accès non autorisé.';

      // Supprimer le token stocké localement
      await TokenService.clearToken();

      // Afficher un message d'erreur global via ScaffoldMessenger
      scaffoldMessengerKey.currentState?.clearSnackBars();
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );

      // Rediriger vers l'écran de connexion
      AppRouter.router.go(AppRoutes.login);
    }
    super.onError(err, handler);
  }
}
