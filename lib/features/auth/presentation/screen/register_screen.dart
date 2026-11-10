import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ai_study_planner/features/auth/presentation/notifier/auth_notifier.dart';
import 'package:ai_study_planner/features/auth/presentation/widgets/auth_form_field.dart';
import 'package:ai_study_planner/features/auth/presentation/widgets/google_button.dart';
import 'package:ai_study_planner/l10n/app_localizations.dart';
import 'package:ai_study_planner/routing/routes.dart';
import 'package:ai_study_planner/theme/color_tokens.dart';
import 'package:ai_study_planner/theme/components/ambient_background.dart';
import 'package:ai_study_planner/theme/components/glass_card.dart';

/// Layar daftar sebagai GlassCard di tengah dengan lingkaran blur di belakangnya.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  // Controller dibuat sekali di initState dan selalu di-dispose
  // (sebelumnya dibuat di build sehingga bocor di tiap rebuild).
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(authNotifierProvider.notifier);
    final authState = ref.watch(authNotifierProvider);

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
                        const Icon(Icons.person_add,
                            size: 48,
                            color: ColorTokens.moonstone,
                            semanticLabel: 'Daftar'),
                        const SizedBox(height: 24),
                        Text(
                          l10n('Register'),
                          style: TextStyle(
                            fontFamily: 'DM Serif Display',
                            fontSize: 32,
                            color: ColorTokens.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n('BuatAkunBaru'),
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: ColorTokens.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        AuthFormField(
                          controller: _emailController,
                          label: l10n('Email'),
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n('EmailKosong');
                            }
                            if (!value.contains('@')) {
                              return l10n('EmailTidakValid');
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        AuthFormField(
                          controller: _passwordController,
                          label: l10n('Sandi'),
                          icon: Icons.lock,
                          isPassword: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n('SandiKosong');
                            }
                            if (value.length < 6) {
                              return l10n('SandiMinimalEnam');
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        AuthFormField(
                          controller: _confirmPasswordController,
                          label: l10n('KonfirmasiSandi'),
                          icon: Icons.lock_outline,
                          isPassword: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n('KonfirmasiKosong');
                            }
                            if (value != _passwordController.text) {
                              return l10n('SandiTidakCocok');
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        if (authState.errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color:
                                  ColorTokens.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              authState.errorMessage!,
                              style: const TextStyle(
                                color: ColorTokens.error,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        const SizedBox(height: 24),
                        ConstrainedBox(
                          constraints:
                              const BoxConstraints(minHeight: 48),
                          child: ElevatedButton(
                            onPressed: authState.isLoading
                                ? null
                                : () => notifier.register(
                                      _emailController.text,
                                      _passwordController.text,
                                    ),
                            child: authState.isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(l10n('Register')),
                          ),
                        ),
                        const SizedBox(height: 16),
                        GoogleButton(
                          onPressed: () => notifier.loginWithGoogle(),
                        ),
                        const SizedBox(height: 16),
                        // Ke /login lewat GoRouter (sebelumnya TODO tak berfungsi).
                        TextButton(
                          onPressed: () => context.go(AppRoutes.login),
                          child: Text(l10n('SudahPunyaAkun')),
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
