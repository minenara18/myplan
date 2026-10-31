import 'package:flutter_test/flutter_test.dart';

import 'package:ai_study_planner/core/models/focus_record.dart';
import 'package:ai_study_planner/core/system_clock.dart';
import 'package:ai_study_planner/data/repositories/fake_focus_repository.dart';

void main() {
  group('FakeFocusRepository', () {
    test('returns default records', () async {
      final repo = FakeFocusRepository(clock: SystemClock());
      final records = await repo.watchFocusRecords().first;
      expect(records.length, 2);
    });

    test('save and retrieve record', () async {
      final repo = FakeFocusRepository(clock: SystemClock());
      await repo.saveFocusRecord(FocusRecord(
        id: 'f-new',
        mulai: SystemClock().now(),
        durasi: const Duration(minutes: 20),
        taskId: null,
      ));
      final records = await repo.watchFocusRecords().first;
      expect(records.any((r) => r.id == 'f-new'), isTrue);
    });

    test('delete record removes it', () async {
      final repo = FakeFocusRepository(clock: SystemClock());
      await repo.deleteFocusRecord('focus-1');
      final records = await repo.watchFocusRecords().first;
      expect(records.any((r) => r.id == 'focus-1'), isFalse);
      expect(records.length, 1);
    });
  });
}