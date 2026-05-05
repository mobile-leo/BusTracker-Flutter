import '../entities/arrival_forecast.dart';
import '../repositories/sptrans_repository.dart';

class GetStopForecastUseCase {
  final SPTransRepository repository;

  GetStopForecastUseCase(this.repository);

  Future<ArrivalForecast?> call(int stopCode) =>
      repository.getArrivalForecastByStop(stopCode);
}
