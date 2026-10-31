import 'package:flutter/material.dart';

import 'package:ai_study_planner/theme/color_tokens.dart';

/// Strip minggu di atas kalender.
class WeekStripWidget extends StatelessWidget {
  const WeekStripWidget({
    super.key,
    required this.selectedDay,
    required this.weekDays,
    required this.onDayTap,
    required this.onPreviousWeek,
    required this.onNextWeek,
  });

  final DateTime selectedDay;
  final List<DateTime> weekDays;
  final ValueSetter<DateTime> onDayTap;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, color: ColorTokens.moonstone),
          onPressed: onPreviousWeek,
        ),
        Expanded(
          child: SizedBox(
            height: 72,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: weekDays.length,
              itemBuilder: (context, index) {
                final day = weekDays[index];
                final isSelected = day.day == selectedDay.day &&
                    day.month == selectedDay.month &&
                    day.year == selectedDay.year;
                return GestureDetector(
                  onTap: () => onDayTap(day),
                  child: Container(
                    width: 64,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? ColorTokens.moonstone : Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _dayName(day.weekday),
                          style: TextStyle(
                            fontSize: 10,
                            color: isSelected ? Colors.white : ColorTokens.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${day.day}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : ColorTokens.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right, color: ColorTokens.moonstone),
          onPressed: onNextWeek,
        ),
      ],
    );
  }

  String _dayName(int weekday) {
    switch (weekday) {
      case 1: return 'Sen';
      case 2: return 'Sel';
      case 3: return 'Rab';
      case 4: return 'Kam';
      case 5: return 'Jum';
      case 6: return 'Sab';
      case 7: return 'Min';
      default: return '';
    }
  }
}