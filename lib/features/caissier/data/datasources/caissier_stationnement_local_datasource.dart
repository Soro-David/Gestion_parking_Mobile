import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../shared/data/models/parking_entry_model.dart';

abstract class CaissierStationnementLocalDataSource {
  Future<void> cacheStationnementsEnCours(List<ParkingEntryModel> entries);
  Future<List<ParkingEntryModel>> getCachedStationnementsEnCours();
  Future<void> clearCache();
}

class CaissierStationnementLocalDataSourceImpl implements CaissierStationnementLocalDataSource {
  static const String _cacheKey = 'cached_caissier_stationnements';

  @override
  Future<void> cacheStationnementsEnCours(List<ParkingEntryModel> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = entries.map((entry) => entry.toJson()).toList();
    await prefs.setString(_cacheKey, json.encode(jsonList));
  }

  @override
  Future<List<ParkingEntryModel>> getCachedStationnementsEnCours() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_cacheKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    final List<dynamic> decodedList = json.decode(jsonString) as List<dynamic>;
    return decodedList
        .map((item) => ParkingEntryModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
  }
}
