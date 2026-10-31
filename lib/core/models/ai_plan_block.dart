import 'package:equatable/equatable.dart';

/// Satu blok usulan jadwal dari AI (atau fallback):
/// tugas mana, kapan mulai-belajar, dan alasan satu kalimat.
class AiPlanBlock extends Equatable {
  const AiPlanBlock({
    required this.taskId,
    required this.mulai,
    required this.selesai,
    required this.alasan,
  });

  final String taskId;
  final DateTime mulai;
  final DateTime selesai;

  /// Satu kalimat penjelasan dari AI.
  final String alasan;

  /// Lama sesi belajar.
  Duration get durasi => selesai.difference(mulai);

  AiPlanBlock copyWith({
    String? taskId,
    DateTime? mulai,
    DateTime? selesai,
    String? alasan,
  }) {
    return AiPlanBlock(
      taskId: taskId ?? this.taskId,
      mulai: mulai ?? this.mulai,
      selesai: selesai ?? this.selesai,
      alasan: alasan ?? this.alasan,
    );
  }

  @override
  List<Object?> get props => [taskId, mulai, selesai, alasan];
}
