import 'package:dio/dio.dart';

import 'package:parking_mobile/core/network/dio_client.dart';
import 'package:parking_mobile/core/network/dio_error_handler.dart';
import 'package:parking_mobile/core/network/remote_api_helper.dart';
import 'package:parking_mobile/shared/data/models/versement_model.dart';
import 'package:parking_mobile/shared/domain/entities/versement.dart';
import 'package:parking_mobile/shared/domain/repositories/versement_repository.dart';

/// Implémentation partagée du repository de versements.
///
/// Le [basePath] permet d'injecter le préfixe de route propre à chaque rôle :
/// - Agent    → basePath = '/attendant'
/// - Caissier → basePath = '/caissier'
///
/// Les endpoints appelés suivent la convention :
///   GET /api{basePath}/versements/list
///   GET /api{basePath}/versements/list/{id}
class DioVersementRepository implements VersementRepository {
  /// [basePath] : préfixe de l'API propre au rôle.
  ///   - '/attendant' pour l'agent
  ///   - '/caissier'  pour le caissier
  DioVersementRepository({required this.basePath, Dio? dio})
      : _dio = DioClient.create(dio);

  final String basePath;
  final Dio _dio;

  @override
  Future<List<Versement>> getVersements() async {
    try {
      final options = await RemoteApiHelper(_dio).authOptions();
      final response = await _dio.get(
        '/api$basePath/versements/list',
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
  Future<VersementDetail> getVersementDetail(int id) async {
    try {
      final options = await RemoteApiHelper(_dio).authOptions();
      final response = await _dio.get(
        '/api$basePath/versements/list/$id',
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
