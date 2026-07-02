import '../../domain/repositories/caissier_stat_repository.dart';
import '../datasources/caissier_stat_remote_datasource.dart';
import '../../../../shared/domain/entities/statistiques.dart';
import '../../../../core/cache/cache_manager.dart';

class CaissierStatRepositoryImpl implements CaissierStatRepository {
  final CaissierStatRemoteDataSource remoteDataSource;
  final CacheManager<Statistiques> _cacheManager;

  CaissierStatRepositoryImpl({
    CaissierStatRemoteDataSource? remoteDataSource,
    CacheManager<Statistiques>? cacheManager,
  })  : remoteDataSource = remoteDataSource ?? CaissierStatRemoteDataSource(),
        _cacheManager = cacheManager ?? CacheManager<Statistiques>(ttl: const Duration(seconds: 15));

  @override
  Future<Statistiques> getStats({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _cacheManager.get();
      if (cached != null) {
        return cached;
      }
    }
    final stats = await remoteDataSource.getStats();
    _cacheManager.update(stats);
    return stats;
  }
}
