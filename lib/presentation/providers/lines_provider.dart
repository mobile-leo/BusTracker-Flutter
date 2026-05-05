import 'package:flutter/material.dart';
import '../../domain/entities/bus_line.dart';
import '../../domain/entities/bus_stop.dart';
import '../../domain/usecases/search_lines_usecase.dart';
import '../../domain/usecases/get_stops_usecase.dart';
import '../../domain/usecases/manage_favorites_usecase.dart';

class LinesProvider extends ChangeNotifier {
  final SearchLinesUseCase searchLinesUseCase;
  final GetStopsUseCase getStopsUseCase;
  final ManageFavoritesUseCase manageFavoritesUseCase;

  LinesProvider({
    required this.searchLinesUseCase,
    required this.getStopsUseCase,
    required this.manageFavoritesUseCase,
  });

  List<BusLine> _lines = [];
  List<BusStop> _stops = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<BusLine> get lines => _lines;
  List<BusStop> get stops => _stops;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  Future<void> searchLines(String query) async {
    _searchQuery = query;
    if (query.isEmpty) {
      _lines = _mockLines();
      notifyListeners();
      return;
    }
    _isLoading = true;
    notifyListeners();
    try {
      _lines = await searchLinesUseCase(query);
      if (_lines.isEmpty) _lines = _mockLines();
    } catch (_) {
      _lines = _mockLines();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadStops(int lineCode) async {
    _isLoading = true;
    notifyListeners();
    try {
      _stops = await getStopsUseCase(lineCode);
    } catch (_) {
      _stops = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> initialize() async {
    _lines = _mockLines();
    notifyListeners();
  }

  List<BusLine> _mockLines() {
    return const [
      BusLine(cl: 34041, lc: false, lt: '402', tl: 1, sl: 1, tp: 'Term. Bandeira', ts: 'Lapa'),
      BusLine(cl: 34042, lc: false, lt: '775L', tl: 1, sl: 1, tp: 'Term. Pirituba', ts: 'Centro'),
      BusLine(cl: 34043, lc: false, lt: '6030', tl: 1, sl: 1, tp: 'Term. Sto. Amaro', ts: 'Pinheiros'),
      BusLine(cl: 34044, lc: false, lt: '107', tl: 1, sl: 1, tp: 'Lapa', ts: 'Metrô Belém'),
      BusLine(cl: 34045, lc: false, lt: '251', tl: 1, sl: 1, tp: 'Term. Parelheiros', ts: 'Centro'),
      BusLine(cl: 34046, lc: false, lt: '4100', tl: 1, sl: 1, tp: 'Term. Capelinha', ts: 'Santo André'),
      BusLine(cl: 34047, lc: false, lt: '8012', tl: 1, sl: 1, tp: 'Term. Princesa Isabel', ts: 'Term. Sacomã'),
    ];
  }
}
