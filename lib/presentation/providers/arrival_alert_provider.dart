import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/notification_service.dart';
import '../../domain/entities/bus_line.dart';
import '../../domain/entities/bus_stop.dart';
import '../../domain/usecases/get_stop_forecast_usecase.dart';

class ArrivalAlert {
  final BusLine line;
  final BusStop stop;
  final int thresholdMinutes;
  bool triggered;

  ArrivalAlert({
    required this.line,
    required this.stop,
    required this.thresholdMinutes,
    this.triggered = false,
  });
}

class ArrivalAlertProvider extends ChangeNotifier {
  final GetStopForecastUseCase getStopForecastUseCase;

  ArrivalAlertProvider({required this.getStopForecastUseCase});

  final List<ArrivalAlert> _alerts = [];
  Timer? _pollingTimer;

  List<ArrivalAlert> get alerts => List.unmodifiable(_alerts);
  bool get hasActiveAlerts => _alerts.isNotEmpty;

  void addAlert({
    required BusLine line,
    required BusStop stop,
    required int thresholdMinutes,
  }) {
    _alerts.removeWhere((a) => a.line.cl == line.cl && a.stop.cp == stop.cp);
    _alerts.add(
      ArrivalAlert(line: line, stop: stop, thresholdMinutes: thresholdMinutes),
    );
    _startPolling();
    notifyListeners();
  }

  void removeAlert(BusLine line, BusStop stop) {
    _alerts.removeWhere((a) => a.line.cl == line.cl && a.stop.cp == stop.cp);
    if (_alerts.isEmpty) _stopPolling();
    notifyListeners();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _checkAlerts(),
    );
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> _checkAlerts() async {
    for (final alert in _alerts) {
      if (alert.triggered) continue;
      try {
        final forecast = await getStopForecastUseCase(alert.stop.cp);
        if (forecast == null) continue;

        for (final lineForecast in forecast.lines) {
          if (lineForecast.lineCode != alert.line.cl) continue;
          for (final vehicle in lineForecast.vehicles) {
            final eta = _parseEtaMinutes(vehicle.arrivalTime);
            if (eta != null && eta <= alert.thresholdMinutes) {
              alert.triggered = true;
              await NotificationService.instance.showArrivalAlert(
                lineSign: alert.line.lt,
                stopName: alert.stop.np,
                minutesAway: eta,
              );
              notifyListeners();
              _scheduleReset(alert);
              break;
            }
          }
        }
      } catch (_) {}
    }
  }

  void _scheduleReset(ArrivalAlert alert) {
    Future.delayed(const Duration(minutes: 5), () {
      alert.triggered = false;
      notifyListeners();
    });
  }

  int? _parseEtaMinutes(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final parts = raw.split(':');
      if (parts.length < 2) return null;
      return int.parse(parts[0]) * 60 + int.parse(parts[1]);
    } catch (_) {
      return null;
    }
  }

  bool hasAlertFor(int lineCode, int stopCode) =>
      _alerts.any((a) => a.line.cl == lineCode && a.stop.cp == stopCode);

  @override
  void dispose() {
    _stopPolling();
    super.dispose();
  }
}
