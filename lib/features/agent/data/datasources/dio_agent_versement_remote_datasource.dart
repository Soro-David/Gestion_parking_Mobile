import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/network/dio_error_handler.dart';
import '../../../../core/network/remote_api_helper.dart';
import '../../../../shared/data/models/versement_model.dart';
import 'agent_versement_remote_datasource.dart';

class DioAgentVersementRemoteDataSource implements AgentVersementRemoteDataSource {
  DioAgentVersementRemoteDataSource({Dio? dio}) : _dio = DioClient.create(dio);

  final Dio _dio;

  @override
  Future<List<VersementModel>> getVersements() async {
    try {
      final options = await RemoteApiHelper(_dio).authOptions();
      final response = await _dio.get(
        '/api/attendant/versements/list',
        options: options,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final list = RemoteApiHelper.extractList(
          response.data,
          keys: const ['data', 'versements', 'results'],
        );
        return list.map((item) => VersementModel.fromJson(item)).toList();
      }
      throw Exception('Échec de la récupération des versements');
    } on DioException catch (e) {
      throw Exception(DioErrorHandler.message(e));
    } catch (e) {
      throw Exception('Erreur: ${e.toString()}');
    }
  }

  @override
  Future<VersementDetailModel> getVersementDetail(int id) async {
    try {
      final options = await RemoteApiHelper(_dio).authOptions();
      final response = await _dio.get(
        '/api/attendant/versements/list/$id',
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
      }
      throw Exception('Échec de la récupération du détail versement');
    } on DioException catch (e) {
      throw Exception(DioErrorHandler.message(e));
    } catch (e) {
      throw Exception('Erreur: ${e.toString()}');
    }
  }
}
