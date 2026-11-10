import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ai_study_planner/l10n/app_localizations.dart';
import 'package:ai_study_planner/core/models/study_session.dart';
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
    // Watch penyedia penuh agar UI dibangun ulang setiap notifyListeners.
    final notifier = ref.watch(calendarNotifierProvider);
    final state = notifier.state;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _WeekStrip(notifier: notifier),
            const SizedBox(height: 16),
            Expanded(child: _CalendarContent(state: state, notifier: notifier)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: l10n('AddSession'),
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (context) => const SessionBottomSheet(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip({required this.notifier});

  final CalendarNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return WeekStripWidget(
      selectedDay: notifier.selectedDay,
      weekDays: notifier.weekDays,
      onDayTap: notifier.selectDay,
      onPreviousWeek: notifier.previousWeek,
      onNextWeek: notifier.nextWeek,
    );
  }
}

class _CalendarContent extends StatelessWidget {
  const _CalendarContent({required this.state, required this.notifier});

  final CalendarState state;
  final CalendarNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      CalendarLoading() => const Center(child: CircularProgressIndicator()),
      CalendarEmpty() => const _EmptyDayCard(
          judul: 'NoSessions',
          deskripsi: 'NoSessionsDescription',
        ),
      CalendarError(:final message) =>
        ErrorRetryCard(message: message, onRetry: notifier.load),
      CalendarContent(:final sessionsByDay) => _SessionDayList(
          notifier: notifier,
          sessionsByDay: sessionsByDay,
        ),
    };
  }
}

class _EmptyDayCard extends StatelessWidget {
  const _EmptyDayCard({required this.judul, required this.deskripsi});

  final String judul;
  final String deskripsi;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              judul == 'NoSessions' ? Icons.calendar_today : Icons.event_busy,
              size: 48,
              color: ColorTokens.moonstone,
              semanticLabel: judul,
            ),
            const SizedBox(height: 16),
            Text(
              l10n(judul),
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w500),
            ),
            Text(
              l10n(deskripsi),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14, color: ColorTokens.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionDayList extends StatelessWidget {
  const _SessionDayList({
    required this.notifier,
    required this.sessionsByDay,
  });

  final CalendarNotifier notifier;
  final Map<DateTime, List<StudySession>> sessionsByDay;

  @override
  Widget build(BuildContext context) {
    final daySessions = sessionsByDay[notifier.selectedDay] ?? [];
    if (daySessions.isEmpty) {
      return const _EmptyDayCard(
        judul: 'SelectedDayNoSessions',
        deskripsi: 'SelectedDayNoSessionsDescription',
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
