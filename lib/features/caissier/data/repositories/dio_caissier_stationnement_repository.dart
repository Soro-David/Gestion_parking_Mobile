import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/token_service.dart';
import '../../../../shared/models/parking_entry_model.dart';
import '../../domain/repositories/caissier_stationnement_repository.dart';
import 'package:cross_file/cross_file.dart';
import 'package:camera/camera.dart';
class DioCaissierStationnementRepository implements CaissierStationnementRepository {
  final Dio _dio;

  DioCaissierStationnementRepository({Dio? dio})
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

  Future<Response> _getWithFallback(String path, Options options) async {
    try {
      // First try with /api prefix
      return await _dio.get(
        '/api$path',
        options: options,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // Fallback to path without /api prefix
        return await _dio.get(
          path,
          options: options,
        );
      }
      rethrow;
    }
  }

  @override
  Future<List<ParkingEntryModel>> getStationnementsEnCours() async {
    try {
      final token = await TokenService.getToken();
      final options = Options(
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      final response = await _getWithFallback('/caissier/parking-sessions/stationnement_en_cours', options);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is List) {
          return data
              .map((item) => ParkingEntryModel.fromCaissierApi(item as Map<String, dynamic>))
              .toList();
        } else if (data is Map && data.containsKey('data')) {
          final list = data['data'];
          if (list is List) {
            return list
                .map((item) => ParkingEntryModel.fromCaissierApi(item as Map<String, dynamic>))
                .toList();
          }
        }
        throw Exception('Format de réponse invalide');
      } else {
        throw Exception('Échec de la récupération des stationnements en cours');
      }
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('Erreur lors de la récupération des stationnements en cours: ${e.toString()}');
    }
  }

  @override
  Future<String?> extractLicensePlate(XFile imageFile) async {
    try {
      final token = await TokenService.getToken();
      final options = Options(headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Content-Type': 'multipart/form-data',
      });

      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imageFile.path, filename: imageFile.name),
      });

      final response = await _dio.post(
        '/caissier/ocr/license-plate',
        data: formData,
        options: options,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map && data.containsKey('license_plate')) {
          return data['license_plate'] as String;
        }
        if (data is Map && data.containsKey('plate')) {
          return data['plate'] as String;
        }
        return null;
      } else {
        throw Exception('Failed to extract license plate');
      }
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('Error during OCR extraction: ${e.toString()}');
    }
  }

  @override
  Future<bool> registerStationnement({
    required int parkingId,
    required String licensePlate,
    String? marque,
    String? modele,
  }) async {
    try {
      final token = await TokenService.getToken();
      final options = Options(headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      final body = {
        'parking_id': parkingId,
        'license_plate': licensePlate,
        'marque': ?marque,
        'modele': ?modele,
      };

      final response = await _dio.post(
        '/caissier/parking-sessions',
        data: body,
        options: options,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('Error registering stationnement: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> checkoutParkingSession(int sessionId) async {
    try {
      final token = await TokenService.getToken();
      final options = Options(headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      final body = {'session_id': sessionId};

      final response = await _dio.post(
        '/caissier/parking-sessions/checkout',
        data: body,
        options: options,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map) {
          return Map<String, dynamic>.from(response.data as Map);
        }
        throw Exception('Invalid checkout response format');
      } else {
        throw Exception('Failed checkout parking session');
      }
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('Error during checkout: ${e.toString()}');
    }
  }
  String _handleDioError(DioException e) {
    if (e.response != null && e.response?.data != null) {
      final errorData = e.response?.data;
      if (errorData is Map<String, dynamic>) {
        return errorData['message'] ?? errorData['error'] ?? 'Erreur serveur';
      }
    }
    if (e.type == DioExceptionType.connectionTimeout) {
      return "Délai d'attente dépassé";
    } else if (e.type == DioExceptionType.connectionError) {
      return "Erreur de connexion internet";
    }
    return e.message ?? 'Erreur de communication';
  }

}
