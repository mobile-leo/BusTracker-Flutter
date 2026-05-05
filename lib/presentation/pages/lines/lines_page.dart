import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_colors.dart';
import '../../providers/history_provider.dart';
import '../../providers/lines_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/map_provider.dart';
import '../line_detail/line_detail_page.dart';
import '../../widgets/line_list_item.dart';

class LinesPage extends StatefulWidget {
  const LinesPage({super.key});

  @override
  State<LinesPage> createState() => _LinesPageState();
}

class _LinesPageState extends State<LinesPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LinesProvider>().initialize();
      context.read<HistoryProvider>().loadHistory();
    });
    _searchController.addListener(() {
      final isEmpty = _searchController.text.isEmpty;
      if (_isSearching == !isEmpty) return;
      setState(() => _isSearching = !isEmpty);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onLineSelected(BuildContext context, dynamic line) {
    context.read<MapProvider>().filterByLine(line);
    context.read<HistoryProvider>().addToHistory(line);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LineDetailPage(line: line)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            Expanded(
              child: _isSearching ? _buildSearchResults() : _buildHomeState(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Linhas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (q) => context.read<LinesProvider>().searchLines(q),
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Buscar linha ou destino',
            hintStyle:
                const TextStyle(color: Color(0xFF666666), fontSize: 14),
            prefixIcon: const Icon(Icons.search,
                color: Color(0xFF666666), size: 20),
            suffixIcon: _isSearching
                ? GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      context.read<LinesProvider>().searchLines('');
                      FocusScope.of(context).unfocus();
                    },
                    child: const Icon(Icons.close,
                        color: Color(0xFF666666), size: 18),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  // Estado inicial: histórico + linhas populares
  Widget _buildHomeState() {
    return Consumer<HistoryProvider>(
      builder: (context, historyProvider, _) {
        final history = historyProvider.history;
        return ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            if (history.isNotEmpty) ...[
              _buildSectionHeader(
                title: 'Recentes',
                onClear: () => historyProvider.clearHistory(),
              ),
              ...history.map(
                (line) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _HistoryLineItem(
                    line: line,
                    onTap: () => _onLineSelected(context, line),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            _buildSectionHeader(title: 'Todas as linhas'),
            _buildAllLinesList(),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader({
    required String title,
    VoidCallback? onClear,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF888888),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          if (onClear != null)
            GestureDetector(
              onTap: onClear,
              child: const Text(
                'Limpar',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAllLinesList() {
    return Consumer2<LinesProvider, FavoritesProvider>(
      builder: (context, linesProvider, favProvider, _) {
        if (linesProvider.isLoading) {
          return const Padding(
            padding: EdgeInsets.only(top: 32),
            child: Center(
              child: CircularProgressIndicator(
                  color: AppColors.primary, strokeWidth: 2),
            ),
          );
        }
        final lines = linesProvider.lines;
        if (lines.isEmpty) {
          return const Padding(
            padding: EdgeInsets.only(top: 32),
            child: Center(
              child: Text(
                'Nenhuma linha disponível',
                style: TextStyle(color: Color(0xFF666666)),
              ),
            ),
          );
        }
        return Column(
          children: List.generate(
            lines.length,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: LineListItem(
                line: lines[index],
                eta: _mockEtas[index % _mockEtas.length],
                onTap: () => _onLineSelected(context, lines[index]),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchResults() {
    return Consumer<LinesProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
                color: AppColors.primary, strokeWidth: 2),
          );
        }
        final lines = provider.lines;
        if (lines.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.search_off,
                    color: Color(0xFF3A3A3A), size: 48),
                const SizedBox(height: 12),
                Text(
                  'Nenhuma linha para\n"${_searchController.text}"',
                  style: const TextStyle(
                      color: Color(0xFF666666), fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: lines.length,
          itemBuilder: (context, index) => LineListItem(
            line: lines[index],
            eta: _mockEtas[index % _mockEtas.length],
            onTap: () => _onLineSelected(context, lines[index]),
          ),
        );
      },
    );
  }

  static const List<String> _mockEtas = [
    '3 min',
    '5 min',
    '7 min',
    '10 min',
    '12 min'
  ];
}

class _HistoryLineItem extends StatelessWidget {
  final dynamic line;
  final VoidCallback onTap;

  const _HistoryLineItem({required this.line, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.history,
                  color: Color(0xFF666666), size: 18),
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
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Sentido ${line.ts}',
                    style: const TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: Color(0xFF444444), size: 20),
          ],
        ),
      ),
    );
  }
}
