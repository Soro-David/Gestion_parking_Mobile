import 'package:dio/dio.dart';
import 'package:parking_mobile/core/network/dio_client.dart';
import 'package:parking_mobile/core/network/dio_error_handler.dart';
import 'package:parking_mobile/core/network/remote_api_helper.dart';

import 'package:parking_mobile/shared/domain/entities/signalement.dart';

class SignalementRepository {
  static final SignalementRepository _instance = SignalementRepository._internal();

  factory SignalementRepository({Dio? dio}) {
    if (dio != null) {
      return SignalementRepository._internal(dio: dio);
    }
    return _instance;
  }

  SignalementRepository._internal({Dio? dio})
      : _api = RemoteApiHelper(DioClient.create(dio)),
        _dio = DioClient.create(dio);

  final RemoteApiHelper _api;
  final Dio _dio;

  Future<bool> createSignalement({
    required int parkingId,
    required String licensePlate,
    required String motif,
  }) async {
    try {
      final options = await _api.authOptions(
        extraHeaders: {'Content-Type': 'application/json'},
      );

      final response = await _dio.post(
        '/api/signalements',
        data: {
          'parking_id': parkingId,
          'license_plate': licensePlate,
          'motif': motif,
        },
        options: Options(headers: options.headers),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      throw Exception(DioErrorHandler.message(e));
    } catch (e) {
      throw Exception('Erreur lors du signalement: ${e.toString()}');
    }
  }

  Future<List<Signalement>> getSignalements() async {
    try {
      final options = await _api.authOptions();
      final response = await _api.getWithFallback(
        '/api/signalements',
        options: options,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final list = RemoteApiHelper.extractList(
          response.data,
          keys: const ['data', 'results'],
        );
        return list.map(Signalement.fromJson).toList();
      }
      throw Exception('Échec de la récupération des signalements');
    } on DioException catch (e) {
      throw Exception(DioErrorHandler.message(e));
    } catch (e) {
      throw Exception('Erreur lors de la récupération des signalements: ${e.toString()}');
    }
  }

  Future<Signalement> getSignalementById(int id) async {
    try {
      final options = await _api.authOptions();
      final response = await _api.getWithFallback(
        '/api/signalements/$id',
        options: options,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map && data['data'] is Map) {
          return Signalement.fromJson(Map<String, dynamic>.from(data['data'] as Map));
        }
        throw Exception('Format de réponse invalide');
      }
      throw Exception('Échec de la récupération du signalement');
    } on DioException catch (e) {
      throw Exception(DioErrorHandler.message(e));
    } catch (e) {
      throw Exception('Erreur lors de la récupération du signalement: ${e.toString()}');
    }
  }
}
