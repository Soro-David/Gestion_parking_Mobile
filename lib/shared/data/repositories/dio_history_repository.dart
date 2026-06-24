import 'package:dio/dio.dart';

import 'package:parking_mobile/core/network/dio_client.dart';
import 'package:parking_mobile/core/network/dio_error_handler.dart';
import 'package:parking_mobile/core/network/remote_api_helper.dart';
import 'package:parking_mobile/shared/data/models/parking_entry_model.dart';
import 'package:parking_mobile/shared/data/models/parking_exit_model.dart';
import 'package:parking_mobile/shared/domain/entities/parking_entry.dart';
import 'package:parking_mobile/shared/domain/entities/parking_exit.dart';
import 'package:parking_mobile/shared/domain/repositories/history_repository.dart';

/// Implémentation partagée du repository d'historique.
///
/// Le [basePath] permet d'injecter le préfixe de route propre à chaque rôle :
/// - Agent    → basePath = '/attendant'
/// - Caissier → basePath = '/caissier'
///
/// Les endpoints appelés suivent la convention :
///   GET {basePath}/parking-sessions/history/entries
///   GET {basePath}/parking-sessions/history/exits
class DioHistoryRepository implements HistoryRepository {
  /// [basePath] : préfixe de l'API propre au rôle.
  ///   - '/attendant' pour l'agent
  ///   - '/caissier'  pour le caissier
  DioHistoryRepository({required this.basePath, Dio? dio})
      : _api = RemoteApiHelper(DioClient.create(dio));

  final String basePath;
  final RemoteApiHelper _api;

  @override
  Future<List<ParkingEntry>> getEntryHistory() async {
    try {
      final options = await _api.authOptions();
      final response = await _api.getWithFallback(
        '$basePath/parking-sessions/history/entries',
        options: options,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final list = RemoteApiHelper.extractList(
          response.data,
          keys: const ['entries', 'data', 'results'],
        );
        return list.map(ParkingEntryModel.fromCaissierApi).toList();
      }
      throw Exception('Échec de la récupération de l\'historique des entrées');
    } on DioException catch (e) {
      throw Exception(DioErrorHandler.message(e));
    } catch (e) {
      throw Exception('Erreur lors de la récupération des entrées: ${e.toString()}');
    }
  }

  @override
  Future<List<ParkingExit>> getExitHistory() async {
    try {
      final options = await _api.authOptions();
      final response = await _api.getWithFallback(
        '$basePath/parking-sessions/history/exits',
        options: options,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final list = RemoteApiHelper.extractList(
          response.data,
          keys: const ['exits', 'data', 'results'],
        );
        return list.map(ParkingExitModel.fromCaissierApi).toList();
      }
      throw Exception('Échec de la récupération de l\'historique des sorties');
    } on DioException catch (e) {
      throw Exception(DioErrorHandler.message(e));
    } catch (e) {
      throw Exception('Erreur lors de la récupération des sorties: ${e.toString()}');
    }
  }
}
