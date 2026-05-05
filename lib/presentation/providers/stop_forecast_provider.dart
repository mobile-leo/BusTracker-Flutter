import 'package:flutter/material.dart';
import '../../domain/entities/arrival_forecast.dart';
import '../../domain/entities/bus_stop.dart';
import '../../domain/usecases/get_stop_forecast_usecase.dart';
import '../../domain/usecases/search_stops_usecase.dart';

class StopForecastProvider extends ChangeNotifier {
  final GetStopForecastUseCase getStopForecastUseCase;
  final SearchStopsUseCase searchStopsUseCase;

  StopForecastProvider({
    required this.getStopForecastUseCase,
    required this.searchStopsUseCase,
  });

  ArrivalForecast? _forecast;
  BusStop? _selectedStop;
  List<BusStop> _searchResults = [];
  bool _isLoadingForecast = false;
  bool _isSearching = false;
  String? _errorMessage;

  ArrivalForecast? get forecast => _forecast;
  BusStop? get selectedStop => _selectedStop;
  List<BusStop> get searchResults => _searchResults;
  bool get isLoadingForecast => _isLoadingForecast;
  bool get isSearching => _isSearching;
  String? get errorMessage => _errorMessage;

  void selectStop(BusStop stop) {
    _selectedStop = stop;
    _forecast = null;
    notifyListeners();
    loadForecast(stop.cp);
  }

  void clearSelection() {
    _selectedStop = null;
    _forecast = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> loadForecast(int stopCode) async {
    _isLoadingForecast = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _forecast = await getStopForecastUseCase(stopCode);
      if (_forecast == null) {
        _errorMessage = 'Sem previsões disponíveis para esta parada.';
      }
    } catch (_) {
      _errorMessage = 'Erro ao carregar previsão.';
    } finally {
      _isLoadingForecast = false;
      notifyListeners();
    }
  }

  Future<void> searchStops(String query) async {
    if (query.length < 3) {
      _searchResults = [];
      notifyListeners();
      return;
    }
    _isSearching = true;
    notifyListeners();
    try {
      _searchResults = await searchStopsUseCase(query);
    } catch (_) {
      _searchResults = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }
}
