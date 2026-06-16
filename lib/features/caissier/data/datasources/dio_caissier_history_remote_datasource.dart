import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/network/dio_error_handler.dart';
import '../../../../core/network/remote_api_helper.dart';
import '../../../../shared/data/models/parking_entry_model.dart';
import '../../../../shared/data/models/parking_exit_model.dart';
import 'caissier_history_remote_datasource.dart';

class DioCaissierHistoryRemoteDataSource implements CaissierHistoryRemoteDataSource {
  DioCaissierHistoryRemoteDataSource({Dio? dio})
      : _api = RemoteApiHelper(DioClient.create(dio));

  final RemoteApiHelper _api;

  @override
  Future<List<ParkingEntryModel>> getEntryHistory() async {
    try {
      final options = await _api.authOptions();
      final response = await _api.getWithFallback(
        '/caissier/parking-sessions/history/entries',
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
  Future<List<ParkingExitModel>> getExitHistory() async {
    try {
      final options = await _api.authOptions();
      final response = await _api.getWithFallback(
        '/caissier/parking-sessions/history/exits',
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
