import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bus_line_model.dart';
import '../models/bus_stop_model.dart';

class FavoritesLocalDataSource {
  static const String _favKey = 'favorites';
  static const String _historyKey = 'line_history';
  static const String _favStopsKey = 'favorite_stops';
  static const int _maxHistorySize = 20;

  final SharedPreferences prefs;

  FavoritesLocalDataSource({required this.prefs});

  List<BusLineModel> getFavorites() {
    final raw = prefs.getString(_favKey);
    if (raw == null) return [];
    final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => BusLineModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveFavorites(List<BusLineModel> lines) async {
    final encoded = jsonEncode(lines.map((l) => l.toJson()).toList());
    await prefs.setString(_favKey, encoded);
  }

  List<BusLineModel> getHistory() {
    final raw = prefs.getString(_historyKey);
    if (raw == null) return [];
    final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => BusLineModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addToHistory(BusLineModel line) async {
    final history = getHistory();
    history.removeWhere((l) => l.cl == line.cl);
    history.insert(0, line);
    final trimmed = history.take(_maxHistorySize).toList();
    final encoded = jsonEncode(trimmed.map((l) => l.toJson()).toList());
    await prefs.setString(_historyKey, encoded);
  }

  Future<void> clearHistory() async {
    await prefs.remove(_historyKey);
  }

  List<BusStopModel> getFavoriteStops() {
    final raw = prefs.getString(_favStopsKey);
    if (raw == null) return [];
    final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => BusStopModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addFavoriteStop(BusStopModel stop) async {
    final current = getFavoriteStops();
    if (current.any((s) => s.cp == stop.cp)) return;
    current.add(stop);
    await _saveFavoriteStops(current);
  }

  Future<void> removeFavoriteStop(int stopCode) async {
    final current = getFavoriteStops();
    current.removeWhere((s) => s.cp == stopCode);
    await _saveFavoriteStops(current);
  }

  Future<void> _saveFavoriteStops(List<BusStopModel> stops) async {
    final encoded = jsonEncode(
      stops.map((s) => {'cp': s.cp, 'np': s.np, 'ed': s.ed, 'py': s.latitude, 'px': s.longitude}).toList(),
    );
    await prefs.setString(_favStopsKey, encoded);
  }
}
