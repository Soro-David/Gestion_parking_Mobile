import '../../../../shared/data/models/versement_model.dart';

abstract class CaissierVersementRemoteDataSource {
  Future<List<VersementModel>> getVersements();

  Future<VersementDetailModel> getVersementDetail(int id);
}
