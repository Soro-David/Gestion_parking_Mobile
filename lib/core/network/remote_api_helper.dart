import 'package:dio/dio.dart';

import '../services/token_service.dart';

class RemoteApiHelper {
  RemoteApiHelper(this._dio);

  final Dio _dio;

  Future<Options> authOptions({Map<String, dynamic>? extraHeaders}) async {
    final token = await TokenService.getToken();
    return Options(
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        ...?extraHeaders,
      },
    );
  }

  Future<Response> getWithFallback(String path, {Options? options}) async {
    try {
      return await _dio.get('/api$path', options: options);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return await _dio.get(path, options: options);
      }
      rethrow;
    }
  }

  static List<Map<String, dynamic>> extractList(
    dynamic data, {
    List<String> keys = const ['data'],
  }) {
    if (data is List) {
      return data.map((item) => Map<String, dynamic>.from(item as Map)).toList();
    }
    if (data is Map) {
      for (final key in keys) {
        final list = data[key];
        if (list is List) {
          return list.map((item) => Map<String, dynamic>.from(item as Map)).toList();
        }
      }
    }
    throw Exception('Format de réponse invalide');
  }
}
