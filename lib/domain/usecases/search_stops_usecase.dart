import '../entities/bus_stop.dart';
import '../repositories/sptrans_repository.dart';

class SearchStopsUseCase {
  final SPTransRepository repository;

  SearchStopsUseCase(this.repository);

  Future<List<BusStop>> call(String query) => repository.searchStops(query);
}
