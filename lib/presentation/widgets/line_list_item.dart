import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../domain/entities/bus_line.dart';

class LineListItem extends StatelessWidget {
  final BusLine line;
  final String eta;
  final VoidCallback? onTap;
  final bool showFavoriteButton;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;

  const LineListItem({
    super.key,
    required this.line,
    required this.eta,
    this.onTap,
    this.showFavoriteButton = false,
    this.isFavorite = false,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              children: [
                _buildLineCodeBadge(),
                const SizedBox(width: 12),
                Expanded(child: _buildLineInfo()),
                if (showFavoriteButton) _buildFavoriteButton(),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(color: Color(0xFF2A2A2A), height: 1),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Próximo ônibus em',
                  style: TextStyle(color: Color(0xFF888888), fontSize: 12),
                ),
                Row(
                  children: [
                    Text(
                      eta,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.wifi, color: AppColors.primary, size: 13),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineCodeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        line.lt,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildLineInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          line.tp,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Sentido ${line.ts}',
          style: const TextStyle(color: Color(0xFF888888), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildFavoriteButton() {
    return GestureDetector(
      onTap: onFavoriteTap,
      child: Icon(
        isFavorite ? Icons.star : Icons.star_border,
        color: isFavorite ? AppColors.primary : const Color(0xFF666666),
        size: 22,
      ),
    );
  }
}
