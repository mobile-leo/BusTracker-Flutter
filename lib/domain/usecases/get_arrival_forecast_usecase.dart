import '../entities/arrival_forecast.dart';
import '../repositories/sptrans_repository.dart';

class GetArrivalForecastUseCase {
  final SPTransRepository repository;

  GetArrivalForecastUseCase(this.repository);

  Future<ArrivalForecast?> call(int stopCode, int lineCode) =>
      repository.getArrivalForecast(stopCode, lineCode);
}
