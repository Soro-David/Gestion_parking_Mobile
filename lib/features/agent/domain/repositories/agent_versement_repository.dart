import '../../../../shared/domain/entities/versement.dart';

abstract class AgentVersementRepository {
  Future<List<Versement>> getVersements();

  Future<VersementDetail> getVersementDetail(int id);
}
