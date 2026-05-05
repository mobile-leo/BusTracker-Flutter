import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';
import '../../../../domain/entities/bus_line.dart';

class LiveInfoCard extends StatelessWidget {
  final BusLine line;

  const LiveInfoCard({super.key, required this.line});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLiveBadge(),
                const SizedBox(height: 8),
                const Text(
                  'Próximo ônibus em',
                  style: TextStyle(color: Color(0xFF888888), fontSize: 12),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    const Text(
                      '3 min',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.wifi, color: AppColors.primary, size: 16),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Sentido ${line.ts}',
                  style: const TextStyle(color: Color(0xFF888888), fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _buildBusIcon(),
        ],
      ),
    );
  }

  Widget _buildLiveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'AO VIVO',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildBusIcon() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.directions_bus,
        color: AppColors.primary,
        size: 40,
      ),
    );
  }
}
