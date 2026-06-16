import 'package:camera/camera.dart';

import '../../../../shared/domain/entities/parking_entry.dart';
import '../../domain/repositories/caissier_stationnement_repository.dart';
import '../datasources/caissier_stationnement_remote_datasource.dart';
import '../datasources/dio_caissier_stationnement_remote_datasource.dart';

class DioCaissierStationnementRepository implements CaissierStationnementRepository {
  DioCaissierStationnementRepository({CaissierStationnementRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? DioCaissierStationnementRemoteDataSource();

  final CaissierStationnementRemoteDataSource _remoteDataSource;

  @override
  Future<List<ParkingEntry>> getStationnementsEnCours() {
    return _remoteDataSource.getStationnementsEnCours();
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
  Future<Map<String, dynamic>> checkoutParkingSession(int sessionId) {
    return _remoteDataSource.checkoutParkingSession(sessionId);
  }
}
