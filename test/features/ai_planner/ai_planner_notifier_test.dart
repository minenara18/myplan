import 'package:flutter_test/flutter_test.dart';

import 'package:ai_study_planner/core/models/ai_plan_result.dart';
import 'package:ai_study_planner/core/models/study_session.dart';
import 'package:ai_study_planner/core/system_clock.dart';
import 'package:ai_study_planner/data/repositories/fake_ai_repository.dart';
import 'package:ai_study_planner/data/repositories/fake_course_repository.dart';
import 'package:ai_study_planner/data/repositories/fake_session_repository.dart';
import 'package:ai_study_planner/data/repositories/fake_task_repository.dart';
import 'package:ai_study_planner/features/ai_planner/presentation/notifier/ai_planner_notifier.dart';

void main() {
  group('AiPlannerNotifier', () {
    late FakeSessionRepository sessionRepo;
    late AiPlannerNotifier notifier;

    setUp(() {
      final clock = SystemClock();
      sessionRepo = FakeSessionRepository(clock: clock);
      notifier = AiPlannerNotifier(
        aiRepository: FakeAiRepository(clock: clock),
        sessionRepository: sessionRepo,
        taskRepository: FakeTaskRepository(clock: clock),
        courseRepository: FakeCourseRepository(clock: clock),
        clock: clock,
      );
    });

    test('state awal adalah idle', () {
      expect(notifier.state, isA<AiPlannerIdle>());
    });

    test('susun menghasilkan state ready dengan blok dari fake', () async {
      await notifier.susun();

      final state = notifier.state;
      expect(state, isA<AiPlannerReady>());
      final ready = state as AiPlannerReady;
      expect(ready.hasil.sesi, isNotEmpty);
      expect(ready.tugas.keys, containsAll(['task-1', 'task-2']));
      expect(ready.hasil.sumber, AiPlanSumber.ai);
    });

    test('terapkan menyimpan semua sesi lewat satu operasi bulk', () async {
      final sesiAiAwal = (await sessionRepo.watchSessions().first)
          .where((s) => s.sumber == SessionSource.ai)
          .length;

      await notifier.susun();
      final rencana = notifier.state as AiPlannerReady;
      final jumlahBlok = rencana.hasil.sesi.length;
      await notifier.terapkan();

      expect(notifier.state, isA<AiPlannerTersimpan>());

      final semuaSesi = await sessionRepo.watchSessions().first;
      final sesiSumberAi =
          semuaSesi.where((s) => s.sumber == SessionSource.ai).toList();

      // Yang baru disimpan = jumlah blok rencana, tidak termasuk sesi lama.
      expect(sesiSumberAi.length - sesiAiAwal, jumlahBlok);
      expect(jumlahBlok, greaterThan(0));
      for (final sesi in sesiSumberAi.skip(sesiAiAwal)) {
        expect(sesi.taskId, isNotEmpty);
        expect(sesi.selesai.isAfter(sesi.mulai), isTrue);
      }
    });

    test('perbaruiBlok mengubah jam satu blok saja', () async {
      await notifier.susun();
      final ready = notifier.state as AiPlannerReady;
      final lama = ready.hasil.sesi.first;
      final mulaiBaru = DateTime(2026, 11, 2, 10);
      final selesaiBaru = DateTime(2026, 11, 2, 11);

      notifier.perbaruiBlok(lama, mulaiBaru, selesaiBaru);

      final terbaru = notifier.state as AiPlannerReady;
      final diubah = terbaru.hasil.sesi.first;
      expect(diubah.mulai, mulaiBaru);
      expect(diubah.selesai, selesaiBaru);
      expect(terbaru.hasil.sesi.length, ready.hasil.sesi.length);
    });

    test('reset kembali ke idle', () async {
      await notifier.susun();
      notifier.reset();

      expect(notifier.state, isA<AiPlannerIdle>());
    });
  });
}
