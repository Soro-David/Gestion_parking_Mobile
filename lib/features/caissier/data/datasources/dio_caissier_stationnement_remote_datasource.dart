import 'package:camera/camera.dart';
import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/network/dio_error_handler.dart';
import '../../../../core/network/remote_api_helper.dart';
import '../../../../shared/data/models/parking_entry_model.dart';
import 'caissier_stationnement_remote_datasource.dart';

class DioCaissierStationnementRemoteDataSource
    implements CaissierStationnementRemoteDataSource {
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
        '/api/caissier/parking-sessions/stationnement_en_cours',
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
      throw Exception(
          'Erreur lors de la récupération des stationnements en cours: ${e.toString()}');
    }
  }

  @override
  Future<String?> extractLicensePlate(XFile imageFile) async {
    try {
      final options = await _api.authOptions();

      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.name,
        ),
      });

      // Essayer d'abord /attendant/ocr/license-plate, puis /caissier en fallback
      Response? response;
      try {
        response = await _dio.post(
          '/api/attendant/ocr/license-plate',
          data: formData,
          options: Options(headers: options.headers),
        );
      } on DioException catch (e) {
        if (e.response?.statusCode == 404 ||
            e.response?.statusCode == 405 ||
            e.type == DioExceptionType.connectionError) {
          // Reconstruire le FormData car il ne peut pas être réutilisé
          final formData2 = FormData.fromMap({
            'image': await MultipartFile.fromFile(
              imageFile.path,
              filename: imageFile.name,
            ),
          });
          response = await _dio.post(
            '/api/caissier/ocr/license-plate',
            data: formData2,
            options: Options(headers: options.headers),
          );
        } else {
          rethrow;
        }
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map && data.containsKey('license_plate')) {
          return data['license_plate'] as String?;
        }
        if (data is Map && data.containsKey('plate')) {
          return data['plate'] as String?;
        }
        if (data is Map && data.containsKey('result')) {
          return data['result'] as String?;
        }
        return null;
      }
      throw Exception('Échec de l\'extraction de la plaque');
    } on DioException catch (e) {
      throw Exception(DioErrorHandler.message(e));
    } catch (e) {
      throw Exception('Erreur lors de l\'analyse OCR: ${e.toString()}');
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

      final body = <String, dynamic>{
        'parking_id': parkingId,
        'license_plate': licensePlate,
        if (marque != null && marque.isNotEmpty) 'marque': marque,
        if (modele != null && modele.isNotEmpty) 'modele': modele,
      };

      final response = await _dio.post(
        '/api/caissier/parking-sessions',
        data: body,
        options: options,
      );
      // debugPrint("RESPONSE ENREGISTREMENT: ${response.data}");
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      throw Exception(DioErrorHandler.message(e));
    } catch (e) {
      throw Exception(
          'Erreur lors de l\'enregistrement du stationnement: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> checkoutParkingSession(int sessionId, {String? paymentMethod, double? amount}) async {
    try {
      final options = await _api.authOptions(
        extraHeaders: {'Content-Type': 'application/json'},
      );

      final body = {
        'session_id': sessionId,
        if (paymentMethod != null) 'payment_method': paymentMethod,
        if (amount != null) 'amount': amount,
      };

      final response = await _dio.post(
        '/api/caissier/parking-sessions/checkout',
        data: body,
        options: options,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map) {
          return Map<String, dynamic>.from(response.data as Map);
        }
        throw Exception('Format de réponse invalide');
      }
      throw Exception('Échec de la clôture de la session');
    } on DioException catch (e) {
      throw Exception(DioErrorHandler.message(e));
    } catch (e) {
      throw Exception(
          'Erreur lors de la clôture de la session: ${e.toString()}');
    }
  }
}
