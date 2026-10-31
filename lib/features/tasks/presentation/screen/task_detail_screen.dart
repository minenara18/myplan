import 'package:flutter/material.dart';

import 'package:ai_study_planner/core/models/task.dart';
import 'package:ai_study_planner/theme/color_tokens.dart';

/// Layar detail tugas.
class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({super.key, required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.status == TaskStatus.selesai;

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
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  if (isCompleted)
                    const Icon(Icons.check_circle, color: ColorTokens.moonstone),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
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
                      child: const Icon(Icons.description, size: 48, color: ColorTokens.moonstone),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      task.judul,
                      style: TextStyle(
                        fontFamily: 'DM Serif Display',
                        fontSize: 32,
                        color: ColorTokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (task.catatan != null && task.catatan!.isNotEmpty) ...[
                      Text(
                        task.catatan!,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          color: ColorTokens.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    _InfoRow(icon: Icons.schedule, label: 'Tenggat', value: '${task.tenggat.day}/${task.tenggat.month}/${task.tenggat.year}'),
                    _InfoRow(icon: Icons.timer, label: 'Estimasi', value: '${task.estimasiMenit} menit'),
                    _InfoRow(icon: Icons.flag, label: 'Prioritas', value: _label(task.prioritas)),
                    _InfoRow(icon: Icons.check_circle, label: 'Status', value: task.status == TaskStatus.selesai ? 'Selesai' : 'Belum'),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
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
  const _InfoRow({required this.icon, required this.label, required this.value});

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
                Text(label, style: TextStyle(fontSize: 12, color: ColorTokens.textSecondary)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}