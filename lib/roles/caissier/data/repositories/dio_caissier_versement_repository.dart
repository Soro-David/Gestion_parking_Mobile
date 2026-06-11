import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/token_service.dart';
import '../../../../shared/models/versement_model.dart';
import '../../domain/repositories/caissier_versement_repository.dart';

class DioCaissierVersementRepository implements CaissierVersementRepository {
  final Dio _dio;

  DioCaissierVersementRepository({Dio? dio})
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

  Future<Options> _authOptions() async {
    final token = await TokenService.getToken();
    return Options(headers: {
      if (token != null) 'Authorization': 'Bearer $token',
    });
  }

  @override
  Future<List<VersementModel>> getVersements() async {
    try {
      final options = await _authOptions();
      final response = await _dio.get(
        '/api/caissier/versements/list',
        options: options,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        List<dynamic>? list;
        if (data is List) {
          list = data;
        } else if (data is Map) {
          list = (data['data'] ?? data['versements'] ?? data['results'])
              as List<dynamic>?;
        }
        if (list != null) {
          return list
              .map((item) =>
                  VersementModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        throw Exception('Format de réponse invalide');
      } else {
        throw Exception('Échec de la récupération des versements');
      }
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('Erreur: ${e.toString()}');
    }
  }

  @override
  Future<VersementDetailModel> getVersementDetail(int id) async {
    try {
      final options = await _authOptions();
      final response = await _dio.get(
        '/api/caissier/versements/list/$id',
        options: options,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        Map<String, dynamic>? map;
        if (data is Map<String, dynamic>) {
          map = data['data'] as Map<String, dynamic>? ?? data;
        }
        if (map != null) {
          return VersementDetailModel.fromJson(map);
        }
        throw Exception('Format de réponse invalide');
      } else {
        throw Exception('Échec de la récupération du détail versement');
      }
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('Erreur: ${e.toString()}');
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
