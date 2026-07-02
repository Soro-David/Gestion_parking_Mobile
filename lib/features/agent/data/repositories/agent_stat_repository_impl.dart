import '../../domain/repositories/agent_stat_repository.dart';
import '../datasources/agent_stat_remote_datasource.dart';
import '../../../../shared/domain/entities/statistiques.dart';
import '../../../../core/cache/cache_manager.dart';

class AgentStatRepositoryImpl implements AgentStatRepository {
  final AgentStatRemoteDataSource remoteDataSource;
  final CacheManager<Statistiques> _cacheManager;

  AgentStatRepositoryImpl({
    AgentStatRemoteDataSource? remoteDataSource,
    CacheManager<Statistiques>? cacheManager,
  })  : remoteDataSource = remoteDataSource ?? AgentStatRemoteDataSource(),
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
