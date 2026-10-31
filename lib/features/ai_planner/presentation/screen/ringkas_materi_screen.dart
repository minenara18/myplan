import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ai_study_planner/core/models/task.dart';
import 'package:ai_study_planner/features/ai_planner/presentation/notifier/ai_summary_notifier.dart';
import 'package:ai_study_planner/theme/app_theme.dart';
import 'package:ai_study_planner/theme/color_tokens.dart';
import 'package:ai_study_planner/theme/components/error_retry_card.dart';
import 'package:ai_study_planner/theme/components/glass_card.dart';

/// Layar Ringkas Materi: tempel teks kuliah, dapat ringkasan,
/// poin kunci, dan 5 pertanyaan latihan; hasil bisa disimpan
/// sebagai catatan pada tugas.
class RingkasMateriScreen extends ConsumerStatefulWidget {
  const RingkasMateriScreen({super.key});

  @override
  ConsumerState<RingkasMateriScreen> createState() =>
      _RingkasMateriScreenState();
}

class _RingkasMateriScreenState extends ConsumerState<RingkasMateriScreen> {
  final _kontrolTeks = TextEditingController();

  @override
  void dispose() {
    _kontrolTeks.dispose();
    super.dispose();
  }

  AiSummaryNotifier get _notifier => ref.read(aiSummaryNotifierProvider.notifier);

  void _ringkas() {
    _notifier.ringkas(_kontrolTeks.text);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiSummaryNotifierProvider).state;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: ColorTokens.textPrimary,
                    ),
                    tooltip: 'Kembali',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Expanded(
                    child: Text(
                      'Ringkas Materi',
                      style: TextStyle(
                        fontFamily: AppTheme.dmSerifDisplay,
                        fontSize: 24,
                        color: ColorTokens.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(child: _isi(state)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _isi(AiSummaryState state) {
    return switch (state) {
      AiSummaryLoading() => const Center(
          child: CircularProgressIndicator(color: ColorTokens.moonstone),
        ),
      AiSummaryError() => ErrorRetryCard(
          message: state.failure.message,
          icon: Icons.smart_toy_outlined,
          onRetry: _ringkas,
        ),
      AiSummaryReady() => _isiHasil(state),
      AiSummaryIdle() => _isiMasukan(),
    };
  }

  Widget _isiMasukan() {
    return GlassCard(
      variant: GlassCardVariant.hero,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Tempel teks kuliah di sini',
            style: TextStyle(
              fontFamily: AppTheme.inter,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ColorTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            flex: 2,
            child: TextField(
              controller: _kontrolTeks,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                filled: true,
                fillColor: ColorTokens.moonstone.withValues(alpha: 0.06),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  borderSide: BorderSide.none,
                ),
                hintText: 'Minimal 50 karakter…',
              ),
              style: const TextStyle(
                fontFamily: AppTheme.inter,
                fontSize: 14,
                color: ColorTokens.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Semantics(
            label: 'Ringkas materi',
            button: true,
            child: SizedBox(
              height: 48,
              child: FilledButton.icon(
                onPressed: _ringkas,
                style: FilledButton.styleFrom(
                  backgroundColor: ColorTokens.moonstone,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  ),
                ),
                icon: const Icon(Icons.auto_awesome, color: Colors.white),
                label: const Text(
                  'Ringkas',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _isiHasil(AiSummaryReady state) {
    return ListView(
      children: [
        _kartuTeks(
          ikon: Icons.article_outlined,
          judul: 'Ringkasan',
          isi: state.hasil.ringkasan,
        ),
        _kartuTeks(
          ikon: Icons.checklist,
          judul: 'Poin kunci',
          isi: state.hasil.poinKunci.map((e) => '• $e').join('\n'),
        ),
        _kartuTeks(
          ikon: Icons.quiz_outlined,
          judul: 'Pertanyaan latihan',
          isi: [
            for (var i = 0; i < state.hasil.pertanyaanLatihan.length; i++)
              '${i + 1}. ${state.hasil.pertanyaanLatihan[i]}',
          ].join('\n'),
        ),
        const SizedBox(height: 8),
        Text(
          'Simpan sebagai catatan:',
          style: const TextStyle(
            fontFamily: AppTheme.inter,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ColorTokens.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        if (state.tugas.isEmpty)
          const Text(
            'Belum ada tugas. Buat tugas dulu di menu Tugas.',
            style: TextStyle(
              fontFamily: AppTheme.inter,
              fontSize: 13,
              color: ColorTokens.textSecondary,
            ),
          )
        else
          for (final tugas in state.tugas)
            _KartuTugasCatatan(
              tugas: tugas,
              ringkasanRingkas: state.hasil.ringkasan,
              padaSimpan: () => _simpanCatatan(tugas),
            ),
      ],
    );
  }

  Future<void> _simpanCatatan(Task tugas) async {
    final berhasil = await _notifier.simpanSebagaiCatatan(tugas);
    if (mounted == false) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          berhasil
              ? 'Catatan tersimpan di "${tugas.judul}"'
              : 'Gagal menyimpan catatan',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _kartuTeks({
    required IconData ikon,
    required String judul,
    required String isi,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: ColorTokens.moonstone.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(ikon, size: 20, color: ColorTokens.moonstone),
              const SizedBox(width: 8),
              Text(
                judul,
                style: const TextStyle(
                  fontFamily: AppTheme.dmSerifDisplay,
                  fontSize: 18,
                  color: ColorTokens.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isi,
            style: const TextStyle(
              fontFamily: AppTheme.inter,
              fontSize: 13,
              height: 1.5,
              color: ColorTokens.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu satu tugas sebagai tujuan simpan catatan.
class _KartuTugasCatatan extends StatelessWidget {
  const _KartuTugasCatatan({
    required this.tugas,
    required this.ringkasanRingkas,
    required this.padaSimpan,
  });

  final Task tugas;
  final String ringkasanRingkas;
  final VoidCallback padaSimpan;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: ColorTokens.moonstone.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: ColorTokens.moonstone.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              tugas.judul,
              style: const TextStyle(
                fontFamily: AppTheme.inter,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: ColorTokens.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_added_outlined,
                size: 20, color: ColorTokens.moonstone),
            tooltip: 'Simpan ringkasan sebagai catatan tugas ini',
            onPressed: padaSimpan,
          ),
        ],
      ),
    );
  }
}
