import '../../../../shared/models/versement_model.dart';

abstract class AgentVersementRepository {
  Future<List<VersementModel>> getVersements();
  Future<VersementDetailModel> getVersementDetail(int id);
}
