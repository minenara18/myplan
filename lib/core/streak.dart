import 'package:ai_study_planner/core/clock.dart';
import 'package:ai_study_planner/core/models/focus_record.dart';

/// Hitung streak hari belajar beruntun hingga hari ini (termasuk hari ini).
/// Streak berakhir jika ada hari tanpa FocusRecord.
/// [records] daftar rekaman fokus. [clock] untuk menentukan hari ini.
int calculateStreak(List<FocusRecord> records, Clock clock) {
  final today = clock.now();
  // Kumpulkan semua tanggal unik yang memiliki record
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
