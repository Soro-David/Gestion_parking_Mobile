import '../../../../shared/data/models/versement_model.dart';

abstract class AgentVersementRemoteDataSource {
  Future<List<VersementModel>> getVersements();

  Future<VersementDetailModel> getVersementDetail(int id);
}
