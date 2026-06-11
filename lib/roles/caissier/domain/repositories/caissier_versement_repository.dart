import '../../../../shared/models/versement_model.dart';

abstract class CaissierVersementRepository {
  Future<List<VersementModel>> getVersements();
  Future<VersementDetailModel> getVersementDetail(int id);
}
