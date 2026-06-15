import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/token_service.dart';
import '../../../../shared/models/parking_entry_model.dart';
import '../../domain/repositories/agent_stationnement_repository.dart';

class DioAgentStationnementRepository implements AgentStationnementRepository {
  final Dio _dio;

  DioAgentStationnementRepository({Dio? dio})
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
      return await _dio.get('/api$path', options: options);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return await _dio.get(path, options: options);
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

      final response = await _getWithFallback(
        '/attendant/parking-sessions/stationnement_en_cours',
        options,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        List<dynamic>? list;
        if (data is List) {
          list = data;
        } else if (data is Map) {
          list = (data['data'] ?? data['entries'] ?? data['results']) as List<dynamic>?;
        }
        if (list != null) {
          return list
              .map((item) => ParkingEntryModel.fromCaissierApi(item as Map<String, dynamic>))
              .toList();
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
