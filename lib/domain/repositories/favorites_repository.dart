import '../entities/bus_line.dart';
import '../entities/bus_stop.dart';

abstract class FavoritesRepository {
  Future<List<BusLine>> getFavorites();
  Future<void> addFavorite(BusLine line);
  Future<void> removeFavorite(int lineCode);
  Future<bool> isFavorite(int lineCode);
  Future<List<BusLine>> getHistory();
  Future<void> addToHistory(BusLine line);
  Future<void> clearHistory();
  Future<List<BusStop>> getFavoriteStops();
  Future<void> addFavoriteStop(BusStop stop);
  Future<void> removeFavoriteStop(int stopCode);
  Future<bool> isFavoriteStop(int stopCode);
}
