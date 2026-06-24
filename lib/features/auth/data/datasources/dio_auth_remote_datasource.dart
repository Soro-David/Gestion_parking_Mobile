import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/network/dio_error_handler.dart';
import '../../../../core/services/token_service.dart';
import 'package:parking_mobile/shared/data/models/user_model.dart';
import 'auth_remote_datasource.dart';

class DioAuthRemoteDataSource implements AuthRemoteDataSource {
  DioAuthRemoteDataSource({Dio? dio}) : _dio = DioClient.create(dio);

  final Dio _dio;

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

      debugPrint('Login response data: $data');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data is Map<String, dynamic>) {
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
      throw Exception(DioErrorHandler.loginMessage(e));
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
    } catch (_) {
      // Force local logout even if server call fails.
    } finally {
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
      throw Exception(DioErrorHandler.message(e, fallback: 'Erreur lors de la récupération du profil'));
    } catch (e) {
      throw Exception('Une erreur inattendue est survenue : ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  @override
  Future<UserModel> updateProfile({
    required String name,
    String? firstName,
    required String email,
    String? phone,
    String? address,
    String? password,
    String? avatarPath,
  }) async {
    try {
      final token = await TokenService.getToken();

      final options = Options(
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      final formData = FormData.fromMap({
        'name': name,
        'email': email,
        if (firstName != null && firstName.isNotEmpty) 'first_name': firstName,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (address != null && address.isNotEmpty) 'address': address,
        if (password != null && password.isNotEmpty) 'password': password,
      });

      if (avatarPath != null && avatarPath.isNotEmpty) {
        formData.files.add(MapEntry(
          'avatar',
          await MultipartFile.fromFile(avatarPath),
        ));
      }

      final response = await _dio.post(
        '/api/auth/profile',
        data: formData,
        options: options,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('user')) {
          final userMap = Map<String, dynamic>.from(data['user'] as Map<String, dynamic>);
          if (data.containsKey('role')) {
            userMap['role'] = data['role'];
          }
          return UserModel.fromJson(userMap);
        }
        throw Exception('Format de réponse invalide lors de la mise à jour');
      } else {
        throw Exception('Échec de la mise à jour du profil');
      }
    } on DioException catch (e) {
      throw Exception(DioErrorHandler.message(e, fallback: 'Erreur lors de la mise à jour du profil'));
    } catch (e) {
      throw Exception('Une erreur inattendue est survenue : ${e.toString().replaceAll('Exception: ', '')}');
    }
  }
}
