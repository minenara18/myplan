import 'package:equatable/equatable.dart';

/// Prioritas tugas.
enum Priority { tinggi, sedang, rendah }

/// Status tugas.
enum TaskStatus { belum, berjalan, selesai }

/// Tugas — model nilai immutable dengan kesetaraan dan copyWith.
class Task extends Equatable {
  const Task({
    required this.id,
    required this.courseId,
    required this.judul,
    this.catatan,
    required this.tenggat,
    required this.estimasiMenit,
    required this.prioritas,
    required this.status,
  });

  final String id;
  final String courseId;
  final String judul;
  final String? catatan;
  final DateTime tenggat;
  final int estimasiMenit;
  final Priority prioritas;
  final TaskStatus status;

  Task copyWith({
    String? id,
    String? courseId,
    String? judul,
    String? catatan,
    DateTime? tenggat,
    int? estimasiMenit,
    Priority? prioritas,
    TaskStatus? status,
  }) {
    return Task(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      judul: judul ?? this.judul,
      catatan: catatan ?? this.catatan,
      tenggat: tenggat ?? this.tenggat,
      estimasiMenit: estimasiMenit ?? this.estimasiMenit,
      prioritas: prioritas ?? this.prioritas,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props =>
      [id, courseId, judul, catatan, tenggat, estimasiMenit, prioritas, status];
}