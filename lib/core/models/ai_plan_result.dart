import 'package:equatable/equatable.dart';

import 'package:ai_study_planner/core/models/ai_plan_block.dart';

/// Sumber rencana: dari LLM ('ai') atau penjadwal deterministik.
enum AiPlanSumber { ai, fallback }

/// Hasil penyusunan rencana belajar dari backend AI.
class AiPlanResult extends Equatable {
  const AiPlanResult({
    required this.sumber,
    required this.rentangMulai,
    required this.rentangSampai,
    required this.sesi,
    required this.prioritas,
  });

  final AiPlanSumber sumber;

  /// Rentang tanggal yang diminta (tanggal tanpa jam).
  final DateTime rentangMulai;
  final DateTime rentangSampai;

  /// Blok-blok usulan yang telah tervalidasi server.
  final List<AiPlanBlock> sesi;

  /// Urutan id tugas berdasarkan prioritas AI.
  final List<String> prioritas;

  @override
  List<Object?> get props => [sumber, rentangMulai, rentangSampai, sesi, prioritas];
}
