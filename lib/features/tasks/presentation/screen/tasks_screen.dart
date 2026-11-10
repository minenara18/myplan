import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ai_study_planner/l10n/app_localizations.dart';
import 'package:ai_study_planner/core/models/task.dart';
import 'package:ai_study_planner/theme/components/error_retry_card.dart';
import 'package:ai_study_planner/theme/color_tokens.dart';
import 'package:ai_study_planner/features/tasks/presentation/notifier/tasks_notifier.dart';
import 'package:ai_study_planner/features/tasks/presentation/widgets/task_item_widget.dart';
import 'package:ai_study_planner/features/tasks/presentation/widgets/empty_tasks_widget.dart';
import 'package:ai_study_planner/routing/routes.dart';

/// Layar daftar tugas dengan panel kaca, filter, dan chip mata pelajaran.
class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch penyedia penuh agar UI dibangun ulang setiap notifyListeners.
    final notifier = ref.watch(tasksNotifierProvider);
    final state = notifier.state;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const _TasksHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _FilterChip(
                    label: l10n('AllTasks'),
                    icon: Icons.list,
                    isSelected: notifier.filter == 'all',
                    onTap: () => notifier.setFilter('all'),
                  ),
                  _FilterChip(
                    label: l10n('TodayTasks'),
                    icon: Icons.today,
                    isSelected: notifier.filter == 'today',
                    onTap: () => notifier.setFilter('today'),
                  ),
                  _FilterChip(
                    label: l10n('WeekTasks'),
                    icon: Icons.calendar_view_week,
                    isSelected: notifier.filter == 'week',
                    onTap: () => notifier.setFilter('week'),
                  ),
                  _FilterChip(
                    label: l10n('CompletedTasks'),
                    icon: Icons.check_circle,
                    isSelected: notifier.filter == 'completed',
                    onTap: () => notifier.setFilter('completed'),
                  ),
                ],
              ),
            ),
            Expanded(child: _TasksContent(state: state)),
          ],
        ),
      ),
    );
  }
}

class _TasksHeader extends ConsumerWidget {
  const _TasksHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l10n('Tasks'),
              style: TextStyle(
                fontFamily: 'DM Serif Display',
                fontSize: 28,
                color: ColorTokens.textPrimary,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: ColorTokens.moonstone),
            tooltip: l10n('AddTask'),
            onPressed: () => context.go(AppRoutes.tugasBaru),
          ),
        ],
      ),
    );
  }
}

class _TasksContent extends ConsumerWidget {
  const _TasksContent({required this.state});

  final TasksState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(tasksNotifierProvider.notifier);
    return switch (state) {
      TasksLoading() => const Center(child: CircularProgressIndicator()),
      TasksEmpty() => const EmptyTasksWidget(),
      TasksError(:final message) => ErrorRetryCard(
          message: message,
          onRetry: notifier.load,
        ),
      TasksContent(:final tasks) =>
        _TasksList(tasks: tasks, notifier: notifier),
    };
  }
}

class _TasksList extends StatelessWidget {
  const _TasksList({required this.tasks, required this.notifier});

  final List<Task> tasks;
  final TasksNotifier notifier;

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) return const EmptyTasksWidget();
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskItemWidget(
          task: task,
          onToggle: () => notifier.toggleComplete(task.id),
          onUndo: () => notifier.undoDelete(task.id),
          onDelete: () => notifier.softDelete(task.id),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      avatar: Icon(
        icon,
        size: 18,
        color: isSelected ? ColorTokens.textPrimary : ColorTokens.moonstone,
      ),
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: ColorTokens.white.withValues(alpha: 0.8),
      selectedColor: ColorTokens.moonstone,
      checkmarkColor: ColorTokens.textPrimary,
      labelStyle: TextStyle(
        // Kontras AA: teks di atas Moonstone memakai textPrimary, bukan putih.
        color: isSelected ? ColorTokens.textPrimary : ColorTokens.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
