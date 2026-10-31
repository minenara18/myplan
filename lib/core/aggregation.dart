import 'package:ai_study_planner/core/clock.dart';
import 'package:ai_study_planner/core/models/course.dart';
import 'package:ai_study_planner/core/models/focus_record.dart';
import 'package:ai_study_planner/core/models/task.dart';

/// Statistik agregasi untuk layar progress.
class ProgressStats {
  const ProgressStats({
    required this.totalStudyMinutes,
    required this.completedTasks,
    required this.totalTasks,
    required this.streak,
    required this.timeByCourse,
  });

  final int totalStudyMinutes;
  final int completedTasks;
  final int totalTasks;
  final int streak;
  final Map<String, int> timeByCourse; // courseId -> menit
}

/// Agregasi murni untuk progress. Semua fungsi static tanpa efek samping.
class ProgressAggregator {
  const ProgressAggregator();

  /// Hitung statistik progres dari data mentah.
  ProgressStats aggregate({
    required List<FocusRecord> focusRecords,
    required List<Task> tasks,
    required List<Course> courses,
    required Clock clock,
  }) {
    final now = clock.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    int totalStudyMinutes = 0;
    final timeByCourse = <String, int>{};

    for (final record in focusRecords) {
      if (record.mulai.isAfter(weekStart) &&
          record.mulai.isBefore(weekEnd.add(const Duration(days: 1)))) {
        totalStudyMinutes += record.durasi.inMinutes;
        timeByCourse.update(
          record.taskId ?? 'umum',
          (val) => val + record.durasi.inMinutes,
          ifAbsent: () => record.durasi.inMinutes,
        );
      }
    }

    final completedTasks =
        tasks.where((t) => t.status == TaskStatus.selesai).length;
    final totalTasks = tasks.length;

    return ProgressStats(
      totalStudyMinutes: totalStudyMinutes,
      completedTasks: completedTasks,
      totalTasks: totalTasks,
      streak: _calculateStreak(focusRecords, clock),
      timeByCourse: timeByCourse,
    );
  }

  int _calculateStreak(List<FocusRecord> records, Clock clock) {
    final today = clock.now();
    final dates = <DateTime>{};
    for (final record in records) {
      dates.add(DateTime(
        record.mulai.year,
        record.mulai.month,
        record.mulai.day,
      ));
    }

    int streak = 0;
    var current = DateTime(today.year, today.month, today.day);
    while (dates.contains(current)) {
      streak++;
      current = current.subtract(const Duration(days: 1));
    }
    return streak;
  }

  /// Urutan courseId berdasarkan waktu terpanjang ke pendek.
  List<String> rankCoursesByTime(Map<String, int> timeByCourse) {
    final entries = timeByCourse.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.map((e) => e.key).toList();
  }

  /// Persentase kursus terhadap total waktu.
  double percentageOfTotal(Map<String, int> timeByCourse, String courseId) {
    final total = timeByCourse.values.fold<int>(0, (sum, v) => sum + v);
    if (total == 0) return 0.0;
    return (timeByCourse[courseId] ?? 0) / total;
  }
}