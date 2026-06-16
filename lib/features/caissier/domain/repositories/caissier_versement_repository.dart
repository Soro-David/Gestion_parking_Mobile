import '../../../../shared/domain/entities/versement.dart';

abstract class CaissierVersementRepository {
  Future<List<Versement>> getVersements();

  Future<VersementDetail> getVersementDetail(int id);
}
