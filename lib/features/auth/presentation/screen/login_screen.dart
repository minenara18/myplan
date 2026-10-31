import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ai_study_planner/l10n/app_localizations.dart';
import 'package:ai_study_planner/theme/components/ambient_background.dart';
import 'package:ai_study_planner/theme/components/glass_card.dart';
import 'package:ai_study_planner/theme/color_tokens.dart';
import 'package:ai_study_planner/features/auth/presentation/notifier/auth_notifier.dart';
import 'package:ai_study_planner/features/auth/presentation/widgets/auth_form_field.dart';
import 'package:ai_study_planner/features/auth/presentation/widgets/google_button.dart';

/// Layar login sebagai GlassCard di tengah dengan lingkaran blur di belakangnya.
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(authNotifierProvider.notifier);
    final authState = ref.watch(authNotifierProvider);

    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      body: Stack(
        children: [
          const AmbientBackground(circleCount: 2),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: GlassCard(
                  variant: GlassCardVariant.hero,
                  padding: const EdgeInsets.all(32),
                  child: Form(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(Icons.login, size: 48, color: ColorTokens.moonstone),
                        const SizedBox(height: 24),
                        Text(
                          AppLocalizations.messages['Login'] ?? 'Masuk',
                          style: TextStyle(
                            fontFamily: 'DM Serif Display',
                            fontSize: 32,
                            color: ColorTokens.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppLocalizations.messages['Welcome'] ?? 'Selamat Datang',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: ColorTokens.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        AuthFormField(
                          controller: emailController,
                          label: 'Email',
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email tidak boleh kosong.';
                            }
                            if (!value.contains('@')) {
                              return 'Masukkan email yang valid.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        AuthFormField(
                          controller: passwordController,
                          label: 'Sandi',
                          icon: Icons.lock,
                          isPassword: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Sandi tidak boleh kosong.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        if (authState.errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFBA1A1A).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              authState.errorMessage!,
                              style: const TextStyle(
                                color: Color(0xFFBA1A1A),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: authState.isLoading
                                ? null
                                : () => notifier.login(
                                      emailController.text,
                                      passwordController.text,
                                    ),
                            child: authState.isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Masuk'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        GoogleButton(
                          onPressed: () => notifier.loginWithGoogle(),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            // TODO: navigate to register
                          },
                          child: const Text('Belum punya akun? Daftar'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}