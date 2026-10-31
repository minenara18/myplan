import 'package:equatable/equatable.dart';

/// Rekaman fokus — model nilai immutable dengan kesetaraan dan copyWith.
class FocusRecord extends Equatable {
  const FocusRecord({
    required this.id,
    required this.mulai,
    required this.durasi,
    this.taskId,
  });

  final String id;
  final DateTime mulai;
  final Duration durasi;
  final String? taskId;

  FocusRecord copyWith({
    String? id,
    DateTime? mulai,
    Duration? durasi,
    String? taskId,
  }) {
    return FocusRecord(
      id: id ?? this.id,
      mulai: mulai ?? this.mulai,
      durasi: durasi ?? this.durasi,
      taskId: taskId ?? this.taskId,
    );
  }

  @override
  List<Object?> get props => [id, mulai, durasi, taskId];
}