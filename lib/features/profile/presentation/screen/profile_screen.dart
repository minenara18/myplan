import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ai_study_planner/data/repositories/settings_repository.dart';
import 'package:ai_study_planner/theme/components/error_retry_card.dart';
import 'package:ai_study_planner/theme/color_tokens.dart';
import 'package:ai_study_planner/features/profile/presentation/notifier/profile_notifier.dart';
import 'package:ai_study_planner/features/profile/presentation/widgets/settings_item_widget.dart';

/// Layar Profile: avatar, nama, email, daftar pengaturan, dan tombol keluar.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(profileNotifierProvider.notifier);
    final state = ref.watch(profileNotifierProvider);

    final Widget body;
    if (notifier.isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (notifier.errorMessage != null && state.settings == null) {
      body = ErrorRetryCard(
        message: notifier.errorMessage!,
        onRetry: () async {
          await notifier.load();
        },
      );
    } else {
      body = _profileBody(context, ref, notifier, state);
    }

    return Scaffold(
      body: SafeArea(child: body),
    );
  }

  Widget _profileBody(
    BuildContext context,
    WidgetRef ref,
    ProfileNotifier notifier,
    ProfileNotifier state,
  ) {
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
                child: const Icon(Icons.person, size: 48, color: ColorTokens.moonstone),
              ),
              const SizedBox(height: 16),
              const Text(
                'Pengguna',
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
              _SettingsSection(title: 'Pengaturan'),
              SettingsItemWidget(
                icon: Icons.notifications,
                label: 'Pengingat',
                trailing: Switch(
                  value: state.settings?.reminderEnabled ?? true,
                  activeThumbColor: ColorTokens.moonstone,
                  onChanged: (v) async {
                    final current = state.settings ??
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
                label: 'Durasi Pomodoro Bawaan',
                trailing: Text(
                  '${state.settings?.defaultPomodoroMinutes ?? 25} menit',
                  style: TextStyle(color: ColorTokens.textSecondary),
                ),
                onTap: () {},
              ),
              SettingsItemWidget(
                icon: Icons.access_time,
                label: 'Waktu Luang Harian',
                trailing: Text(
                  '${state.settings?.dailyFreeTimeStart ?? 16}:00 â€“ ${state.settings?.dailyFreeTimeEnd ?? 21}:00',
                  style: TextStyle(color: ColorTokens.textSecondary),
                ),
                onTap: () {},
              ),
              const SizedBox(height: 24),
              // Tombol keluar
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () => _showLogoutDialog(context, notifier),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFBA1A1A),
                    side: const BorderSide(color: Color(0xFFBA1A1A)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Keluar'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
  }

  Future<void> _showLogoutDialog(BuildContext context, ProfileNotifier notifier) async {
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar Akun'),
        content: const Text('Yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              notifier.logout();
            },
            child: const Text('Keluar', style: TextStyle(color: Color(0xFFBA1A1A))),
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
          Text(
            title,
            style: TextStyle(
              fontFamily: 'DM Serif Display',
              fontSize: 18,
              color: ColorTokens.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Provider ProfileNotifier.
final profileScreenNotifierProvider =
    ChangeNotifierProvider<ProfileNotifier>((ref) {
  final repo = ref.watch(settingsRepositoryProvider);
  return ProfileNotifier(repo);
});