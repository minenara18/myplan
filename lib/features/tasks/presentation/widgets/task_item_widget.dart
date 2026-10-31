import 'package:flutter/material.dart';

import 'package:ai_study_planner/core/models/task.dart';
import 'package:ai_study_planner/theme/color_tokens.dart';

/// Item tugas dengan checkbox bulat, ikon tanggal, penanda prioritas.
class TaskItemWidget extends StatelessWidget {
  const TaskItemWidget({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
    required this.onUndo,
  });

  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.status == TaskStatus.selesai;

    return Dismissible(
      key: ValueKey(task.id),
      background: Container(
        color: Colors.green,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        child: const Icon(Icons.check, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: const Color(0xFFBA1A1A),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          onToggle();
        } else {
          onDelete();
        }
      },
      confirmDismiss: (direction) async => true,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: ColorTokens.moonstone.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            GestureDetector(
              key: const Key('task_checkbox'),
              onTap: onToggle,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isCompleted ? ColorTokens.vanilla : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCompleted ? ColorTokens.vanilla : ColorTokens.moonstone,
                    width: 2,
                  ),
                ),
                child: isCompleted
                    ? const Icon(Icons.check, size: 16, color: ColorTokens.textPrimary)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          task.judul,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isCompleted
                                ? ColorTokens.textSecondary.withValues(alpha: 0.6)
                                : ColorTokens.textPrimary,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (task.catatan != null && task.catatan!.isNotEmpty)
                        Icon(Icons.note, size: 14, color: ColorTokens.moonstone),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 14, color: ColorTokens.moonstone),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(task.tenggat),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: ColorTokens.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _PriorityIndicator(priority: task.prioritas),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _PriorityIndicator extends StatelessWidget {
  const _PriorityIndicator({required this.priority});

  final Priority priority;

  @override
  Widget build(BuildContext context) {
    final color = switch (priority) {
      Priority.tinggi => ColorTokens.moonstone,
      Priority.sedang => ColorTokens.moonstoneTint,
      Priority.rendah => ColorTokens.vanilla,
    };
    final icon = switch (priority) {
      Priority.tinggi => Icons.error_outline,
      Priority.sedang => Icons.warning_amber_outlined,
      Priority.rendah => Icons.info_outline,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            _label(priority),
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
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