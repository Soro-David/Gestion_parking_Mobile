import 'package:camera/camera.dart';
import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/network/dio_error_handler.dart';
import '../../../../core/network/remote_api_helper.dart';
import '../../../../shared/data/models/parking_entry_model.dart';
import 'caissier_stationnement_remote_datasource.dart';

class DioCaissierStationnementRemoteDataSource implements CaissierStationnementRemoteDataSource {
  DioCaissierStationnementRemoteDataSource({Dio? dio})
      : _dio = DioClient.create(dio),
        _api = RemoteApiHelper(DioClient.create(dio));

  final Dio _dio;
  final RemoteApiHelper _api;

  @override
  Future<List<ParkingEntryModel>> getStationnementsEnCours() async {
    try {
      final options = await _api.authOptions();
      final response = await _api.getWithFallback(
        '/caissier/parking-sessions/stationnement_en_cours',
        options: options,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final list = RemoteApiHelper.extractList(
          response.data,
          keys: const ['data', 'entries', 'results'],
        );
        return list.map(ParkingEntryModel.fromCaissierApi).toList();
      }
      throw Exception('Échec de la récupération des stationnements en cours');
    } on DioException catch (e) {
      throw Exception(DioErrorHandler.message(e));
    } catch (e) {
      throw Exception('Erreur lors de la récupération des stationnements en cours: ${e.toString()}');
    }
  }

  @override
  Future<String?> extractLicensePlate(XFile imageFile) async {
    try {
      final options = await _api.authOptions(
        extraHeaders: {'Content-Type': 'multipart/form-data'},
      );

      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imageFile.path, filename: imageFile.name),
      });

      final response = await _dio.post(
        '/caissier/ocr/license-plate',
        data: formData,
        options: options,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map && data.containsKey('license_plate')) {
          return data['license_plate'] as String;
        }
        if (data is Map && data.containsKey('plate')) {
          return data['plate'] as String;
        }
        return null;
      }
      throw Exception('Failed to extract license plate');
    } on DioException catch (e) {
      throw Exception(DioErrorHandler.message(e));
    } catch (e) {
      throw Exception('Error during OCR extraction: ${e.toString()}');
    }
  }

  @override
  Future<bool> registerStationnement({
    required int parkingId,
    required String licensePlate,
    String? marque,
    String? modele,
  }) async {
    try {
      final options = await _api.authOptions(
        extraHeaders: {'Content-Type': 'application/json'},
      );

      final body = {
        'parking_id': parkingId,
        'license_plate': licensePlate,
        'marque': ?marque,
        'modele': ?modele,
      };

      final response = await _dio.post(
        '/caissier/parking-sessions',
        data: body,
        options: options,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      throw Exception(DioErrorHandler.message(e));
    } catch (e) {
      throw Exception('Error registering stationnement: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> checkoutParkingSession(int sessionId) async {
    try {
      final options = await _api.authOptions(
        extraHeaders: {'Content-Type': 'application/json'},
      );

      final body = {'session_id': sessionId};

      final response = await _dio.post(
        '/caissier/parking-sessions/checkout',
        data: body,
        options: options,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map) {
          return Map<String, dynamic>.from(response.data as Map);
        }
        throw Exception('Invalid checkout response format');
      }
      throw Exception('Failed checkout parking session');
    } on DioException catch (e) {
      throw Exception(DioErrorHandler.message(e));
    } catch (e) {
      throw Exception('Error during checkout: ${e.toString()}');
    }
  }
}
