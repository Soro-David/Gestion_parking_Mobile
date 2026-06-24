import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../shared/data/models/statistiques_model.dart';

class AgentStatRemoteDataSource {
  final Dio dio;

  AgentStatRemoteDataSource({Dio? dioClient}) : dio = dioClient ?? DioClient.instance;

  Future<StatistiquesModel> getStats() async {
    final responses = await Future.wait([
      dio.get('/api/attendant/statistiques/total-encaisser'),
      dio.get('/api/attendant/statistiques/stationnement-en-cours'),
      dio.get('/api/attendant/statistiques/encaisse-non-verse'),
      dio.get('/api/attendant/statistiques/dette'),
    ]);

    return StatistiquesModel.fromResponses(responses);
  }
}
