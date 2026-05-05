import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../domain/entities/arrival_forecast.dart';
import '../../domain/entities/bus_line.dart';
import '../../domain/entities/bus_stop.dart';
import '../providers/arrival_alert_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/stop_forecast_provider.dart';
import 'arrival_alert_sheet.dart';

class StopForecastSheet extends StatelessWidget {
  final BusStop stop;

  const StopForecastSheet({super.key, required this.stop});

  static Future<void> show(BuildContext context, BusStop stop) {
    context.read<StopForecastProvider>().selectStop(stop);
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<StopForecastProvider>(),
        child: StopForecastSheet(stop: stop),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              _buildHandle(),
              _buildStopHeader(),
              Expanded(
                child: Consumer<StopForecastProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoadingForecast) {
                      return _buildLoading();
                    }
                    if (provider.errorMessage != null) {
                      return _buildError(provider.errorMessage!);
                    }
                    final forecast = provider.forecast;
                    if (forecast == null || forecast.lines.isEmpty) {
                      return _buildEmpty();
                    }
                    return _buildForecastList(forecast, scrollController);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 10, bottom: 6),
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: const Color(0xFF3A3A3A),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildStopHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primary.withOpacity(0.4)),
            ),
            child: const Icon(Icons.place, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stop.np,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  stop.ed,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Consumer<FavoritesProvider>(
            builder: (context, favProvider, _) {
              final isFav = favProvider.isFavoriteStop(stop.cp);
              return GestureDetector(
                onTap: () => favProvider.toggleFavoriteStop(stop),
                child: Icon(
                  isFav ? Icons.bookmark : Icons.bookmark_border,
                  color: isFav ? AppColors.primary : const Color(0xFF666666),
                  size: 22,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildForecastList(
      ArrivalForecast forecast, ScrollController scrollController) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: forecast.lines.length,
      itemBuilder: (context, index) {
        final line = forecast.lines[index];
        return _LineForecastCard(line: line, stop: stop);
      },
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
          SizedBox(height: 12),
          Text(
            'Carregando previsões...',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.signal_wifi_off, color: Color(0xFF444444), size: 40),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(color: Color(0xFF666666), fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.directions_bus_outlined, color: Color(0xFF444444), size: 40),
            SizedBox(height: 12),
            Text(
              'Nenhum ônibus previsto\npara esta parada agora.',
              style: TextStyle(color: Color(0xFF666666), fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _LineForecastCard extends StatelessWidget {
  final dynamic line;
  final BusStop stop;

  const _LineForecastCard({required this.line, required this.stop});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    line.sign,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        line.terminalPrimary,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Sentido ${line.terminalSecondary}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Consumer<ArrivalAlertProvider>(
                  builder: (context, alertProvider, _) {
                    final busLine = BusLine(
                      cl: line.lineCode,
                      lc: false,
                      lt: line.sign,
                      tl: 1,
                      sl: 1,
                      tp: line.terminalPrimary,
                      ts: line.terminalSecondary,
                    );
                    final hasAlert =
                        alertProvider.hasAlertFor(line.lineCode, stop.cp);
                    return GestureDetector(
                      onTap: () => ArrivalAlertSheet.show(
                        context,
                        line: busLine,
                        stop: stop,
                      ),
                      child: Icon(
                        hasAlert
                            ? Icons.notifications_active
                            : Icons.notifications_none,
                        color: hasAlert
                            ? AppColors.primary
                            : const Color(0xFF666666),
                        size: 20,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF2A2A2A), height: 1),
          ...line.vehicles.map<Widget>((v) => _VehicleRow(vehicle: v)).toList(),
        ],
      ),
    );
  }
}

class _VehicleRow extends StatelessWidget {
  final dynamic vehicle;

  const _VehicleRow({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final eta = _parseEta(vehicle.arrivalTime);
    final isNear = eta != null && eta <= 5;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Icon(
            Icons.directions_bus,
            color: isNear ? AppColors.primary : const Color(0xFF666666),
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Prefixo ${vehicle.prefix}${vehicle.accessible ? "  ♿" : ""}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isNear
                  ? AppColors.primary.withOpacity(0.15)
                  : const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(20),
              border: isNear
                  ? Border.all(color: AppColors.primary.withOpacity(0.5))
                  : null,
            ),
            child: Text(
              vehicle.arrivalTime,
              style: TextStyle(
                color: isNear ? AppColors.primary : Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  int? _parseEta(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length != 2) return null;
      final now = DateTime.now();
      final arrival = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
      return arrival.difference(now).inMinutes;
    } catch (_) {
      return null;
    }
  }
}
