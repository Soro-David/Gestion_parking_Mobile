import '../../../../shared/domain/entities/versement.dart';
import '../../domain/repositories/caissier_versement_repository.dart';
import '../datasources/caissier_versement_remote_datasource.dart';
import '../datasources/dio_caissier_versement_remote_datasource.dart';

class DioCaissierVersementRepository implements CaissierVersementRepository {
  DioCaissierVersementRepository({CaissierVersementRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? DioCaissierVersementRemoteDataSource();

  final CaissierVersementRemoteDataSource _remoteDataSource;

  @override
  Future<List<Versement>> getVersements() {
    return _remoteDataSource.getVersements();
  }

  @override
  Future<VersementDetail> getVersementDetail(int id) {
    return _remoteDataSource.getVersementDetail(id);
  }
}
