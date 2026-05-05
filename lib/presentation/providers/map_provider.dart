import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../domain/entities/bus_line.dart';
import '../../domain/entities/bus_position.dart';
import '../../domain/entities/bus_stop.dart';
import '../../domain/usecases/get_bus_positions_usecase.dart';
import '../../domain/usecases/get_stops_usecase.dart';
import '../../domain/usecases/search_lines_usecase.dart';

class MapProvider extends ChangeNotifier {
  final GetBusPositionsUseCase getBusPositionsUseCase;
  final SearchLinesUseCase searchLinesUseCase;
  final GetStopsUseCase getStopsUseCase;

  MapProvider({
    required this.getBusPositionsUseCase,
    required this.searchLinesUseCase,
    required this.getStopsUseCase,
  });

  // Limite máximo de markers visíveis por vez para manter a UI fluida.
  // Com viewport culling este número raramente é atingido em zoom razoável.
  static const int _maxVisibleMarkers = 150;

  Set<Marker> _markers = {};
  Set<Marker> _stopMarkers = {};
  Set<Polyline> _routePolylines = {};
  List<LineBusPositions> _busPositions = [];
  List<BusLine> _nearbyLines = [];
  List<BusLine> _searchResults = [];
  List<BusStop> _lineStops = [];
  BusLine? _activeFilterLine;
  LatLng _currentPosition = const LatLng(-23.5505, -46.6333);
  bool _isLoading = false;
  bool _isSearching = false;
  bool _showStops = false;
  String? _errorMessage;
  Timer? _pollingTimer;
  Timer? _rebuildDebounce;
  GoogleMapController? _mapController;
  BitmapDescriptor? _busIcon;
  BitmapDescriptor? _stopIcon;
  int _totalVehicles = 0;

  // Viewport atual do mapa — atualizado via onCameraMove
  LatLngBounds? _visibleBounds;
  // Zoom atual — controla limite dinâmico de markers
  double _currentZoom = 13.0;

  Set<Marker> get markers => {..._markers, ..._stopMarkers};
  Set<Polyline> get routePolylines => _routePolylines;
  List<LineBusPositions> get busPositions => _busPositions;
  List<BusLine> get nearbyLines => _nearbyLines;
  List<BusLine> get searchResults => _searchResults;
  LatLng get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  bool get showStops => _showStops;
  BusLine? get activeFilterLine => _activeFilterLine;
  String? get errorMessage => _errorMessage;
  int get totalVehicles => _totalVehicles;

  void setMapController(GoogleMapController controller) {
    _mapController = controller;
  }

  /// Chamado pelo GoogleMap.onCameraMove — atualiza bounds e refiltra markers
  /// sem fazer nenhuma chamada de rede. O debounce evita rebuilds em cascata
  /// durante o gesto de arrastar/pinçar.
  void onCameraMove(CameraPosition position) {
    _currentZoom = position.zoom;
    _rebuildDebounce?.cancel();
    _rebuildDebounce = Timer(const Duration(milliseconds: 150), () {
      _refreshVisibleBounds();
    });
  }

  Future<void> _refreshVisibleBounds() async {
    if (_mapController == null) return;
    try {
      _visibleBounds = await _mapController!.getVisibleRegion();
      _buildMarkersForViewport();
    } catch (_) {}
  }

  Future<void> initialize() async {
    _busIcon = await _createBusMarkerIcon();
    _stopIcon = await _createStopMarkerIcon();
    await _getUserLocation();
    await loadBusPositions();
    _startPolling();
  }

  Future<void> _getUserLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
        _currentPosition = LatLng(position.latitude, position.longitude);
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> loadBusPositions() async {
    _isLoading = _busPositions.isEmpty;
    _errorMessage = null;
    notifyListeners();

    try {
      final positions = await getBusPositionsUseCase.allPositions();
      _busPositions = positions;

      int total = 0;
      for (final p in positions) {
        total += p.vehicles.length;
      }
      _totalVehicles = total;

      // Atualiza nearbyLines com linhas que têm veículos próximos ao usuário
      _updateNearbyLines();

      // Tenta pegar bounds reais do mapa; caso não disponível ainda,
      // usa fallback baseado na posição do usuário
      if (_mapController != null) {
        try {
          _visibleBounds = await _mapController!.getVisibleRegion();
        } catch (_) {}
      }

      _buildMarkersForViewport();
    } catch (_) {
      _errorMessage = 'Erro ao carregar posições. Tentando novamente...';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _updateNearbyLines() {
    final double uLat = _currentPosition.latitude;
    final double uLon = _currentPosition.longitude;

    final List<_LineWithDistance> allWithDistance = [];

    for (final p in _busPositions) {
      if (p.vehicles.isEmpty) continue;
      double minDist = double.infinity;
      for (final v in p.vehicles) {
        final d = _distanceSquared(uLat, uLon, v.latitude, v.longitude);
        if (d < minDist) minDist = d;
      }
      allWithDistance.add(_LineWithDistance(line: p, distanceSquared: minDist));
    }

    allWithDistance.sort(
      (a, b) => a.distanceSquared.compareTo(b.distanceSquared),
    );

    // Pega as 30 linhas mais próximas independente de raio fixo,
    // garantindo que o sheet nunca fique vazio enquanto houver dados da API.
    _nearbyLines = allWithDistance
        .take(30)
        .map(
          (c) => BusLine(
            cl: c.line.lineCode,
            lc: false,
            lt: c.line.sign,
            tl: c.line.direction,
            sl: c.line.direction,
            tp: c.line.terminalPrimary,
            ts: c.line.terminalSecondary,
          ),
        )
        .toList();
  }

  /// Núcleo da solução: filtra veículos pela bounding box visível (O(n) sem sort),
  /// depois aplica um limite dinâmico baseado no zoom para proteger a UI.
  void _buildMarkersForViewport() {
    final icon =
        _busIcon ??
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);

    final bounds = _visibleBounds;

    // Limite dinâmico: quanto mais próximo o zoom, mais markers permitimos
    // pois a área visível é menor e há menos veículos dentro dela de qualquer forma.
    final int dynamicLimit = _zoomToMarkerLimit(_currentZoom);

    final Set<Marker> newMarkers = {};

    for (final line in _busPositions) {
      if (newMarkers.length >= dynamicLimit) break;

      for (final bus in line.vehicles) {
        if (newMarkers.length >= dynamicLimit) break;

        // Culling por bounding box: descarta veículos fora da tela sem cálculo de distância
        if (bounds != null &&
            !_isInBounds(bus.latitude, bus.longitude, bounds)) {
          continue;
        }

        newMarkers.add(
          Marker(
            markerId: MarkerId('bus_${line.lineCode}_${bus.prefix}'),
            position: LatLng(bus.latitude, bus.longitude),
            icon: icon,
            anchor: const Offset(0.5, 0.5),
            infoWindow: InfoWindow(
              title: '${line.sign} - ${line.terminalPrimary}',
              snippet: 'Sentido ${line.terminalSecondary}',
            ),
            zIndex: 1,
          ),
        );
      }
    }

    _markers = newMarkers;
    notifyListeners();
  }

  /// Verifica se um ponto está dentro dos bounds visíveis do mapa.
  /// Tratamos o caso de bounds que cruzam o antimeridiano (lon wrap).
  bool _isInBounds(double lat, double lon, LatLngBounds bounds) {
    if (lat < bounds.southwest.latitude || lat > bounds.northeast.latitude) {
      return false;
    }
    final double west = bounds.southwest.longitude;
    final double east = bounds.northeast.longitude;
    if (west <= east) {
      return lon >= west && lon <= east;
    } else {
      // Bounds cruzam o antimeridiano
      return lon >= west || lon <= east;
    }
  }

  /// Limite dinâmico de markers por nível de zoom.
  /// Zoom alto = área pequena → podemos mostrar mais.
  /// Zoom baixo = cidade toda → limite rígido para não travar.
  int _zoomToMarkerLimit(double zoom) {
    if (zoom >= 16) return _maxVisibleMarkers;
    if (zoom >= 14) return 120;
    if (zoom >= 12) return 80;
    if (zoom >= 10) return 50;
    return 30; // Zoom muito afastado: mostrar apenas 30 para não travar
  }

  double _distanceSquared(double lat1, double lon1, double lat2, double lon2) {
    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;
    return dLat * dLat + dLon * dLon;
  }

  Future<void> filterByLine(BusLine line) async {
    _activeFilterLine = line;
    _stopMarkers = {};
    _routePolylines = {};
    notifyListeners();

    final positions = _busPositions
        .where((p) => p.lineCode == line.cl)
        .toList();

    final icon =
        _busIcon ??
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);

    final Set<Marker> lineMarkers = {};
    for (final lp in positions) {
      for (final bus in lp.vehicles) {
        lineMarkers.add(
          Marker(
            markerId: MarkerId('filtered_bus_${lp.lineCode}_${bus.prefix}'),
            position: LatLng(bus.latitude, bus.longitude),
            icon: icon,
            anchor: const Offset(0.5, 0.5),
            infoWindow: InfoWindow(
              title: '${lp.sign} - ${lp.terminalPrimary}',
              snippet: 'Sentido ${lp.terminalSecondary}',
            ),
            zIndex: 2,
          ),
        );
      }
    }

    _markers = lineMarkers;

    // Carrega paradas da linha para exibir rota e paradas no mapa
    try {
      _lineStops = await getStopsUseCase(line.cl);
      _buildStopMarkers(_lineStops, forLine: true);
      _buildRoutePolyline(_lineStops);
    } catch (_) {}

    if (_mapController != null && _lineStops.isNotEmpty) {
      final bounds = _boundsFromStops(_lineStops);
      _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 60));
    }

    notifyListeners();
  }

  void clearLineFilter() {
    _activeFilterLine = null;
    _stopMarkers = {};
    _routePolylines = {};
    _lineStops = [];
    _buildMarkersForViewport();
  }

  void toggleStops() {
    _showStops = !_showStops;
    if (!_showStops) {
      if (_activeFilterLine == null) _stopMarkers = {};
    } else if (_currentZoom >= 14 && _visibleBounds != null) {
      _buildStopMarkersForViewport();
    }
    notifyListeners();
  }

  void _buildStopMarkersForViewport() {
    if (_currentZoom < 14) {
      _stopMarkers = {};
      return;
    }
    final bounds = _visibleBounds;
    final icon =
        _stopIcon ??
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
    final Set<Marker> stops = {};
    for (final stop in _lineStops) {
      if (bounds != null && !_isInBounds(stop.latitude, stop.longitude, bounds))
        continue;
      if (stops.length >= 80) break;
      stops.add(_buildStopMarker(stop, icon));
    }
    _stopMarkers = stops;
    notifyListeners();
  }

  void _buildStopMarkers(List<BusStop> stops, {bool forLine = false}) {
    final icon =
        _stopIcon ??
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
    _stopMarkers = stops.map((s) => _buildStopMarker(s, icon)).toSet();
  }

  Marker _buildStopMarker(BusStop stop, BitmapDescriptor icon) {
    return Marker(
      markerId: MarkerId('stop_${stop.cp}'),
      position: LatLng(stop.latitude, stop.longitude),
      icon: icon,
      anchor: const Offset(0.5, 0.5),
      infoWindow: InfoWindow(title: stop.np, snippet: stop.ed),
      zIndex: 1,
    );
  }

  void _buildRoutePolyline(List<BusStop> stops) {
    if (stops.length < 2) return;
    final points = stops.map((s) => LatLng(s.latitude, s.longitude)).toList();
    _routePolylines = {
      Polyline(
        polylineId: const PolylineId('route'),
        color: const Color(0xFFE53935),
        width: 3,
        points: points,
        patterns: [],
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
      ),
    };
  }

  LatLngBounds _boundsFromStops(List<BusStop> stops) {
    double minLat = stops.first.latitude;
    double maxLat = stops.first.latitude;
    double minLon = stops.first.longitude;
    double maxLon = stops.first.longitude;
    for (final s in stops) {
      if (s.latitude < minLat) minLat = s.latitude;
      if (s.latitude > maxLat) maxLat = s.latitude;
      if (s.longitude < minLon) minLon = s.longitude;
      if (s.longitude > maxLon) maxLon = s.longitude;
    }
    return LatLngBounds(
      southwest: LatLng(minLat, minLon),
      northeast: LatLng(maxLat, maxLon),
    );
  }

  Future<void> searchLines(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      _isSearching = false;
      notifyListeners();
      return;
    }
    _isSearching = true;
    notifyListeners();
    try {
      _searchResults = await searchLinesUseCase(query);
    } catch (_) {
      _searchResults = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  void centerOnUser() {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_currentPosition, 15),
    );
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    // Polling a cada 30s (era 20s) — a API SPTrans atualiza a cada ~30s de qualquer forma
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      await loadBusPositions();
    });
  }

  Future<BitmapDescriptor> _createBusMarkerIcon() async {
    const double size = 80;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    const bgColor = Color(0xFFE53935);
    const borderColor = Color(0xFFFFFFFF);

    final bgPaint = Paint()..color = bgColor;
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(const Offset(size / 2, size / 2), size / 2 - 2, bgPaint);
    canvas.drawCircle(
      const Offset(size / 2, size / 2),
      size / 2 - 2,
      borderPaint,
    );

    final iconPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    const double busW = 36;
    const double busH = 24;
    const double cx = size / 2;
    const double cy = size / 2;
    const double left = cx - busW / 2;
    const double top = cy - busH / 2;

    path.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, busW, busH),
        const Radius.circular(4),
      ),
    );
    canvas.drawPath(path, iconPaint);

    final windowPaint = Paint()..color = bgColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left + 3, top + 4, 10, 8),
        const Radius.circular(2),
      ),
      windowPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left + 15, top + 4, 8, 8),
        const Radius.circular(2),
      ),
      windowPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left + 25, top + 4, 8, 8),
        const Radius.circular(2),
      ),
      windowPaint,
    );

    final wheelPaint = Paint()..color = const Color(0xFF333333);
    canvas.drawCircle(Offset(left + 8, top + busH), 4, wheelPaint);
    canvas.drawCircle(Offset(left + busW - 8, top + busH), 4, wheelPaint);

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List bytes = byteData!.buffer.asUint8List();

    return BitmapDescriptor.bytes(bytes, width: 36, height: 36);
  }

  Future<BitmapDescriptor> _createStopMarkerIcon() async {
    const double size = 60;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final bgPaint = Paint()..color = const Color(0xFF1565C0);
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawCircle(const Offset(size / 2, size / 2), size / 2 - 2, bgPaint);
    canvas.drawCircle(
      const Offset(size / 2, size / 2),
      size / 2 - 2,
      borderPaint,
    );

    final iconPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path()
      ..addRect(
        Rect.fromCenter(
          center: const Offset(size / 2, size / 2 - 2),
          width: 20,
          height: 3,
        ),
      )
      ..addRect(
        Rect.fromCenter(
          center: const Offset(size / 2 - 7, size / 2 + 5),
          width: 6,
          height: 10,
        ),
      )
      ..addRect(
        Rect.fromCenter(
          center: const Offset(size / 2 + 7, size / 2 + 5),
          width: 6,
          height: 10,
        ),
      );
    canvas.drawPath(path, iconPaint);

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List bytes = byteData!.buffer.asUint8List();
    return BitmapDescriptor.bytes(bytes, width: 28, height: 28);
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _rebuildDebounce?.cancel();
    _mapController?.dispose();
    super.dispose();
  }
}

class _LineWithDistance {
  final LineBusPositions line;
  final double distanceSquared;

  _LineWithDistance({required this.line, required this.distanceSquared});
}
