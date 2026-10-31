import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ai_study_planner/core/failure.dart';
import 'package:ai_study_planner/core/models/ai_summary.dart';
import 'package:ai_study_planner/core/models/task.dart';
import 'package:ai_study_planner/data/repositories/ai_repository.dart';
import 'package:ai_study_planner/data/repositories/task_repository.dart';

/// State untuk AiSummaryNotifier.
sealed class AiSummaryState {}

final class AiSummaryIdle extends AiSummaryState {}

final class AiSummaryLoading extends AiSummaryState {}

final class AiSummaryReady extends AiSummaryState {
  AiSummaryReady(this.hasil, this.tugas);

  final AiSummary hasil;

  /// Daftar tugas untuk memilih tujuan catatan.
  final List<Task> tugas;
}

final class AiSummaryError extends AiSummaryState {
  AiSummaryError(this.failure);

  final Failure failure;
}

/// Notifier untuk layar Ringkas Materi.
class AiSummaryNotifier extends ChangeNotifier {
  AiSummaryNotifier({
    required AiRepository aiRepository,
    required TaskRepository taskRepository,
  })  : _aiRepository = aiRepository,
        _taskRepository = taskRepository;

  final AiRepository _aiRepository;
  final TaskRepository _taskRepository;

  AiSummaryState _state = AiSummaryIdle();
  AiSummaryState get state => _state;

  /// Ringkas teks materi yang ditempel pengguna.
  Future<void> ringkas(String teks) async {
    _state = AiSummaryLoading();
    notifyListeners();

    try {
      final hasil = await _aiRepository.ringkasMateri(teks);
      final tugas = await _taskRepository.watchTasks().first;
      _state = AiSummaryReady(hasil, tugas);
    } on Failure catch (failure) {
      _state = AiSummaryError(failure);
    }
    notifyListeners();
  }

  /// Simpan hasil ringkasan sebagai catatan pada satu tugas.
  /// Mengembalikan true bila berhasil.
  Future<bool> simpanSebagaiCatatan(Task tugas) async {
    final state = _state;
    if (state is! AiSummaryReady) return false;

    final gabungan = tugas.catatan == null || tugas.catatan!.isEmpty
        ? state.hasil.ringkasan
        : '${tugas.catatan}\n\n${state.hasil.ringkasan}';

    try {
      await _taskRepository.saveTask(tugas.copyWith(catatan: gabungan));

      return true;
    } on Failure {
      return false;
    }
  }

  /// Coba lagi setelah error (ulang teks terakhir milik layar).
  void reset() {
    _state = AiSummaryIdle();
    notifyListeners();
  }
}

/// Provider AiSummaryNotifier.
final aiSummaryNotifierProvider = ChangeNotifierProvider<AiSummaryNotifier>(
  (ref) {
    return AiSummaryNotifier(
      aiRepository: ref.watch(aiRepositoryProvider),
      taskRepository: ref.watch(taskRepositoryProvider),
    );
  },
);
