import 'package:camera/camera.dart';

import '../../../../shared/domain/entities/parking_entry.dart';
import '../../domain/repositories/agent_stationnement_repository.dart';
import '../datasources/agent_stationnement_remote_datasource.dart';
import '../datasources/dio_agent_stationnement_remote_datasource.dart';

import '../../../../core/cache/cache_manager.dart';

class DioAgentStationnementRepository implements AgentStationnementRepository {
  DioAgentStationnementRepository({
    AgentStationnementRemoteDataSource? remoteDataSource,
    CacheManager<List<ParkingEntry>>? cacheManager,
  })  : _remoteDataSource = remoteDataSource ?? DioAgentStationnementRemoteDataSource(),
        _cacheManager = cacheManager ?? CacheManager<List<ParkingEntry>>(ttl: const Duration(seconds: 15));

  final AgentStationnementRemoteDataSource _remoteDataSource;
  final CacheManager<List<ParkingEntry>> _cacheManager;

  @override
  Future<List<ParkingEntry>> getStationnementsEnCours({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _cacheManager.get();
      if (cached != null) {
        return cached;
      }
    }
    final remoteEntries = await _remoteDataSource.getStationnementsEnCours();
    _cacheManager.update(remoteEntries);
    return remoteEntries;
  }

  @override
  Future<String?> extractLicensePlate(XFile imageFile) {
    return _remoteDataSource.extractLicensePlate(imageFile);
  }

  @override
  Future<bool> registerStationnement({
    required int parkingId,
    required String licensePlate,
    String? marque,
    String? modele,
  }) {
    return _remoteDataSource.registerStationnement(
      parkingId: parkingId,
      licensePlate: licensePlate,
      marque: marque,
      modele: modele,
    );
  }

  @override
  Future<Map<String, dynamic>> checkoutParkingSession(int sessionId, {String? paymentMethod, double? amount}) {
    return _remoteDataSource.checkoutParkingSession(sessionId, paymentMethod: paymentMethod, amount: amount);
  }
}
