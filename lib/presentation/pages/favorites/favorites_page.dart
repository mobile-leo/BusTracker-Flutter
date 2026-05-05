import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_colors.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/map_provider.dart';
import '../../providers/history_provider.dart';
import '../../widgets/favorite_stop_card.dart';
import '../../widgets/line_list_item.dart';
import '../line_detail/line_detail_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoritesProvider>().loadFavorites();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFavoritesTab(),
                  _buildStopsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Favoritos',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: const Icon(Icons.add, color: AppColors.primary, size: 26),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF2A2A2A), width: 1),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: const Color(0xFF888888),
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        tabs: const [
          Tab(text: 'LINHAS'),
          Tab(text: 'PONTOS'),
        ],
      ),
    );
  }

  Widget _buildFavoritesTab() {
    return Consumer<FavoritesProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (provider.favorites.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          itemCount: provider.favorites.length,
          itemBuilder: (context, index) {
            final line = provider.favorites[index];
            return LineListItem(
              line: line,
              eta: _mockEtas[index % _mockEtas.length],
              showFavoriteButton: true,
              isFavorite: true,
              onFavoriteTap: () => provider.toggleFavorite(line),
              onTap: () {
                context.read<MapProvider>().filterByLine(line);
                context.read<HistoryProvider>().addToHistory(line);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LineDetailPage(line: line),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildStopsTab() {
    return Consumer<FavoritesProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        if (provider.favoriteStops.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.place_outlined, color: Color(0xFF3A3A3A), size: 48),
                SizedBox(height: 12),
                Text(
                  'Nenhum ponto favoritado',
                  style: TextStyle(color: Color(0xFF666666), fontSize: 14),
                ),
                SizedBox(height: 4),
                Text(
                  'Favoriteuma parada no mapa para\nacompanhar previsões rapidamente.',
                  style: TextStyle(color: Color(0xFF444444), fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
          itemCount: provider.favoriteStops.length,
          itemBuilder: (context, index) =>
              FavoriteStopCard(stop: provider.favoriteStops[index]),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_outline, color: Color(0xFF3A3A3A), size: 48),
          const SizedBox(height: 12),
          const Text(
            'Nenhuma linha favorita',
            style: TextStyle(color: Color(0xFF666666), fontSize: 14),
          ),
          const SizedBox(height: 4),
          const Text(
            'Favorite uma linha para acompanhar\nos horários rapidamente.',
            style: TextStyle(color: Color(0xFF444444), fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Explorar linhas',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const List<String> _mockEtas = ['3 min', '6 min', '7 min', '11 min'];
}
