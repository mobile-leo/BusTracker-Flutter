import '../../domain/entities/arrival_forecast.dart';
import '../../domain/entities/bus_line.dart';
import '../../domain/entities/bus_position.dart';
import '../../domain/entities/bus_stop.dart';
import '../../domain/repositories/sptrans_repository.dart';
import '../datasources/sptrans_remote_datasource.dart';

class SPTransRepositoryImpl implements SPTransRepository {
  final SPTransRemoteDataSource remoteDataSource;

  SPTransRepositoryImpl({required this.remoteDataSource});

  @override
  Future<bool> authenticate() => remoteDataSource.authenticate();

  @override
  Future<List<BusLine>> searchLines(String query) =>
      remoteDataSource.searchLines(query);

  @override
  Future<List<BusStop>> searchStops(String query) =>
      remoteDataSource.searchStops(query);

  @override
  Future<List<LineBusPositions>> getBusPositionsByLine(int lineCode) =>
      remoteDataSource.getBusPositionsByLine(lineCode);

  @override
  Future<List<BusStop>> getStopsByLine(int lineCode) =>
      remoteDataSource.getStopsByLine(lineCode);

  @override
  Future<ArrivalForecast?> getArrivalForecast(int stopCode, int lineCode) =>
      remoteDataSource.getArrivalForecast(stopCode, lineCode);

  @override
  Future<ArrivalForecast?> getArrivalForecastByStop(int stopCode) =>
      remoteDataSource.getArrivalForecastByStop(stopCode);

  @override
  Future<List<LineBusPositions>> getAllBusPositions() async {
    final response = await remoteDataSource.getAllBusPositions();
    return response?.lines ?? [];
  }
}
