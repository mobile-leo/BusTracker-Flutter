import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_colors.dart';
import '../../../core/service_locator.dart';
import '../../../data/datasources/sptrans_remote_datasource.dart';
import '../../../domain/entities/bus_position.dart';
import '../../providers/map_provider.dart';

class TrafficPage extends StatefulWidget {
  const TrafficPage({super.key});

  @override
  State<TrafficPage> createState() => _TrafficPageState();
}

class _TrafficPageState extends State<TrafficPage> {
  List<_CorridorTrafficData> _corridors = [];
  bool _isLoading = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadTrafficData();
    _refreshTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      _loadTrafficData();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadTrafficData() async {
    setState(() => _isLoading = _corridors.isEmpty);
    try {
      final positions =
          context.read<MapProvider>().busPositions;
      final computed = _computeTrafficFromPositions(positions);
      setState(() {
        _corridors = computed;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  List<_CorridorTrafficData> _computeTrafficFromPositions(
      List<LineBusPositions> positions) {
    final corridorMap = <String, _CorridorAccumulator>{};

    for (final line in positions) {
      final key = _extractCorridorKey(line.sign);
      if (key == null) continue;
      corridorMap.putIfAbsent(key, () => _CorridorAccumulator(key));
      corridorMap[key]!.vehicleCount += line.vehicles.length;
      corridorMap[key]!.lineCount += 1;
    }

    final result = corridorMap.values
        .where((c) => c.vehicleCount > 0)
        .map((c) {
          final density = c.vehicleCount / c.lineCount;
          final status = _densityToStatus(density);
          return _CorridorTrafficData(
            name: c.name,
            vehicleCount: c.vehicleCount,
            lineCount: c.lineCount,
            status: status,
          );
        })
        .toList();

    result.sort((a, b) => b.vehicleCount.compareTo(a.vehicleCount));
    return result.take(20).toList();
  }

  String? _extractCorridorKey(String sign) {
    if (sign.isEmpty) return null;
    final prefix = sign.replaceAll(RegExp(r'[^0-9A-Z]'), '');
    if (prefix.length < 3) return null;
    return prefix.substring(0, (prefix.length / 2).ceil());
  }

  _TrafficStatus _densityToStatus(double density) {
    if (density >= 8) return _TrafficStatus.congested;
    if (density >= 4) return _TrafficStatus.slow;
    return _TrafficStatus.flowing;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildLegend(),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary, strokeWidth: 2))
                  : _corridors.isEmpty
                      ? _buildEmpty()
                      : _buildList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Tráfego',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          Consumer<MapProvider>(
            builder: (context, provider, _) => Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  '${provider.totalVehicles} veículos',
                  style: const TextStyle(
                      color: Color(0xFF888888), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Row(
        children: [
          _legendDot(const Color(0xFF4CAF50), 'Fluindo'),
          const SizedBox(width: 16),
          _legendDot(const Color(0xFFFFA726), 'Lento'),
          const SizedBox(width: 16),
          _legendDot(const Color(0xFFE53935), 'Congestionado'),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label,
            style:
                const TextStyle(color: Color(0xFF888888), fontSize: 11)),
      ],
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _corridors.length,
      itemBuilder: (context, index) =>
          _CorridorCard(data: _corridors[index]),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.traffic, color: Color(0xFF3A3A3A), size: 48),
          SizedBox(height: 12),
          Text(
            'Dados de tráfego não disponíveis.\nVerifique sua conexão.',
            style: TextStyle(color: Color(0xFF666666), fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _CorridorCard extends StatelessWidget {
  final _CorridorTrafficData data;

  const _CorridorCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final statusColor = data.status == _TrafficStatus.flowing
        ? const Color(0xFF4CAF50)
        : data.status == _TrafficStatus.slow
            ? const Color(0xFFFFA726)
            : const Color(0xFFE53935);

    final statusLabel = data.status == _TrafficStatus.flowing
        ? 'Fluindo'
        : data.status == _TrafficStatus.slow
            ? 'Lento'
            : 'Congestionado';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 44,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Corredor ${data.name}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${data.lineCount} linhas · ${data.vehicleCount} veículos',
                  style: const TextStyle(
                      color: Color(0xFF888888), fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withOpacity(0.4)),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _TrafficStatus { flowing, slow, congested }

class _CorridorTrafficData {
  final String name;
  final int vehicleCount;
  final int lineCount;
  final _TrafficStatus status;

  _CorridorTrafficData({
    required this.name,
    required this.vehicleCount,
    required this.lineCount,
    required this.status,
  });
}

class _CorridorAccumulator {
  final String name;
  int vehicleCount = 0;
  int lineCount = 0;

  _CorridorAccumulator(this.name);
}
