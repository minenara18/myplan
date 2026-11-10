import 'package:ai_study_planner/core/clock.dart';
import 'package:ai_study_planner/core/models/focus_record.dart';
import 'package:ai_study_planner/data/repositories/focus_repository.dart';

/// Implementasi in-memory dari FocusRepository.
class FakeFocusRepository implements FocusRepository {
  FakeFocusRepository({required this.clock, List<FocusRecord>? initialRecords})
      : _records = initialRecords ?? _defaultRecords(clock);

  final Clock clock;
  final List<FocusRecord> _records;

  static List<FocusRecord> _defaultRecords(Clock clock) {
    final now = clock.now();
    return [
      FocusRecord(
        id: 'focus-1',
        mulai: now.subtract(const Duration(minutes: 45)),
        durasi: const Duration(minutes: 45),
        taskId: 'task-1',
      ),
      FocusRecord(
        id: 'focus-2',
        mulai: now.subtract(const Duration(hours: 3)),
        durasi: const Duration(minutes: 25),
        taskId: null,
      ),
    ];
  }

  @override
  Stream<List<FocusRecord>> watchFocusRecords() async* {
    yield _records;
  }

  @override
  Future<void> saveFocusRecord(FocusRecord record) async {
    final index = _records.indexWhere((r) => r.id == record.id);
    if (index >= 0) {
      _records[index] = record;
    } else {
      _records.add(record);
    }
  }

  @override
  Future<void> deleteFocusRecord(String id) async {
    _records.removeWhere((r) => r.id == id);
  }
}
