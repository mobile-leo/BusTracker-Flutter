import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 8),
            const Text(
              'Mais',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            _buildSection('Geral', [
              _MoreItem(Icons.notifications_outlined, 'Notificações', () {}),
              _MoreItem(Icons.history, 'Histórico', () {}),
              _MoreItem(Icons.map_outlined, 'Mapa offline', () {}),
            ]),
            const SizedBox(height: 16),
            _buildSection('Suporte', [
              _MoreItem(Icons.help_outline, 'Ajuda', () {}),
              _MoreItem(Icons.bug_report_outlined, 'Reportar problema', () {}),
              _MoreItem(Icons.info_outline, 'Sobre o app', () {}),
            ]),
            const SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.directions_bus,
                    color: AppColors.primary,
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'BusTracker SP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Versão 1.0.0',
                    style: TextStyle(color: Color(0xFF666666), fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Dados fornecidos pela SPTrans',
                    style: TextStyle(color: Color(0xFF444444), fontSize: 11),
                  ),
                  const Text(
                    'Desenvolvido por Leonardo Santos (mobile-leo)',
                    style: TextStyle(color: Color(0xFF444444), fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<_MoreItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF666666),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final isLast = entry.key == items.length - 1;
              return _buildMenuItem(entry.value, isLast);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(_MoreItem item, bool isLast) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(bottom: BorderSide(color: Color(0xFF2A2A2A))),
        ),
        child: Row(
          children: [
            Icon(item.icon, color: const Color(0xFF888888), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.label,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF444444), size: 18),
          ],
        ),
      ),
    );
  }
}

class _MoreItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MoreItem(this.icon, this.label, this.onTap);
}
