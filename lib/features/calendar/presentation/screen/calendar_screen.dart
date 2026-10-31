import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ai_study_planner/data/repositories/session_repository.dart';
import 'package:ai_study_planner/theme/components/error_retry_card.dart';
import 'package:ai_study_planner/theme/color_tokens.dart';
import 'package:ai_study_planner/features/calendar/presentation/notifier/calendar_notifier.dart';
import 'package:ai_study_planner/features/calendar/presentation/widgets/week_strip_widget.dart';
import 'package:ai_study_planner/features/calendar/presentation/widgets/session_card_widget.dart';
import 'package:ai_study_planner/features/calendar/presentation/widgets/session_bottom_sheet.dart';

/// Layar kalender dengan strip minggu dan timeline vertikal.
class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(calendarNotifierProvider.notifier);
    final state = notifier.state;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            WeekStripWidget(
              selectedDay: notifier.selectedDay,
              weekDays: notifier.weekDays,
              onDayTap: notifier.selectDay,
              onPreviousWeek: notifier.previousWeek,
              onNextWeek: notifier.nextWeek,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _buildContent(state, notifier),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => const SessionBottomSheet(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent(CalendarState state, CalendarNotifier notifier) {
    switch (state) {
      case CalendarLoading():
        return const Center(child: CircularProgressIndicator());
      case CalendarEmpty():
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_today, size: 48, color: ColorTokens.moonstone),
              SizedBox(height: 16),
              Text('Belum ada sesi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
              Text('Tambah sesi belajar untuk menjadwalkan waktu.', style: TextStyle(fontSize: 14, color: ColorTokens.textSecondary)),
            ],
          ),
        );
      case CalendarError(:final message):
        return ErrorRetryCard(message: message, onRetry: notifier.load);
      case CalendarContent(:final sessionsByDay):
        final daySessions = sessionsByDay[notifier.selectedDay] ?? [];
        if (daySessions.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy, size: 48, color: ColorTokens.moonstone),
                SizedBox(height: 16),
                Text('Tidak ada sesi pada hari ini', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                Text('Tambah sesi baru untuk hari ini.', style: TextStyle(fontSize: 14, color: ColorTokens.textSecondary)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: daySessions.length,
          itemBuilder: (context, index) {
            final session = daySessions[index];
            return SessionCardWidget(
              session: session,
              onTap: () {},
            );
          },
        );
    }
  }
}