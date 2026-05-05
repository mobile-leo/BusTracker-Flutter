import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_colors.dart';
import '../../../domain/entities/bus_line.dart';
import '../../providers/favorites_provider.dart';
import 'widgets/live_info_card.dart';
import 'widgets/itinerary_tab.dart';
import 'widgets/schedules_tab.dart';
import 'widgets/info_tab.dart';

class LineDetailPage extends StatefulWidget {
  final BusLine line;

  const LineDetailPage({super.key, required this.line});

  @override
  State<LineDetailPage> createState() => _LineDetailPageState();
}

class _LineDetailPageState extends State<LineDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
            _buildAppBar(context),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: LiveInfoCard(line: widget.line),
            ),
            const SizedBox(height: 8),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  ItineraryTab(lineCode: widget.line.cl),
                  const SchedulesTab(),
                  InfoTab(line: widget.line),
                ],
              ),
            ),
            _buildAlertButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${widget.line.lt} - ${widget.line.tp}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Consumer<FavoritesProvider>(
            builder: (context, favProvider, _) {
              final isFav = favProvider.isFavorite(widget.line.cl);
              return GestureDetector(
                onTap: () => favProvider.toggleFavorite(widget.line),
                child: Icon(
                  isFav ? Icons.star : Icons.star_border,
                  color: isFav ? AppColors.primary : Colors.white,
                  size: 26,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        tabs: const [
          Tab(text: 'ITINERÁRIO'),
          Tab(text: 'HORÁRIOS'),
          Tab(text: 'INFORMAÇÕES'),
        ],
      ),
    );
  }

  Widget _buildAlertButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton.icon(
          onPressed: () => _showAlertDialog(context),
          icon: const Icon(Icons.notifications_outlined, size: 20),
          label: const Text(
            'Alertar quando chegar',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(27),
            ),
          ),
        ),
      ),
    );
  }

  void _showAlertDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF3A3A3A),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Icon(
              Icons.notifications_active,
              color: AppColors.primary,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              'Alertar para ${widget.line.lt} - ${widget.line.tp}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Você receberá uma notificação quando o ônibus estiver chegando.',
              style: TextStyle(color: Color(0xFF888888), fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(27),
                  ),
                ),
                child: const Text(
                  'Ativar alerta',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
