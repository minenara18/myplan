import 'package:ai_study_planner/core/models/study_session.dart';

/// DTO sesi studi untuk parsing keluaran API dan penulisan ke API.
class StudySessionDto {
  const StudySessionDto._();

  /// Map JSON dari API (StudySessionResource) menjadi [StudySession].
  static StudySession fromJson(Map<String, dynamic> json) {
    return StudySession(
      id: json['id'] as String,
      taskId: json['task_id'] as String?,
      courseId: json['course_id'] as String,
      mulai: DateTime.parse(json['mulai'] as String),
      selesai: DateTime.parse(json['selesai'] as String),
      sumber: _parseSumber(json['sumber']),
    );
  }

  /// Ubah [StudySession] menjadi map yang diminta API.
  static Map<String, dynamic> toJson(StudySession session) {
    return {
      if (session.taskId != null) 'task_id': session.taskId,
      'course_id': session.courseId,
      'mulai': session.mulai.toIso8601String(),
      'selesai': session.selesai.toIso8601String(),
      'sumber': session.sumber.name,
    };
  }

  static SessionSource _parseSumber(dynamic value) {
    return value?.toString() == 'ai' ? SessionSource.ai : SessionSource.manual;
  }
}
