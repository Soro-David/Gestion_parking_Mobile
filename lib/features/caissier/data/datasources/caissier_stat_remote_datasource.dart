import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../shared/data/models/statistiques_model.dart';

class CaissierStatRemoteDataSource {
  final Dio dio;

  CaissierStatRemoteDataSource({Dio? dioClient}) : dio = dioClient ?? DioClient.instance;

  Future<StatistiquesModel> getStats() async {
    final responses = await Future.wait([
      dio.get('/api/caissier/statistiques/total-encaisser'),
      dio.get('/api/caissier/statistiques/stationnement-en-cours'),
      dio.get('/api/caissier/statistiques/encaisse-non-verse'),
      dio.get('/api/caissier/statistiques/dette'),
    ]);

    return StatistiquesModel.fromResponses(responses);
  }
}
