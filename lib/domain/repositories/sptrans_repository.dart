import '../entities/bus_line.dart';
import '../entities/bus_position.dart';
import '../entities/bus_stop.dart';
import '../entities/arrival_forecast.dart';

abstract class SPTransRepository {
  Future<bool> authenticate();
  Future<List<BusLine>> searchLines(String query);
  Future<List<BusStop>> searchStops(String query);
  Future<List<LineBusPositions>> getBusPositionsByLine(int lineCode);
  Future<List<BusStop>> getStopsByLine(int lineCode);
  Future<ArrivalForecast?> getArrivalForecast(int stopCode, int lineCode);
  Future<ArrivalForecast?> getArrivalForecastByStop(int stopCode);
  Future<List<LineBusPositions>> getAllBusPositions();
}
