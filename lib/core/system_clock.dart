import 'package:ai_study_planner/core/clock.dart';

/// Implementasi konkret dari Clock yang menggunakan waktu sistem.
class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}