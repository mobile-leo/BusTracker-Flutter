import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

class MapActionButtons extends StatelessWidget {
  final VoidCallback onCenter;
  final VoidCallback onToggleStops;
  final bool stopsActive;

  const MapActionButtons({
    super.key,
    required this.onCenter,
    required this.onToggleStops,
    required this.stopsActive,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildActionButton(
            Icons.my_location,
            onCenter,
            active: false,
          ),
          const SizedBox(height: 8),
          _buildActionButton(
            Icons.place_outlined,
            onToggleStops,
            active: stopsActive,
            tooltip: 'Paradas',
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    VoidCallback onTap, {
    bool active = false,
    String? tooltip,
  }) {
    final widget = GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: active ? AppColors.primary : const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active
                ? AppColors.primary
                : const Color(0xFF2A2A2A),
          ),
        ),
        child: Icon(
          icon,
          color: active ? Colors.white : Colors.white,
          size: 20,
        ),
      ),
    );
    if (tooltip != null) {
      return Tooltip(message: tooltip, child: widget);
    }
    return widget;
  }
}
