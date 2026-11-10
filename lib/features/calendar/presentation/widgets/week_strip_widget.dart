import 'package:flutter/material.dart';

import 'package:ai_study_planner/l10n/app_localizations.dart';
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
    // Ukuran chip mengikuti skala teks agar label "Sen"–"Min" dan nomor
    // hari tetap muat tanpa potongan pada skala besar (mis. 2.0).
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final chipHeight = 72.0 * textScale;
    final chipWidth = 64.0 * textScale;

    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, color: ColorTokens.moonstone),
          tooltip: l10n('PreviousWeek'),
          onPressed: onPreviousWeek,
        ),
        Expanded(
          child: SizedBox(
            height: chipHeight,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: weekDays.length,
              itemBuilder: (context, index) {
                final day = weekDays[index];
                final isSelected = day.day == selectedDay.day &&
                    day.month == selectedDay.month &&
                    day.year == selectedDay.year;
                return Semantics(
                  label: '${_dayName(day.weekday)} ${day.day}',
                  button: true,
                  selected: isSelected,
                  child: GestureDetector(
                    onTap: () => onDayTap(day),
                    child: Container(
                      width: chipWidth,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? ColorTokens.moonstone
                            : ColorTokens.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _dayName(day.weekday),
                            style: TextStyle(
                              fontSize: 11,
                              color: isSelected
                                  ? ColorTokens.textPrimary
                                  : ColorTokens.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${day.day}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: ColorTokens.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right, color: ColorTokens.moonstone),
          tooltip: l10n('NextWeek'),
          onPressed: onNextWeek,
        ),
      ],
    );
  }

  String _dayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Sen';
      case 2:
        return 'Sel';
      case 3:
        return 'Rab';
      case 4:
        return 'Kam';
      case 5:
        return 'Jum';
      case 6:
        return 'Sab';
      case 7:
        return 'Min';
      default:
        return '';
    }
  }
}
