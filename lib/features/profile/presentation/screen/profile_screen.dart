import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ai_study_planner/data/repositories/settings_repository.dart';
import 'package:ai_study_planner/l10n/app_localizations.dart';
import 'package:ai_study_planner/theme/components/error_retry_card.dart';
import 'package:ai_study_planner/theme/color_tokens.dart';
import 'package:ai_study_planner/features/profile/presentation/notifier/profile_notifier.dart';
import 'package:ai_study_planner/features/profile/presentation/widgets/settings_item_widget.dart';

/// Layar Profile: avatar, nama, email, daftar pengaturan, dan tombol keluar.
/// [onLogout] disuntik dari routing agar fitur tidak mengimpor fitur lain.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key, this.onLogout});

  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(profileNotifierProvider);
    final settings = notifier.settings;

    final Widget body;
    if (notifier.isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (notifier.errorMessage != null && settings == null) {
      body = ErrorRetryCard(
        message: notifier.errorMessage!,
        onRetry: notifier.load,
      );
    } else {
      body = _ProfileBody(
        notifier: notifier,
        settings: settings,
        onLogout: onLogout,
      );
    }

    return Scaffold(
      body: SafeArea(child: body),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({
    required this.notifier,
    this.settings,
    this.onLogout,
  });

  final ProfileNotifier notifier;
  final AppSettings? settings;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    final state = settings;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          // Avatar dengan cincin Moonstone
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: ColorTokens.moonstone.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: ColorTokens.moonstone,
                width: 3,
              ),
            ),
            child: const Icon(
              Icons.person,
              size: 48,
              color: ColorTokens.moonstone,
              semanticLabel: 'Avatar',
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n('Pengguna'),
            style: TextStyle(
              fontFamily: 'DM Serif Display',
              fontSize: 28,
              color: ColorTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'pengguna@example.com',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: ColorTokens.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          // Daftar pengaturan
          _SettingsSection(title: l10n('Pengaturan')),
          SettingsItemWidget(
            icon: Icons.notifications,
            iconLabel: 'Pengingat',
            label: l10n('Pengingat'),
            trailing: Switch(
              value: state?.reminderEnabled ?? true,
              activeThumbColor: ColorTokens.moonstone,
              onChanged: (v) async {
                final current = state ??
                    const AppSettings(
                      reminderEnabled: true,
                      defaultPomodoroMinutes: 25,
                      dailyFreeTimeStart: 16,
                      dailyFreeTimeEnd: 21,
                    );
                await notifier.saveSettings(
                  current.copyWith(reminderEnabled: v),
                );
              },
            ),
          ),
          SettingsItemWidget(
            icon: Icons.timer,
            iconLabel: 'Durasi',
            label: l10n('DurasiPomodoro'),
            trailing: Text(
              '${state?.defaultPomodoroMinutes ?? 25} ${l10n('MinuteUnit')}',
              style: const TextStyle(color: ColorTokens.textSecondary),
            ),
            onTap: () {},
          ),
          SettingsItemWidget(
            icon: Icons.access_time,
            iconLabel: 'Waktu luang',
            label: l10n('WaktuLuang'),
            trailing: Text(
              '${state?.dailyFreeTimeStart ?? 16}:00 - ${state?.dailyFreeTimeEnd ?? 21}:00',
              style: const TextStyle(color: ColorTokens.textSecondary),
            ),
            onTap: () {},
          ),
          const SizedBox(height: 24),
          // Tombol keluar
          ConstrainedBox(
            constraints: const BoxConstraints(
                minWidth: double.infinity, minHeight: 48),
            child: OutlinedButton(
              onPressed: () => _showLogoutDialog(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: ColorTokens.error,
                side: const BorderSide(color: ColorTokens.error),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(l10n('Keluar')),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n('KeluarAkun')),
        content: Text(l10n('YakinKeluar')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n('Cancel')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              onLogout?.call();
            },
            child: Text(
              l10n('Keluar'),
              style: const TextStyle(color: ColorTokens.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: ColorTokens.moonstone,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'DM Serif Display',
                fontSize: 18,
                color: ColorTokens.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
