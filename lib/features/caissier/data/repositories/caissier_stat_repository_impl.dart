import '../../domain/repositories/caissier_stat_repository.dart';
import '../datasources/caissier_stat_remote_datasource.dart';
import '../../../../shared/domain/entities/statistiques.dart';

class CaissierStatRepositoryImpl implements CaissierStatRepository {
  final CaissierStatRemoteDataSource remoteDataSource;

  CaissierStatRepositoryImpl({CaissierStatRemoteDataSource? remoteDataSource})
      : remoteDataSource = remoteDataSource ?? CaissierStatRemoteDataSource();

  @override
  Future<Statistiques> getStats() async {
    return await remoteDataSource.getStats();
  }
}
