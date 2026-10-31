import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:ai_study_planner/core/aggregation.dart';
import 'package:ai_study_planner/core/models/course.dart';
import 'package:ai_study_planner/theme/color_tokens.dart';

/// Donut distribusi waktu per mata pelajaran.
class DonutChartWidget extends StatelessWidget {
  const DonutChartWidget({
    super.key,
    required this.stats,
    required this.courses,
  });

  final ProgressStats? stats;
  final List<Course> courses;

  @override
  Widget build(BuildContext context) {
    final timeByCourse = stats?.timeByCourse ?? {};

    if (timeByCourse.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: ColorTokens.moonstone.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Semantics(
          label: 'Belum ada data distribusi waktu per mata pelajaran',
          child: Center(
            child: Text('Belum ada data distribusi'),
          ),
        ),
      );
    }

    // Urutkan berdasarkan waktu terpanjang
    final entries = timeByCourse.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final sections = entries.take(5).map((entry) {
      final courseId = entry.key;
      final value = entry.value;
      final course = courses.firstWhere(
        (c) => c.id == courseId,
        orElse: () => Course(
          id: courseId,
          nama: 'Mata Pelajaran',
          warnaIndex: 0,
          ikon: const IconData(0xe800, fontFamily: 'MaterialIcons'),
        ),
      );
      final colorIndex = course.warnaIndex % 4;
      final colors = [
        ColorTokens.moonstone,
        ColorTokens.moonstoneTint,
        ColorTokens.vanilla,
        ColorTokens.textSecondary,
      ];

      return PieChartSectionData(
        value: value.toDouble(),
        title: course.nama,
        color: colors[colorIndex],
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 10,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      );
    }).toList();

    final totalMinutes = timeByCourse.values.fold<int>(0, (sum, v) => sum + v);

    return Semantics(
      label: 'Donut distribusi waktu belajar per mata pelajaran, total $totalMinutes menit',
      child: SizedBox(
        height: 220,
        child: Column(
          children: [
            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 40,
                  sectionsSpace: 4,
                  startDegreeOffset: -90,
                ),
                swapAnimationDuration: const Duration(milliseconds: 300),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Data direpresentasikan dengan bentuk lingkaran dan warna yang berbeda.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                color: ColorTokens.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}