import '../entities/bus_position.dart';
import '../repositories/sptrans_repository.dart';

class GetBusPositionsUseCase {
  final SPTransRepository repository;

  GetBusPositionsUseCase(this.repository);

  Future<List<LineBusPositions>> call(int lineCode) =>
      repository.getBusPositionsByLine(lineCode);

  Future<List<LineBusPositions>> allPositions() =>
      repository.getAllBusPositions();
}
