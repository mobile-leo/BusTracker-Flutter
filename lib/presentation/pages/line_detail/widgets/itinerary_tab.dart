import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';

class ItineraryTab extends StatelessWidget {
  final int lineCode;

  const ItineraryTab({super.key, required this.lineCode});

  static const List<_ItineraryStop> _mockStops = [
    _ItineraryStop('Terminal Bandeira', 'Partida', StopType.origin),
    _ItineraryStop('Av. 9 de Julho, 1000', '1 min', StopType.passed),
    _ItineraryStop('R. Augusta, 800', '3 min', StopType.current),
    _ItineraryStop('R. Consolação, 2100', '5 min', StopType.upcoming),
    _ItineraryStop('Av. Paulista, 1500', '7 min', StopType.upcoming),
    _ItineraryStop('Terminal Lapa', 'Chegada prevista 9:58', StopType.destination),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      itemCount: _mockStops.length,
      itemBuilder: (context, index) {
        final stop = _mockStops[index];
        final isLast = index == _mockStops.length - 1;
        return _buildStopItem(stop, index, isLast);
      },
    );
  }

  Widget _buildStopItem(
      _ItineraryStop stop, int index, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTimeline(stop, isLast),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: _buildStopInfo(stop),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(_ItineraryStop stop, bool isLast) {
    final Color dotColor = stop.type == StopType.origin || stop.type == StopType.current
        ? AppColors.primary
        : stop.type == StopType.destination
            ? AppColors.primary
            : const Color(0xFF3A3A3A);

    final bool showBus = stop.type == StopType.current;

    return SizedBox(
      width: 24,
      child: Column(
        children: [
          if (showBus)
            const Icon(Icons.directions_bus, color: AppColors.primary, size: 20)
          else
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: stop.type == StopType.upcoming
                      ? const Color(0xFF3A3A3A)
                      : dotColor,
                  width: 2,
                ),
              ),
            ),
          if (!isLast)
            Expanded(
              child: Container(
                width: 2,
                color: stop.type == StopType.origin ||
                        stop.type == StopType.passed ||
                        stop.type == StopType.current
                    ? AppColors.primary
                    : const Color(0xFF2A2A2A),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStopInfo(_ItineraryStop stop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          stop.name,
          style: TextStyle(
            color: stop.type == StopType.upcoming
                ? const Color(0xFF888888)
                : Colors.white,
            fontSize: 14,
            fontWeight: stop.type == StopType.origin ||
                    stop.type == StopType.destination
                ? FontWeight.w600
                : FontWeight.w400,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          stop.subtitle,
          style: TextStyle(
            color: stop.type == StopType.origin
                ? AppColors.primary
                : const Color(0xFF666666),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

enum StopType { origin, passed, current, upcoming, destination }

class _ItineraryStop {
  final String name;
  final String subtitle;
  final StopType type;

  const _ItineraryStop(this.name, this.subtitle, this.type);
}
