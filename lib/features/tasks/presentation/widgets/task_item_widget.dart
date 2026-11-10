import 'package:flutter/material.dart';

import 'package:ai_study_planner/core/models/task.dart';
import 'package:ai_study_planner/l10n/app_localizations.dart';
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
        color: ColorTokens.success,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        child: const Icon(Icons.check, color: ColorTokens.white, semanticLabel: 'Tandai selesai'),
      ),
      secondaryBackground: Container(
        color: ColorTokens.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete,
            color: ColorTokens.white, semanticLabel: 'Hapus tugas'),
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
          color: ColorTokens.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: ColorTokens.moonstone.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Target sentuh 48px: lingkaran visual tetap 24px, area sentuh 48.
            Semantics(
              label:
                  isCompleted ? 'Tandai belum selesai' : 'Tandai tugas selesai',
              button: true,
              child: GestureDetector(
                key: const Key('task_checkbox'),
                onTap: onToggle,
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                      color: isCompleted
                          ? ColorTokens.vanilla
                          : ColorTokens.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCompleted
                              ? ColorTokens.vanilla
                              : ColorTokens.moonstone,
                          width: 2,
                        ),
                      ),
                      child: isCompleted
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: ColorTokens.textPrimary,
                            )
                          : null,
                    ),
                  ),
                ),
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
                                ? ColorTokens.textSecondary
                                : ColorTokens.textPrimary,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                          // Judul dibungkus, tidak ada ellipsis: aman pada skala 2.0
                          // karena kartu bisa tumbuh secara vertikal.
                        ),
                      ),
                      if (task.catatan != null && task.catatan!.isNotEmpty)
                        const Icon(Icons.note,
                            size: 14,
                            color: ColorTokens.moonstone,
                            semanticLabel: 'Ada catatan'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Wrap: pada skala teks besar indikator prioritas pindah
                  // ke baris berikutnya, bukan terpotong di tepi kartu.
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.schedule,
                              size: 14,
                              color: ColorTokens.moonstone,
                              semanticLabel: 'Tenggat'),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(task.tenggat),
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              color: ColorTokens.textSecondary,
                            ),
                          ),
                        ],
                      ),
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
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Ags',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
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
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            _label(priority),
            // Label memakai warna teks token agar kontras AA di atas kaca;
            // bentuk ikon berbeda memastikan status tidak hanya disangga warna.
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: ColorTokens.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _label(Priority p) {
    switch (p) {
      case Priority.tinggi:
        return l10n('Tinggi');
      case Priority.sedang:
        return l10n('Sedang');
      case Priority.rendah:
        return l10n('Rendah');
    }
  }
}
