import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../domain/entities/bus_line.dart';
import '../../domain/entities/bus_stop.dart';
import '../providers/arrival_alert_provider.dart';

class ArrivalAlertSheet extends StatefulWidget {
  final BusLine line;
  final BusStop stop;

  const ArrivalAlertSheet({
    super.key,
    required this.line,
    required this.stop,
  });

  static Future<void> show(
    BuildContext context, {
    required BusLine line,
    required BusStop stop,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ArrivalAlertSheet(line: line, stop: stop),
    );
  }

  @override
  State<ArrivalAlertSheet> createState() => _ArrivalAlertSheetState();
}

class _ArrivalAlertSheetState extends State<ArrivalAlertSheet> {
  int _selectedMinutes = 5;

  static const List<int> _options = [2, 5, 10, 15, 20];

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ArrivalAlertProvider>();
    final hasAlert =
        provider.hasAlertFor(widget.line.cl, widget.stop.cp);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF3A3A3A),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppColors.primary.withOpacity(0.4), width: 1),
                ),
                child: Text(
                  widget.line.lt,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.line.tp,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      widget.stop.np,
                      style: const TextStyle(
                          color: Color(0xFF888888), fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Alertar quando o ônibus estiver a:',
            style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _options.map((min) {
              final selected = _selectedMinutes == min;
              return GestureDetector(
                onTap: () => setState(() => _selectedMinutes = min),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary
                        : const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? AppColors.primary
                          : const Color(0xFF3A3A3A),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$min',
                        style: TextStyle(
                          color: selected ? Colors.white : const Color(0xFF888888),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'min',
                        style: TextStyle(
                          color: selected
                              ? Colors.white70
                              : const Color(0xFF555555),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          if (hasAlert)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  provider.removeAlert(widget.line, widget.stop);
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Remover alerta'),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  provider.addAlert(
                    line: widget.line,
                    stop: widget.stop,
                    thresholdMinutes: _selectedMinutes,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Alerta criado: ${widget.line.lt} em ${_selectedMinutes}min',
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: const Color(0xFF2A2A2A),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Ativar alerta',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
