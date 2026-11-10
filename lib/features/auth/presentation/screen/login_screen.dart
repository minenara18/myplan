import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ai_study_planner/l10n/app_localizations.dart';
import 'package:ai_study_planner/theme/components/ambient_background.dart';
import 'package:ai_study_planner/theme/components/glass_card.dart';
import 'package:ai_study_planner/theme/color_tokens.dart';
import 'package:ai_study_planner/features/auth/presentation/notifier/auth_notifier.dart';
import 'package:ai_study_planner/features/auth/presentation/widgets/auth_form_field.dart';
import 'package:ai_study_planner/features/auth/presentation/widgets/google_button.dart';
import 'package:ai_study_planner/routing/routes.dart';

/// Layar login sebagai GlassCard di tengah dengan lingkaran blur di belakangnya.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit(AuthNotifier notifier) {
    notifier.login(_emailController.text, _passwordController.text);
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
                        const Icon(
                          Icons.login,
                          size: 48,
                          color: ColorTokens.moonstone,
                          semanticLabel: 'Masuk',
                        ),
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
                          AppLocalizations.messages['Welcome'] ??
                              'Selamat Datang',
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
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        if (authState.errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: ColorTokens.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              authState.errorMessage!,
                              style: const TextStyle(
                                color: ColorTokens.error,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        const SizedBox(height: 24),
                        // Tombol pakai batas minimum agar bisa membesar di skala teks 2.0.
                        ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 48),
                          child: ElevatedButton(
                            onPressed: authState.isLoading
                                ? null
                                : () => _submit(notifier),
                            child: authState.isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(l10n('Login')),
                          ),
                        ),
                        const SizedBox(height: 16),
                        GoogleButton(
                          onPressed: () => notifier.loginWithGoogle(),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => context.go(AppRoutes.register),
                          child: Text(l10n('BelumPunyaAkun')),
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
