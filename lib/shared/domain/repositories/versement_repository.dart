import 'package:parking_mobile/shared/domain/entities/versement.dart';

/// Repository partagé pour les versements.
/// Utilisé par les deux rôles (agent et caissier) via injection du [basePath].
abstract class VersementRepository {
  Future<List<Versement>> getVersements();
  Future<VersementDetail> getVersementDetail(int id);
}
