import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:ai_study_planner/core/aggregation.dart';
import 'package:ai_study_planner/theme/color_tokens.dart';

/// Bar chart mingguan dengan batang Moonstone, hari ini disorot Vanilla.
class WeeklyBarChartWidget extends StatelessWidget {
  const WeeklyBarChartWidget({super.key, this.stats});

  final ProgressStats? stats;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    // Data dummy per hari (7 hari)
    final dayData = List.generate(7, (i) {
      final day = weekStart.add(Duration(days: i));
      final isToday = day.day == now.day &&
          day.month == now.month &&
          day.year == now.year;
      final minutes = stats?.totalStudyMinutes ?? 0;
      // Distribusi sederhana
      final value = isToday ? minutes.toDouble() : (minutes / 7).toDouble();

      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: value,
            color: isToday ? ColorTokens.vanilla : ColorTokens.moonstone,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (stats?.totalStudyMinutes ?? 60).toDouble() * 1.2,
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
                  return Text(
                    days[value.toInt()],
                    style: const TextStyle(fontSize: 10, color: ColorTokens.textSecondary),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: dayData,
        ),
        swapAnimationDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}