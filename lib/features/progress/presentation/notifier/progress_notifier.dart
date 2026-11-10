import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ai_study_planner/core/aggregation.dart';
import 'package:ai_study_planner/core/failure.dart';
import 'package:ai_study_planner/core/clock.dart';
import 'package:ai_study_planner/core/system_clock.dart';
import 'package:ai_study_planner/core/models/course.dart';
import 'package:ai_study_planner/data/repositories/course_repository.dart';
import 'package:ai_study_planner/data/repositories/focus_repository.dart';
import 'package:ai_study_planner/data/repositories/task_repository.dart';

/// Notifier untuk Progress.
class ProgressNotifier extends ChangeNotifier {
  ProgressNotifier({
    required this.courseRepository,
    required this.taskRepository,
    required this.focusRepository,
    Clock? clock,
  })  : _clock = clock ?? SystemClock(),
        _aggregator = const ProgressAggregator();

  final CourseRepository courseRepository;
  final TaskRepository taskRepository;
  final FocusRepository focusRepository;
  final Clock _clock;
  final ProgressAggregator _aggregator;

  ProgressStats? _stats;
  List<Course> _courses = [];
  bool _isLoading = false;
  String? _errorMessage;

  ProgressStats? get stats => _stats;
  List<Course> get courses => _courses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Hari ini dari Clock yang disuntik (bukan DateTime.now() di widget).
  DateTime get today => _clock.now();

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    try {
      final courses = await courseRepository.watchCourses().first;
      final tasks = await taskRepository.watchTasks().first;
      final focusRecords = await focusRepository.watchFocusRecords().first;

      _courses = courses;
      _stats = _aggregator.aggregate(
        focusRecords: focusRecords,
        tasks: tasks,
        courses: courses,
        clock: _clock,
      );
    } on Failure catch (failure) {
      _errorMessage = failure.message;
    } catch (_) {
      _errorMessage = 'Terjadi kesalahan saat memuat data';
    }
    _isLoading = false;
    notifyListeners();
  }
}

/// Provider ProgressNotifier; memuat data saat pertama dibaca.
final progressNotifierProvider =
    ChangeNotifierProvider<ProgressNotifier>((ref) {
  return ProgressNotifier(
    courseRepository: ref.watch(courseRepositoryProvider),
    taskRepository: ref.watch(taskRepositoryProvider),
    focusRepository: ref.watch(focusRepositoryProvider),
    clock: ref.watch(clockProvider),
  )..load();
});
