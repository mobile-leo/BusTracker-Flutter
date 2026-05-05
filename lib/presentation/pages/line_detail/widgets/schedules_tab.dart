import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';

class SchedulesTab extends StatelessWidget {
  const SchedulesTab({super.key});

  static const List<String> _workdaySchedules = [
    '05:00', '05:30', '06:00', '06:30', '07:00', '07:30',
    '08:00', '08:30', '09:00', '09:30', '10:00', '10:30',
    '11:00', '11:30', '12:00', '12:30', '13:00', '13:30',
    '14:00', '14:30', '15:00', '15:30', '16:00', '16:30',
    '17:00', '17:30', '18:00', '18:30', '19:00', '19:30',
    '20:00', '20:30', '21:00', '22:00', '23:00',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildDaySelector(),
        const SizedBox(height: 20),
        _buildScheduleGrid(),
      ],
    );
  }

  Widget _buildDaySelector() {
    return Row(
      children: [
        _buildDayChip('Dias úteis', true),
        const SizedBox(width: 8),
        _buildDayChip('Sábados', false),
        const SizedBox(width: 8),
        _buildDayChip('Dom/Fer', false),
      ],
    );
  }

  Widget _buildDayChip(String label, bool selected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : const Color(0xFF888888),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildScheduleGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 2.5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _workdaySchedules.length,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            _workdaySchedules[index],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      },
    );
  }
}
