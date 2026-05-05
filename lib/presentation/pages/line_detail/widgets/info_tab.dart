import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';
import '../../../../domain/entities/bus_line.dart';

class InfoTab extends StatelessWidget {
  final BusLine line;

  const InfoTab({super.key, required this.line});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildInfoSection('Linha', [
          _InfoItem('Código', line.lt),
          _InfoItem('Terminal primário', line.tp),
          _InfoItem('Terminal secundário', line.ts),
          _InfoItem('Acessível', line.lc ? 'Sim' : 'Não'),
        ]),
        const SizedBox(height: 16),
        _buildInfoSection('Operação', const [
          _InfoItem('Empresa', 'SPTrans'),
          _InfoItem('Frequência', 'A cada 10-15 min'),
          _InfoItem('Frota', '12 veículos'),
          _InfoItem('Extensão', '18,5 km'),
        ]),
        const SizedBox(height: 16),
        _buildInfoSection('Tarifa', const [
          _InfoItem('Bilhete único', 'R\$ 4,40'),
          _InfoItem('Dinheiro', 'R\$ 4,40'),
        ]),
      ],
    );
  }

  Widget _buildInfoSection(String title, List<_InfoItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const Divider(color: Color(0xFF2A2A2A), height: 1),
          ...items.map((item) => _buildInfoRow(item, items.last == item)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(_InfoItem item, bool isLast) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: Color(0xFF2A2A2A))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            item.label,
            style: const TextStyle(color: Color(0xFF888888), fontSize: 13),
          ),
          Text(
            item.value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem {
  final String label;
  final String value;

  const _InfoItem(this.label, this.value);
}
