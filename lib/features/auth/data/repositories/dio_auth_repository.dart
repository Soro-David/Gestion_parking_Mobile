import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/token_service.dart';
import '../../../../shared/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';

class DioAuthRepository implements AuthRepository {
  final Dio _dio;

  DioAuthRepository({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConstants.baseUrl,
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
                headers: {
                  'Accept': 'application/json',
                  'Content-Type': 'application/json',
                },
              ),
            );

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: {
          'login': email,
          'password': password,
        },
      );

      final data = response.data;

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data is Map<String, dynamic>) {
          // Stockage du token s'il est présent dans la réponse
          final token = data['token'] ?? data['access_token'] ?? data['accessToken'];
          if (token != null && token is String) {
            await TokenService.saveToken(token);
          }

          if (data.containsKey('user')) {
            final userMap = Map<String, dynamic>.from(data['user'] as Map<String, dynamic>);
            if (data.containsKey('role')) {
              userMap['role'] = data['role'];
            }
            return UserModel.fromJson(userMap);
          } else if (data.containsKey('data')) {
            final dataMap = Map<String, dynamic>.from(data['data'] as Map<String, dynamic>);
            if (data.containsKey('role')) {
              dataMap['role'] = data['role'];
            }
            return UserModel.fromJson(dataMap);
          }
          return UserModel.fromJson(data);
        }
        throw Exception('Format de réponse invalide');
      } else {
        throw Exception('Échec de la connexion');
      }
    } on DioException catch (e) {
      String errorMessage = 'Erreur de connexion';
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
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Une erreur inattendue est survenue : ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      final token = await TokenService.getToken();
      
      final options = Options(
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      await _dio.post(
        '/api/auth/logout',
        options: options,
      );
    } catch (e) {
      // Si la déconnexion échoue côté serveur (ex: serveur indisponible ou erreur 500),
      // nous ignorons l'erreur pour forcer quand même la déconnexion locale de l'utilisateur.
    } finally {
      // Nettoyage impératif du jeton local dans tous les cas
      await TokenService.clearToken();
    }
  }

  @override
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final token = await TokenService.getToken();
      
      final options = Options(
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      final response = await _dio.get(
        '/api/auth/me',
        options: options,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          return response.data as Map<String, dynamic>;
        }
        throw Exception('Format de réponse de profil invalide');
      } else {
        throw Exception('Impossible de récupérer le profil');
      }
    } on DioException catch (e) {
      String errorMessage = 'Erreur lors de la récupération du profil';
      if (e.response != null && e.response?.data != null) {
        final errorData = e.response?.data;
        if (errorData is Map<String, dynamic>) {
          errorMessage = errorData['message'] ?? errorData['error'] ?? errorMessage;
        }
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Une erreur inattendue est survenue : ${e.toString().replaceAll('Exception: ', '')}');
    }
  }
}

