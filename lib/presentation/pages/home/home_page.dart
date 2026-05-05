import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../map/map_page.dart';
import '../lines/lines_page.dart';
import '../favorites/favorites_page.dart';
import '../traffic/traffic_page.dart';
import '../more/more_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    MapPage(),
    LinesPage(),
    FavoritesPage(),
    TrafficPage(),
    MorePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        border: Border(
          top: BorderSide(color: Color(0xFF2A2A2A), width: 0.5),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _buildNavItem(0, Icons.location_on, Icons.location_on_outlined, 'Mapa'),
              _buildNavItem(1, Icons.directions_bus, Icons.directions_bus_outlined, 'Linhas'),
              _buildNavItem(2, Icons.star, Icons.star_outline, 'Favoritos'),
              _buildNavItem(3, Icons.traffic, Icons.traffic_outlined, 'Tráfego'),
              _buildNavItem(4, Icons.more_horiz, Icons.more_horiz, 'Mais'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isActive = _currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : inactiveIcon,
              color: isActive ? AppColors.primary : const Color(0xFF666666),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.primary : const Color(0xFF666666),
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
