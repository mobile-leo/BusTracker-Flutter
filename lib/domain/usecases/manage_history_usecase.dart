import '../entities/bus_line.dart';
import '../repositories/favorites_repository.dart';

class ManageHistoryUseCase {
  final FavoritesRepository repository;

  ManageHistoryUseCase(this.repository);

  Future<List<BusLine>> getHistory() => repository.getHistory();
  Future<void> addToHistory(BusLine line) => repository.addToHistory(line);
  Future<void> clearHistory() => repository.clearHistory();
}
