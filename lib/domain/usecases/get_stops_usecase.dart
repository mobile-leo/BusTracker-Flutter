import '../entities/bus_stop.dart';
import '../repositories/sptrans_repository.dart';

class GetStopsUseCase {
  final SPTransRepository repository;

  GetStopsUseCase(this.repository);

  Future<List<BusStop>> call(int lineCode) =>
      repository.getStopsByLine(lineCode);
}
