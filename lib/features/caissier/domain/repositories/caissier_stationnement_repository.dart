import 'package:camera/camera.dart';

import '../../../../shared/domain/entities/parking_entry.dart';

abstract class CaissierStationnementRepository {
  Future<List<ParkingEntry>> getStationnementsEnCours();

  Future<String?> extractLicensePlate(XFile imageFile);

  Future<bool> registerStationnement({
    required int parkingId,
    required String licensePlate,
    String? marque,
    String? modele,
  });

  Future<Map<String, dynamic>> checkoutParkingSession(int sessionId);
}
