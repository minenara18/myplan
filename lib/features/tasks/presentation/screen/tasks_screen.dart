import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ai_study_planner/theme/components/error_retry_card.dart';
import 'package:ai_study_planner/theme/color_tokens.dart';
import 'package:ai_study_planner/features/tasks/presentation/notifier/tasks_notifier.dart';
import 'package:ai_study_planner/features/tasks/presentation/widgets/task_item_widget.dart';
import 'package:ai_study_planner/features/tasks/presentation/widgets/empty_tasks_widget.dart';

/// Layar daftar tugas dengan panel kaca, filter, dan chip mata pelajaran.
class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(tasksNotifierProvider.notifier);
    final state = notifier.state;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'Tugas',
                    style: TextStyle(
                      fontFamily: 'DM Serif Display',
                      fontSize: 28,
                      color: ColorTokens.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.add, color: ColorTokens.moonstone),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _FilterChip(
                    label: 'Semua',
                    icon: Icons.list,
                    isSelected: notifier.filter == 'all',
                    onTap: () => notifier.setFilter('all'),
                  ),
                  _FilterChip(
                    label: 'Hari Ini',
                    icon: Icons.today,
                    isSelected: notifier.filter == 'today',
                    onTap: () => notifier.setFilter('today'),
                  ),
                  _FilterChip(
                    label: 'Minggu Ini',
                    icon: Icons.calendar_view_week,
                    isSelected: notifier.filter == 'week',
                    onTap: () => notifier.setFilter('week'),
                  ),
                  _FilterChip(
                    label: 'Selesai',
                    icon: Icons.check_circle,
                    isSelected: notifier.filter == 'completed',
                    onTap: () => notifier.setFilter('completed'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _buildContent(state, notifier),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(TasksState state, TasksNotifier notifier) {
    switch (state) {
      case TasksLoading():
        return const Center(child: CircularProgressIndicator());
      case TasksEmpty():
        return const EmptyTasksWidget();
      case TasksError(:final message):
        return ErrorRetryCard(message: message, onRetry: notifier.load);
      case TasksContent(:final tasks):
        if (tasks.isEmpty) return const EmptyTasksWidget();
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return TaskItemWidget(
              task: task,
              onToggle: () {},
              onDelete: () {},
              onUndo: () {},
            );
          },
        );
    }
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
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        avatar: Icon(icon, size: 16, color: isSelected ? Colors.white : ColorTokens.moonstone),
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: Colors.white.withValues(alpha: 0.8),
        selectedColor: ColorTokens.moonstone,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : ColorTokens.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}