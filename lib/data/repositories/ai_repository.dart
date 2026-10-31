import 'package:ai_study_planner/core/models/ai_plan_input.dart';
import 'package:ai_study_planner/core/models/ai_plan_result.dart';
import 'package:ai_study_planner/core/models/ai_summary.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Interface repositori AI: jalur satu-satunya panggilan /api/ai/*.
abstract class AiRepository {
  /// Susun rencana belajar dari backend (/api/ai/plan).
  /// Gagal jaringan/validasi/AI dilempar sebagai Failure.
  Future<AiPlanResult> buatRencana(AiPlanInput input);

  /// Ringkas materi kuliah (/api/ai/summarize).
  Future<AiSummary> ringkasMateri(String teks);
}

/// Provider AiRepository — melempar UnimplementedError sampai di-override di bootstrap.
final aiRepositoryProvider = Provider<AiRepository>((ref) {
  throw UnimplementedError(
    'AiRepository belum di-override di bootstrap. '
    'Gunakan FakeAiRepository atau RemoteAiRepository.',
  );
});
