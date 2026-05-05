import '../../domain/entities/bus_line.dart';
import '../../domain/entities/bus_stop.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_local_datasource.dart';
import '../models/bus_line_model.dart';
import '../models/bus_stop_model.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesLocalDataSource localDataSource;

  FavoritesRepositoryImpl({required this.localDataSource});

  @override
  Future<List<BusLine>> getFavorites() async {
    return localDataSource.getFavorites();
  }

  @override
  Future<void> addFavorite(BusLine line) async {
    final current = localDataSource.getFavorites();
    if (current.any((l) => l.cl == line.cl)) return;
    final updated = [
      ...current,
      BusLineModel(
        cl: line.cl,
        lc: line.lc,
        lt: line.lt,
        tl: line.tl,
        sl: line.sl,
        tp: line.tp,
        ts: line.ts,
      ),
    ];
    await localDataSource.saveFavorites(updated);
  }

  @override
  Future<void> removeFavorite(int lineCode) async {
    final current = localDataSource.getFavorites();
    final updated = current.where((l) => l.cl != lineCode).toList();
    await localDataSource.saveFavorites(updated);
  }

  @override
  Future<bool> isFavorite(int lineCode) async {
    final current = localDataSource.getFavorites();
    return current.any((l) => l.cl == lineCode);
  }

  @override
  Future<List<BusLine>> getHistory() async => localDataSource.getHistory();

  @override
  Future<void> addToHistory(BusLine line) async {
    await localDataSource.addToHistory(
      BusLineModel(
        cl: line.cl,
        lc: line.lc,
        lt: line.lt,
        tl: line.tl,
        sl: line.sl,
        tp: line.tp,
        ts: line.ts,
      ),
    );
  }

  @override
  Future<void> clearHistory() => localDataSource.clearHistory();

  @override
  Future<List<BusStop>> getFavoriteStops() async =>
      localDataSource.getFavoriteStops();

  @override
  Future<void> addFavoriteStop(BusStop stop) async {
    await localDataSource.addFavoriteStop(
      BusStopModel(
        cp: stop.cp,
        np: stop.np,
        ed: stop.ed,
        latitude: stop.latitude,
        longitude: stop.longitude,
      ),
    );
  }

  @override
  Future<void> removeFavoriteStop(int stopCode) =>
      localDataSource.removeFavoriteStop(stopCode);

  @override
  Future<bool> isFavoriteStop(int stopCode) async {
    final stops = localDataSource.getFavoriteStops();
    return stops.any((s) => s.cp == stopCode);
  }
}
