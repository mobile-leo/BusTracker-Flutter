import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../domain/entities/bus_line.dart';
import '../../domain/entities/bus_position.dart';
import '../pages/line_detail/line_detail_page.dart';
import '../providers/history_provider.dart';
import '../providers/map_provider.dart';

class NearbyLinesSheet extends StatelessWidget {
  final DraggableScrollableController controller;

  const NearbyLinesSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: controller,
      initialChildSize: 0.32,
      minChildSize: 0.12,
      maxChildSize: 0.75,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Consumer<MapProvider>(
            builder: (context, provider, _) {
              final isSearchMode = provider.searchResults.isNotEmpty ||
                  provider.isSearching;
              final lines =
                  isSearchMode ? provider.searchResults : provider.nearbyLines;
              final positions = provider.busPositions;

              return ListView(
                controller: scrollController,
                padding: EdgeInsets.zero,
                children: [
                  _buildHandle(),
                  _buildHeader(context, lines.length, isSearchMode),
                  if (provider.isSearching)
                    _buildShimmer()
                  else if (lines.isEmpty && provider.isLoading)
                    _buildShimmer()
                  else if (lines.isEmpty && isSearchMode)
                    _buildEmptySearch()
                  else if (lines.isEmpty)
                    _buildEmpty()
                  else
                    ...lines.map((line) {
                      final vehicleCount = _getVehicleCount(line, positions);
                      return _LineItem(
                        line: line,
                        vehicleCount: vehicleCount,
                      );
                    }),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
        );
      },
    );
  }

  int _getVehicleCount(BusLine line, List<LineBusPositions> positions) {
    try {
      return positions
          .firstWhere((p) => p.lineCode == line.cl)
          .vehicles
          .length;
    } catch (_) {
      return 0;
    }
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

  Widget _buildHeader(BuildContext context, int count, bool isSearchMode) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                isSearchMode ? 'Resultados' : 'Linhas ativas',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.primary.withOpacity(0.4)),
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                const Text(
                  'AO VIVO',
                  style: TextStyle(
                    color: Color(0xFF4CAF50),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Column(
      children: List.generate(
        3,
        (_) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFF222222),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Padding(
      padding: EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.directions_bus_outlined,
              color: Color(0xFF444444), size: 40),
          SizedBox(height: 8),
          Text(
            'Nenhuma linha ativa encontrada.\nVerifique sua conexão ou token da API.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF666666), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearch() {
    return const Padding(
      padding: EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, color: Color(0xFF444444), size: 40),
          SizedBox(height: 8),
          Text(
            'Nenhuma linha encontrada.\nTente outro número ou nome.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF666666), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _LineItem extends StatelessWidget {
  final BusLine line;
  final int vehicleCount;

  const _LineItem({required this.line, required this.vehicleCount});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<MapProvider>().filterByLine(line);
        context.read<HistoryProvider>().addToHistory(line);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => LineDetailPage(line: line)),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF222222),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.directions_bus,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${line.lt} - ${line.tp}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Sentido ${line.ts}',
                    style: const TextStyle(
                        color: Color(0xFF888888), fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Text(
                      '$vehicleCount ônibus',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.wifi,
                        color: AppColors.primary, size: 13),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'em circulação',
                  style: TextStyle(
                      color: Color(0xFF666666), fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
