import 'package:equatable/equatable.dart';

/// Sumber sesi studi.
enum SessionSource { manual, ai }

/// Sesi studi — model nilai immutable dengan kesetaraan dan copyWith.
class StudySession extends Equatable {
  const StudySession({
    required this.id,
    this.taskId,
    required this.courseId,
    required this.mulai,
    required this.selesai,
    required this.sumber,
  });

  final String id;
  final String? taskId;
  final String courseId;
  final DateTime mulai;
  final DateTime selesai;
  final SessionSource sumber;

  StudySession copyWith({
    String? id,
    String? taskId,
    String? courseId,
    DateTime? mulai,
    DateTime? selesai,
    SessionSource? sumber,
  }) {
    return StudySession(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      courseId: courseId ?? this.courseId,
      mulai: mulai ?? this.mulai,
      selesai: selesai ?? this.selesai,
      sumber: sumber ?? this.sumber,
    );
  }

  @override
  List<Object?> get props => [id, taskId, courseId, mulai, selesai, sumber];
}