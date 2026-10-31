import 'package:flutter_test/flutter_test.dart';

import 'package:ai_study_planner/core/system_clock.dart';
import 'package:ai_study_planner/data/repositories/fake_ai_repository.dart';
import 'package:ai_study_planner/data/repositories/fake_task_repository.dart';
import 'package:ai_study_planner/features/ai_planner/presentation/notifier/ai_summary_notifier.dart';

void main() {
  late FakeTaskRepository taskRepo;
  late AiSummaryNotifier notifier;

  setUp(() {
    taskRepo = FakeTaskRepository(clock: SystemClock());
    notifier = AiSummaryNotifier(
      aiRepository: FakeAiRepository(clock: SystemClock()),
      taskRepository: taskRepo,
    );
  });

  test('state awal adalah idle', () {
    expect(notifier.state, isA<AiSummaryIdle>());
  });

  test('ringkas menghasilkan ringkasan, poin, dan 5 pertanyaan', () async {
    await notifier.ringkas('Teks materi kuliah basis data untuk uji ringkas '
        'yang cukup panjang agar melewati batas minimal karakter.');

    final state = notifier.state;
    expect(state, isA<AiSummaryReady>());
    final ready = state as AiSummaryReady;
    expect(ready.hasil.ringkasan, isNotEmpty);
    expect(ready.hasil.poinKunci, isNotEmpty);
    expect(ready.hasil.pertanyaanLatihan.length, 5);
    expect(ready.tugas, isNotEmpty);
  });

  test('simpanSebagaiCatatan menambah ringkasan ke catatan tugas', () async {
    await notifier.ringkas('Teks materi poin kunci untuk uji simpan catatan '
        'yang cukup panjang agar melewati batas minimal karakter.');
    final ready = notifier.state as AiSummaryReady;
    final tugas = ready.tugas.first;

    final berhasil = await notifier.simpanSebagaiCatatan(tugas);

    expect(berhasil, isTrue);
    final semua = await taskRepo.watchTasks().first;
    final terbarui = semua.firstWhere((t) => t.id == tugas.id);
    expect(terbarui.catatan, contains(ready.hasil.ringkasan));
  });
}
