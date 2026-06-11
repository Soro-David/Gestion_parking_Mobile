import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/token_service.dart';
import '../../../../shared/models/parking_entry_model.dart';
import '../../../../shared/models/parking_exit_model.dart';
import '../../domain/repositories/caissier_history_repository.dart';

class DioCaissierHistoryRepository implements CaissierHistoryRepository {
  final Dio _dio;

  DioCaissierHistoryRepository({Dio? dio})
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
  Future<List<ParkingEntryModel>> getEntryHistory() async {
    try {
      final token = await TokenService.getToken();
      final options = Options(
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      final response = await _getWithFallback('/caissier/parking-sessions/history/entries', options);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        List<dynamic>? list;
        if (data is List) {
          list = data;
        } else if (data is Map) {
          // Supporte { 'entries': [...] }, { 'data': [...] } ou { 'results': [...] }
          list = (data['entries'] ?? data['data'] ?? data['results']) as List<dynamic>?;
        }
        if (list != null) {
          return list
              .map((item) => ParkingEntryModel.fromCaissierApi(item as Map<String, dynamic>))
              .toList();
        }
        throw Exception('Format de réponse invalide');
      } else {
        throw Exception('Échec de la récupération de l\'historique des entrées');
      }
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('Erreur lors de la récupération des entrées: ${e.toString()}');
    }
  }

  @override
  Future<List<ParkingExitModel>> getExitHistory() async {
    try {
      final token = await TokenService.getToken();
      final options = Options(
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      final response = await _getWithFallback('/caissier/parking-sessions/history/exits', options);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is List) {
          return data
              .map((item) => ParkingExitModel.fromCaissierApi(item as Map<String, dynamic>))
              .toList();
        } else if (data is Map && data.containsKey('data')) {
          final list = data['data'];
          if (list is List) {
            return list
                .map((item) => ParkingExitModel.fromCaissierApi(item as Map<String, dynamic>))
                .toList();
          }
        }
        throw Exception('Format de réponse invalide');
      } else {
        throw Exception('Échec de la récupération de l\'historique des sorties');
      }
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('Erreur lors de la récupération des sorties: ${e.toString()}');
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
      return 'Délai d\'attente dépassé';
    } else if (e.type == DioExceptionType.connectionError) {
      return 'Erreur de connexion internet';
    }
    return e.message ?? 'Erreur de communication';
  }
}
