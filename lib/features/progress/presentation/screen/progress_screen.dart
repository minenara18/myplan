import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ai_study_planner/core/aggregation.dart';
import 'package:ai_study_planner/l10n/app_localizations.dart';
import 'package:ai_study_planner/theme/components/error_retry_card.dart';
import 'package:ai_study_planner/theme/color_tokens.dart';
import 'package:ai_study_planner/features/progress/presentation/notifier/progress_notifier.dart';
import 'package:ai_study_planner/features/progress/presentation/widgets/donut_chart_widget.dart';
import 'package:ai_study_planner/features/progress/presentation/widgets/stat_cards_widget.dart';
import 'package:ai_study_planner/features/progress/presentation/widgets/weekly_bar_chart_widget.dart';

/// Layar Progress: bar chart mingguan, 3 kartu statistik, dan donut distribusi.
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(progressNotifierProvider);
    final stats = notifier.stats;

    final Widget body;
    if (notifier.isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (notifier.errorMessage != null) {
      body = ErrorRetryCard(
        message: notifier.errorMessage!,
        onRetry: notifier.load,
      );
    } else {
      body = _ProgressBody(stats: stats, notifier: notifier);
    }

    return Scaffold(
      body: SafeArea(child: body),
    );
  }
}

class _ProgressBody extends StatelessWidget {
  const _ProgressBody({required this.stats, required this.notifier});

  final ProgressStats? stats;
  final ProgressNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            l10n('ProgressBelajar'),
            style: TextStyle(
              fontFamily: 'DM Serif Display',
              fontSize: 32,
              color: ColorTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 24),

          // Bar chart mingguan
          Text(
            l10n('AktivitasMingguIni'),
            style: TextStyle(
              fontFamily: 'DM Serif Display',
              fontSize: 20,
              color: ColorTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          WeeklyBarChartWidget(
            stats: stats,
            hariIni: notifier.today,
          ),
          const SizedBox(height: 24),

          // 3 kartu statistik
          StatCardsWidget(stats: stats),
          const SizedBox(height: 24),

          // Donut distribusi per mata pelajaran
          Text(
            l10n('DistribusiMataPelajaran'),
            style: TextStyle(
              fontFamily: 'DM Serif Display',
              fontSize: 20,
              color: ColorTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          DonutChartWidget(
            stats: stats,
            courses: notifier.courses,
          ),
        ],
      ),
    );
  }
}
