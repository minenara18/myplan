import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ai_study_planner/core/models/task.dart';
import 'package:ai_study_planner/features/tasks/presentation/notifier/tasks_notifier.dart';
import 'package:ai_study_planner/theme/color_tokens.dart';

/// Layar detail tugas. Data tugas diambil dari TasksNotifier lewat
/// [tugasId] dari path param, bukan objek lewat extra.
class TaskDetailScreen extends ConsumerWidget {
  const TaskDetailScreen({super.key, required this.tugasId});

  final String tugasId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tasksNotifierProvider.notifier).state;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    tooltip: 'Kembali',
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: switch (state) {
                TasksLoading() =>
                  const Center(child: CircularProgressIndicator()),
                TasksError(:final message) => Center(
                    child: Text(
                      message,
                      style: const TextStyle(color: ColorTokens.textSecondary),
                    ),
                  ),
                TasksEmpty() => const Center(
                    child: Text(
                      'Tugas tidak ditemukan.',
                      style: TextStyle(color: ColorTokens.textSecondary),
                    ),
                  ),
                TasksContent(:final tasks) => _detail(tasks),
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _detail(List<Task> tasks) {
    Task? task;
    for (final t in tasks) {
      if (t.id == tugasId) {
        task = t;
        break;
      }
    }
    if (task == null) {
      return const Center(
        child: Text(
          'Tugas tidak ditemukan.',
          style: TextStyle(color: ColorTokens.textSecondary),
        ),
      );
    }

    final isCompleted = task.status == TaskStatus.selesai;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: ColorTokens.moonstone.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.description,
                size: 48, color: ColorTokens.moonstone),
          ),
          const SizedBox(height: 24),
          Text(
            task.judul,
            style: const TextStyle(
              fontFamily: 'DM Serif Display',
              fontSize: 32,
              color: ColorTokens.textPrimary,
            ),
          ),
          if (isCompleted)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(Icons.check_circle,
                      size: 18, color: ColorTokens.textPrimary),
                  SizedBox(width: 4),
                  Text(
                    'Selesai',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ColorTokens.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          if (task.catatan != null && task.catatan!.isNotEmpty) ...[
            Text(
              task.catatan!,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                color: ColorTokens.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
          ],
          _InfoRow(
              icon: Icons.schedule,
              label: 'Tenggat',
              value:
                  '${task.tenggat.day}/${task.tenggat.month}/${task.tenggat.year}'),
          _InfoRow(
              icon: Icons.timer,
              label: 'Estimasi',
              value: '${task.estimasiMenit} menit'),
          _InfoRow(
              icon: Icons.flag,
              label: 'Prioritas',
              value: _label(task.prioritas)),
          _InfoRow(
              icon: Icons.check_circle,
              label: 'Status',
              value: task.status == TaskStatus.selesai ? 'Selesai' : 'Belum'),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _label(Priority p) {
    switch (p) {
      case Priority.tinggi:
        return 'Tinggi';
      case Priority.sedang:
        return 'Sedang';
      case Priority.rendah:
        return 'Rendah';
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: ColorTokens.moonstone),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 12, color: ColorTokens.textSecondary)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
