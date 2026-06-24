import 'package:dio/dio.dart';
import '../../../../core/cache/cache_manager.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/caissier_report.dart';
import '../../domain/repositories/caissier_report_repository.dart';
import '../models/caissier_report_model.dart';

class DioCaissierReportRepository implements CaissierReportRepository {
  final Dio dio;
  final CacheManager<Map<String, CaissierReportData>> _cacheManager;

  DioCaissierReportRepository({
    Dio? dioClient,
    CacheManager<Map<String, CaissierReportData>>? cacheManager,
  })  : dio = dioClient ?? DioClient.instance,
        _cacheManager = cacheManager ?? CacheManager<Map<String, CaissierReportData>>(ttl: const Duration(minutes: 5));

  @override
  Future<CaissierReportData> getReport({
    required String periode,
    String? dateFrom,
    String? dateTo,
    bool forceRefresh = false,
  }) async {
    final cacheKey = '$periode-$dateFrom-$dateTo';
    if (!forceRefresh) {
      final cachedMap = _cacheManager.get();
      if (cachedMap != null && cachedMap.containsKey(cacheKey)) {
        return cachedMap[cacheKey]!;
      }
    }

    final Map<String, dynamic> queryParameters = {
      'periode': periode,
    };
    if (dateFrom != null) {
      queryParameters['date_from'] = dateFrom;
    }
    if (dateTo != null) {
      queryParameters['date_to'] = dateTo;
    }

    final response = await dio.get(
      '/api/caissier/reports',
      queryParameters: queryParameters,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = CaissierReportDataModel.fromJson(response.data as Map<String, dynamic>);
      final cachedMap = _cacheManager.get() ?? <String, CaissierReportData>{};
      cachedMap[cacheKey] = data;
      _cacheManager.update(cachedMap);
      return data;
    } else {
      throw Exception('Erreur lors du chargement des rapports');
    }
  }
}
