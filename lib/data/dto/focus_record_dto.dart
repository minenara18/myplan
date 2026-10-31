import 'package:ai_study_planner/core/models/focus_record.dart';

/// DTO rekaman fokus untuk parsing keluaran API dan penulisan ke API.
class FocusRecordDto {
  const FocusRecordDto._();

  /// Map JSON dari API (FocusRecordResource) menjadi [FocusRecord].
  static FocusRecord fromJson(Map<String, dynamic> json) {
    return FocusRecord(
      id: json['id'] as String,
      taskId: json['task_id'] as String?,
      mulai: DateTime.parse(json['mulai'] as String),
      durasi: Duration(minutes: json['durasi_menit'] as int? ?? 0),
    );
  }

  /// Ubah [FocusRecord] baru (tanpa id) menjadi map yang diminta API.
  static Map<String, dynamic> toJsonNew(FocusRecord record) {
    return {
      'task_id': record.taskId,
      'mulai': record.mulai.toIso8601String(),
      'durasi_menit': record.durasi.inMinutes,
    };
  }
}
