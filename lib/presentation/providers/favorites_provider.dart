import 'package:flutter/material.dart';
import '../../domain/entities/bus_line.dart';
import '../../domain/entities/bus_stop.dart';
import '../../domain/usecases/manage_favorites_usecase.dart';

class FavoritesProvider extends ChangeNotifier {
  final ManageFavoritesUseCase manageFavoritesUseCase;

  FavoritesProvider({required this.manageFavoritesUseCase});

  List<BusLine> _favorites = [];
  List<BusStop> _favoriteStops = [];
  bool _isLoading = false;

  List<BusLine> get favorites => _favorites;
  List<BusStop> get favoriteStops => _favoriteStops;
  bool get isLoading => _isLoading;

  Future<void> loadFavorites() async {
    _isLoading = true;
    notifyListeners();
    try {
      _favorites = await manageFavoritesUseCase.getFavorites();
      _favoriteStops = await manageFavoritesUseCase.getFavoriteStops();
    } catch (_) {
      _favorites = [];
      _favoriteStops = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(BusLine line) async {
    final isFav = await manageFavoritesUseCase.isFavorite(line.cl);
    if (isFav) {
      await manageFavoritesUseCase.removeFavorite(line.cl);
    } else {
      await manageFavoritesUseCase.addFavorite(line);
    }
    await loadFavorites();
  }

  Future<void> toggleFavoriteStop(BusStop stop) async {
    final isFav = await manageFavoritesUseCase.isFavoriteStop(stop.cp);
    if (isFav) {
      await manageFavoritesUseCase.removeFavoriteStop(stop.cp);
    } else {
      await manageFavoritesUseCase.addFavoriteStop(stop);
    }
    await loadFavorites();
  }

  bool isFavorite(int lineCode) => _favorites.any((l) => l.cl == lineCode);

  bool isFavoriteStop(int stopCode) =>
      _favoriteStops.any((s) => s.cp == stopCode);
}
