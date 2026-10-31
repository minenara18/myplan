import 'package:ai_study_planner/core/models/task.dart';

/// DTO tugas untuk parsing keluaran API dan penulisan ke API.
class TaskDto {
  const TaskDto._();

  /// Map JSON dari API (TaskResource) menjadi [Task].
  static Task fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      courseId: json['course_id'] as String,
      judul: json['judul'] as String,
      catatan: json['catatan'] as String?,
      tenggat: DateTime.parse(json['tenggat'] as String),
      estimasiMenit: json['estimasi_menit'] as int,
      prioritas: _parsePrioritas(json['prioritas']),
      status: _parseStatus(json['status']),
    );
  }

  /// Ubah [Task] sebagai tugas baru (tanpa id).
  static Map<String, dynamic> toJsonNew(Task task) {
    return {
      'course_id': task.courseId,
      'judul': task.judul,
      if (task.catatan != null) 'catatan': task.catatan,
      'tenggat': task.tenggat.toIso8601String(),
      'estimasi_menit': task.estimasiMenit,
      'prioritas': task.prioritas.name,
      'status': task.status.name,
    };
  }

  /// Ubah [Task] menjadi map yang diminta API.
  static Map<String, dynamic> toJson(Task task) {
    return {
      'course_id': task.courseId,
      'judul': task.judul,
      if (task.catatan != null) 'catatan': task.catatan,
      'tenggat': task.tenggat.toIso8601String(),
      'estimasi_menit': task.estimasiMenit,
      'prioritas': task.prioritas.name,
      'status': task.status.name,
    };
  }

  static Priority _parsePrioritas(dynamic value) {
    switch (value?.toString()) {
      case 'tinggi':
        return Priority.tinggi;
      case 'rendah':
        return Priority.rendah;
      case 'sedang':
      default:
        return Priority.sedang;
    }
  }

  static TaskStatus _parseStatus(dynamic value) {
    switch (value?.toString()) {
      case 'selesai':
        return TaskStatus.selesai;
      case 'berjalan':
        return TaskStatus.berjalan;
      case 'belum':
      default:
        return TaskStatus.belum;
    }
  }
}
