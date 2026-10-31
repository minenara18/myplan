import 'package:ai_study_planner/core/models/ai_plan_block.dart';
import 'package:ai_study_planner/core/models/ai_plan_input.dart';
import 'package:ai_study_planner/core/models/ai_plan_result.dart';
import 'package:ai_study_planner/core/models/ai_summary.dart';

/// DTO hasil AI: parsing JSON API menjadi model nilai (AiPlanResult, AiSummary)
/// dan menyusun body permintaan /api/ai/plan.
class AiDto {
  const AiDto._();

  /// Body permintaan POST /api/ai/plan.
  static Map<String, dynamic> planToJson(AiPlanInput input) {
    return {
      'mulai': _tanggal(input.mulai),
      'sampai': _tanggal(input.sampai),
      'jam_mulai': input.jamMulai,
      'jam_selesai': input.jamSelesai,
      if (input.catatan != null && input.catatan!.trim().isNotEmpty)
        'catatan': input.catatan,
    };
  }

  /// Pars isi 'data' bentuk JSON POST /api/ai/plan menjadi [AiPlanResult].
  static AiPlanResult planFromJson(Map<String, dynamic> json) {
    final sumber = json['sumber']?.toString() == 'ai'
        ? AiPlanSumber.ai
        : AiPlanSumber.fallback;

    return AiPlanResult(
      sumber: sumber,
      rentangMulai: DateTime.parse(json['rentang']['mulai'] as String),
      rentangSampai: DateTime.parse(json['rentang']['sampai'] as String),
      sesi: (json['sesi'] as List<dynamic>)
          .map((item) => _blok(item as Map<String, dynamic>))
          .toList(),
      prioritas: (json['prioritas'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          const <String>[],
    );
  }

  /// Pars isi 'data' bentuk JSON POST /api/ai/summarize menjadi [AiSummary].
  static AiSummary summaryFromJson(Map<String, dynamic> json) {
    return AiSummary(
      ringkasan: json['ringkasan'] as String? ?? '',
      poinKunci: (json['poin_kunci'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          const <String>[],
      pertanyaanLatihan: (json['pertanyaan_latihan'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          const <String>[],
    );
  }

  /// Body permintaan POST /api/ai/summarize.
  static Map<String, dynamic> summaryToJson(String teks) {
    return {'teks': teks};
  }

  static AiPlanBlock _blok(Map<String, dynamic> json) {
    return AiPlanBlock(
      taskId: json['task_id'].toString(),
      mulai: DateTime.parse(json['mulai'] as String),
      selesai: DateTime.parse(json['selesai'] as String),
      alasan: json['alasan'] as String? ?? '',
    );
  }

  /// Bagian tanggal saja (ISO yyyy-MM-dd) — backend meminta string date.
  static String _tanggal(DateTime waktu) {
    final bulan = waktu.month.toString().padLeft(2, '0');
    final hari = waktu.day.toString().padLeft(2, '0');

    return '${waktu.year}-$bulan-$hari';
  }
}
