import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../domain/entities/arrival_forecast.dart';
import '../../domain/entities/bus_stop.dart';
import '../providers/stop_forecast_provider.dart';
import 'stop_forecast_sheet.dart';

class FavoriteStopCard extends StatelessWidget {
  final BusStop stop;

  const FavoriteStopCard({super.key, required this.stop});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => StopForecastSheet.show(context, stop),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2A2A2A)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Consumer<StopForecastProvider>(
              builder: (context, provider, _) {
                if (provider.isLoadingForecast &&
                    provider.selectedStop?.cp == stop.cp) {
                  return const _LoadingRow();
                }
                final forecast = provider.forecast;
                if (forecast == null ||
                    provider.selectedStop?.cp != stop.cp) {
                  return const _EmptyForecastRow();
                }
                return _ForecastSummary(forecast: forecast);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: const Icon(Icons.place,
                color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stop.np,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  stop.ed,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right,
              color: AppColors.textSecondary, size: 18),
        ],
      ),
    );
  }
}

class _ForecastSummary extends StatelessWidget {
  final ArrivalForecast forecast;

  const _ForecastSummary({required this.forecast});

  @override
  Widget build(BuildContext context) {
    final upcomingVehicles = <_VehicleEta>[];
    for (final line in forecast.lines) {
      for (final v in line.vehicles) {
        upcomingVehicles.add(_VehicleEta(
          sign: line.sign,
          arrivalTime: v.arrivalTime,
        ));
      }
    }
    upcomingVehicles.sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));
    final displayed = upcomingVehicles.take(3).toList();

    if (displayed.isEmpty) return const _EmptyForecastRow();

    return Column(
      children: [
        const Divider(color: Color(0xFF2A2A2A), height: 1),
        ...displayed.map((v) => _VehicleRow(vehicle: v)),
      ],
    );
  }
}

class _VehicleRow extends StatelessWidget {
  final _VehicleEta vehicle;

  const _VehicleRow({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              vehicle.sign,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Spacer(),
          Text(
            vehicle.arrivalTime,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingRow extends StatelessWidget {
  const _LoadingRow();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(14),
      child: Row(
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: 8),
          Text(
            'Carregando previsões...',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _EmptyForecastRow extends StatelessWidget {
  const _EmptyForecastRow();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Text(
        'Toque para ver previsões ao vivo',
        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
      ),
    );
  }
}

class _VehicleEta {
  final String sign;
  final String arrivalTime;

  _VehicleEta({required this.sign, required this.arrivalTime});
}
