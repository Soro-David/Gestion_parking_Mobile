import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/network/dio_error_handler.dart';
import '../../../../core/network/remote_api_helper.dart';
import '../../../../shared/data/models/parking_entry_model.dart';
import 'agent_stationnement_remote_datasource.dart';

class DioAgentStationnementRemoteDataSource implements AgentStationnementRemoteDataSource {
  DioAgentStationnementRemoteDataSource({Dio? dio})
      : _api = RemoteApiHelper(DioClient.create(dio));

  final RemoteApiHelper _api;

  @override
  Future<List<ParkingEntryModel>> getStationnementsEnCours() async {
    try {
      final options = await _api.authOptions();
      final response = await _api.getWithFallback(
        '/attendant/parking-sessions/stationnement_en_cours',
        options: options,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final list = RemoteApiHelper.extractList(
          response.data,
          keys: const ['data', 'entries', 'results'],
        );
        return list.map(ParkingEntryModel.fromCaissierApi).toList();
      }
      throw Exception('Échec de la récupération des stationnements en cours');
    } on DioException catch (e) {
      throw Exception(DioErrorHandler.message(e));
    } catch (e) {
      throw Exception('Erreur lors de la récupération des stationnements en cours: ${e.toString()}');
    }
  }
}
