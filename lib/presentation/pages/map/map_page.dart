import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../providers/map_provider.dart';
import '../../widgets/nearby_lines_sheet.dart';
import '../../widgets/map_search_bar.dart';
import '../../widgets/map_action_buttons.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(-23.5505, -46.6333),
    zoom: 13,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: Stack(
        children: [
          _buildMap(),
          SafeArea(
            child: Column(
              children: [
                MapSearchBar(
                  onChanged: (q) {
                    context.read<MapProvider>().searchLines(q);
                    if (q.isNotEmpty) {
                      _sheetController.animateTo(
                        0.6,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  },
                ),
                _buildErrorBanner(),
                _buildActiveFilterBanner(),
              ],
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.centerRight,
              child: Consumer<MapProvider>(
                builder: (context, provider, _) => MapActionButtons(
                  onCenter: () => provider.centerOnUser(),
                  onToggleStops: () => provider.toggleStops(),
                  stopsActive: provider.showStops,
                ),
              ),
            ),
          ),
          _buildLiveIndicator(),
          NearbyLinesSheet(controller: _sheetController),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return Consumer<MapProvider>(
      builder: (context, provider, _) {
        return GoogleMap(
          initialCameraPosition: _initialPosition,
          markers: provider.markers,
          polylines: provider.routePolylines,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          mapType: MapType.normal,
          style: _darkMapStyle,
          compassEnabled: false,
          zoomControlsEnabled: false,
          onMapCreated: (controller) {
            provider.setMapController(controller);
          },
          onCameraMove: (position) {
            provider.onCameraMove(position);
          },
        );
      },
    );
  }

  Widget _buildActiveFilterBanner() {
    return Consumer<MapProvider>(
      builder: (context, provider, _) {
        final line = provider.activeFilterLine;
        if (line == null) return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE53935).withOpacity(0.6)),
          ),
          child: Row(
            children: [
              const Icon(Icons.filter_alt, color: Color(0xFFE53935), size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Filtro: ${line.lt} - ${line.tp}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: () => context.read<MapProvider>().clearLineFilter(),
                child: const Icon(Icons.close,
                    color: Color(0xFFAAAAAA), size: 16),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorBanner() {
    return Consumer<MapProvider>(
      builder: (context, provider, _) {
        if (provider.errorMessage == null) return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF2A1A1A),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE53935).withOpacity(0.4)),
          ),
          child: Row(
            children: [
              const Icon(Icons.wifi_off_rounded,
                  color: Color(0xFFE53935), size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  provider.errorMessage!,
                  style: const TextStyle(
                    color: Color(0xFFAAAAAA),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLiveIndicator() {
    return Positioned(
      bottom: 260,
      left: 16,
      child: Consumer<MapProvider>(
        builder: (context, provider, _) {
          return AnimatedOpacity(
            opacity: provider.isLoading ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: const Color(0xFFE53935).withOpacity(0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: const Color(0xFFE53935),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Atualizando...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static const String _darkMapStyle = '''
[
  {"elementType":"geometry","stylers":[{"color":"#1a1a1a"}]},
  {"elementType":"labels.icon","stylers":[{"visibility":"off"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#1a1a1a"}]},
  {"featureType":"administrative","elementType":"geometry","stylers":[{"color":"#555555"}]},
  {"featureType":"administrative.country","elementType":"labels.text.fill","stylers":[{"color":"#9e9e9e"}]},
  {"featureType":"administrative.land_parcel","stylers":[{"visibility":"off"}]},
  {"featureType":"administrative.locality","elementType":"labels.text.fill","stylers":[{"color":"#bdbdbd"}]},
  {"featureType":"poi","stylers":[{"visibility":"off"}]},
  {"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#141414"}]},
  {"featureType":"road","elementType":"geometry.fill","stylers":[{"color":"#2c2c2c"}]},
  {"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#6b6b6b"}]},
  {"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#333333"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#3a3a3a"}]},
  {"featureType":"road.highway","elementType":"geometry.stroke","stylers":[{"color":"#212121"}]},
  {"featureType":"road.highway.controlled_access","elementType":"geometry","stylers":[{"color":"#444444"}]},
  {"featureType":"road.local","elementType":"labels.text.fill","stylers":[{"color":"#555555"}]},
  {"featureType":"transit","elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},
  {"featureType":"transit.line","elementType":"geometry","stylers":[{"color":"#2c2c2c"}]},
  {"featureType":"transit.station","elementType":"geometry","stylers":[{"color":"#1e1e1e"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#000000"}]},
  {"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#3d3d3d"}]}
]
''';
}
