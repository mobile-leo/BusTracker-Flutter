import '../entities/bus_line.dart';
import '../entities/bus_stop.dart';
import '../repositories/favorites_repository.dart';

class ManageFavoritesUseCase {
  final FavoritesRepository repository;

  ManageFavoritesUseCase(this.repository);

  Future<List<BusLine>> getFavorites() => repository.getFavorites();
  Future<void> addFavorite(BusLine line) => repository.addFavorite(line);
  Future<void> removeFavorite(int lineCode) => repository.removeFavorite(lineCode);
  Future<bool> isFavorite(int lineCode) => repository.isFavorite(lineCode);

  Future<List<BusStop>> getFavoriteStops() => repository.getFavoriteStops();
  Future<void> addFavoriteStop(BusStop stop) => repository.addFavoriteStop(stop);
  Future<void> removeFavoriteStop(int stopCode) => repository.removeFavoriteStop(stopCode);
  Future<bool> isFavoriteStop(int stopCode) => repository.isFavoriteStop(stopCode);
}
