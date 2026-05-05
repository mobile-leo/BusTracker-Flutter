import 'package:shared_preferences/shared_preferences.dart';
import '../data/datasources/favorites_local_datasource.dart';
import '../data/datasources/sptrans_remote_datasource.dart';
import '../data/repositories/favorites_repository_impl.dart';
import '../data/repositories/sptrans_repository_impl.dart';
import '../domain/usecases/get_arrival_forecast_usecase.dart';
import '../domain/usecases/get_bus_positions_usecase.dart';
import '../domain/usecases/get_stop_forecast_usecase.dart';
import '../domain/usecases/get_stops_usecase.dart';
import '../domain/usecases/manage_favorites_usecase.dart';
import '../domain/usecases/manage_history_usecase.dart';
import '../domain/usecases/search_lines_usecase.dart';
import '../domain/usecases/search_stops_usecase.dart';
import '../presentation/providers/arrival_alert_provider.dart';
import '../presentation/providers/favorites_provider.dart';
import '../presentation/providers/history_provider.dart';
import '../presentation/providers/lines_provider.dart';
import '../presentation/providers/map_provider.dart';
import '../presentation/providers/stop_forecast_provider.dart';
import 'notification_service.dart';

class ServiceLocator {
  static late SPTransRemoteDataSource _remoteDataSource;
  static late SPTransRepositoryImpl _spTransRepository;
  static late FavoritesRepositoryImpl _favoritesRepository;

  static late SearchLinesUseCase searchLinesUseCase;
  static late SearchStopsUseCase searchStopsUseCase;
  static late GetBusPositionsUseCase getBusPositionsUseCase;
  static late GetStopsUseCase getStopsUseCase;
  static late GetArrivalForecastUseCase getArrivalForecastUseCase;
  static late GetStopForecastUseCase getStopForecastUseCase;
  static late ManageFavoritesUseCase manageFavoritesUseCase;
  static late ManageHistoryUseCase manageHistoryUseCase;

  static late MapProvider mapProvider;
  static late LinesProvider linesProvider;
  static late FavoritesProvider favoritesProvider;
  static late StopForecastProvider stopForecastProvider;
  static late HistoryProvider historyProvider;
  static late ArrivalAlertProvider arrivalAlertProvider;

  static Future<void> initialize(String apiToken) async {
    final prefs = await SharedPreferences.getInstance();

    _remoteDataSource = SPTransRemoteDataSource(apiToken: apiToken);

    _spTransRepository = SPTransRepositoryImpl(
      remoteDataSource: _remoteDataSource,
    );

    _favoritesRepository = FavoritesRepositoryImpl(
      localDataSource: FavoritesLocalDataSource(prefs: prefs),
    );

    searchLinesUseCase = SearchLinesUseCase(_spTransRepository);
    searchStopsUseCase = SearchStopsUseCase(_spTransRepository);
    getBusPositionsUseCase = GetBusPositionsUseCase(_spTransRepository);
    getStopsUseCase = GetStopsUseCase(_spTransRepository);
    getArrivalForecastUseCase = GetArrivalForecastUseCase(_spTransRepository);
    getStopForecastUseCase = GetStopForecastUseCase(_spTransRepository);
    manageFavoritesUseCase = ManageFavoritesUseCase(_favoritesRepository);
    manageHistoryUseCase = ManageHistoryUseCase(_favoritesRepository);

    mapProvider = MapProvider(
      getBusPositionsUseCase: getBusPositionsUseCase,
      searchLinesUseCase: searchLinesUseCase,
      getStopsUseCase: getStopsUseCase,
    );

    linesProvider = LinesProvider(
      searchLinesUseCase: searchLinesUseCase,
      getStopsUseCase: getStopsUseCase,
      manageFavoritesUseCase: manageFavoritesUseCase,
    );

    favoritesProvider = FavoritesProvider(
      manageFavoritesUseCase: manageFavoritesUseCase,
    );

    stopForecastProvider = StopForecastProvider(
      getStopForecastUseCase: getStopForecastUseCase,
      searchStopsUseCase: searchStopsUseCase,
    );

    historyProvider = HistoryProvider(
      manageHistoryUseCase: manageHistoryUseCase,
    );

    arrivalAlertProvider = ArrivalAlertProvider(
      getStopForecastUseCase: getStopForecastUseCase,
    );

    await NotificationService.instance.initialize();

    final authOk = await _remoteDataSource.authenticate();
    // ignore: avoid_print
    print('[ServiceLocator] SPTrans authenticate() => $authOk');
  }
}
