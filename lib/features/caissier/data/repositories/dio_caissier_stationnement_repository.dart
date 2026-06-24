import 'package:camera/camera.dart';

import '../../../../core/cache/cache_manager.dart';
import '../../../../shared/domain/entities/parking_entry.dart';
import '../../domain/repositories/caissier_stationnement_repository.dart';
import '../datasources/caissier_stationnement_local_datasource.dart';
import '../datasources/caissier_stationnement_remote_datasource.dart';
import '../datasources/dio_caissier_stationnement_remote_datasource.dart';

class DioCaissierStationnementRepository implements CaissierStationnementRepository {
  DioCaissierStationnementRepository({
    CaissierStationnementRemoteDataSource? remoteDataSource,
    CaissierStationnementLocalDataSource? localDataSource,
    CacheManager<List<ParkingEntry>>? cacheManager,
  })  : _remoteDataSource = remoteDataSource ?? DioCaissierStationnementRemoteDataSource(),
        _localDataSource = localDataSource ?? CaissierStationnementLocalDataSourceImpl(),
        _cacheManager = cacheManager ?? CacheManager<List<ParkingEntry>>(ttl: const Duration(minutes: 5));

  final CaissierStationnementRemoteDataSource _remoteDataSource;
  final CaissierStationnementLocalDataSource _localDataSource;
  final CacheManager<List<ParkingEntry>> _cacheManager;

  @override
  Future<List<ParkingEntry>> getStationnementsEnCours({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _cacheManager.get();
      if (cached != null) {
        return cached;
      }
    }

    try {
      final remoteEntries = await _remoteDataSource.getStationnementsEnCours();
      _cacheManager.update(remoteEntries);
      await _localDataSource.cacheStationnementsEnCours(remoteEntries);
      return remoteEntries;
    } catch (e) {
      // En cas d'échec de l'appel réseau, essayer de récupérer les données du cache local (offline mode).
      try {
        final localEntries = await _localDataSource.getCachedStationnementsEnCours();
        if (localEntries.isNotEmpty) {
          _cacheManager.update(localEntries);
          return localEntries;
        }
      } catch (_) {
        // Ignorer l'erreur du cache local pour propager l'erreur réseau d'origine.
      }
      rethrow;
    }
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
