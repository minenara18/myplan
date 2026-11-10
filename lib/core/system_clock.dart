import 'package:ai_study_planner/core/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Implementasi konkret dari Clock yang menggunakan waktu sistem.
class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}

/// Provider Clock. Di test di-override dengan fake clock.
final clockProvider = Provider<Clock>((ref) => const SystemClock());
