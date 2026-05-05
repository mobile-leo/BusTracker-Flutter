import '../entities/bus_line.dart';
import '../repositories/sptrans_repository.dart';

class SearchLinesUseCase {
  final SPTransRepository repository;

  SearchLinesUseCase(this.repository);

  Future<List<BusLine>> call(String query) => repository.searchLines(query);
}
