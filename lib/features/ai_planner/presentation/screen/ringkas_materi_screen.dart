import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ai_study_planner/core/models/ai_summary.dart';
import 'package:ai_study_planner/core/models/task.dart';
import 'package:ai_study_planner/features/ai_planner/presentation/notifier/ai_summary_notifier.dart';
import 'package:ai_study_planner/l10n/app_localizations.dart';
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

  AiSummaryNotifier get _notifier =>
      ref.read(aiSummaryNotifierProvider.notifier);

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
              const _RingkasHeader(),
              const SizedBox(height: 12),
              Expanded(child: _IsiRingkas(state: state, padaRingkas: _ringkas)),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingkasHeader extends StatelessWidget {
  const _RingkasHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: ColorTokens.textPrimary,
          ),
          tooltip: l10n('Kembali'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        Expanded(
          child: Text(
            l10n('RingkasMateri'),
            style: const TextStyle(
              fontFamily: AppTheme.dmSerifDisplay,
              fontSize: 24,
              color: ColorTokens.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _IsiRingkas extends StatelessWidget {
  const _IsiRingkas({required this.state, required this.padaRingkas});

  final AiSummaryState state;
  final VoidCallback padaRingkas;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      AiSummaryLoading() => const Center(
          child: CircularProgressIndicator(color: ColorTokens.moonstone),
        ),
      AiSummaryError(:final failure) => ErrorRetryCard(
          message: failure.message,
          icon: Icons.smart_toy_outlined,
          onRetry: padaRingkas,
        ),
      AiSummaryReady(:final hasil, :final tugas) => _HasilListView(
          hasil: hasil,
          tugas: tugas,
        ),
      AiSummaryIdle() => _MasukanKartu(padaRingkas: padaRingkas),
    };
  }
}

/// Masukan teks materi di state awal. Hero card TIDAK di dalam daftar.
class _MasukanKartu extends StatelessWidget {
  const _MasukanKartu({required this.padaRingkas});

  final VoidCallback padaRingkas;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      variant: GlassCardVariant.hero,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n('TempelTeksKuliah'),
            style: const TextStyle(
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
                hintText: l10n('MinimalKarakter'),
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
            label: l10n('RingkasMateri'),
            button: true,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: FilledButton.icon(
                onPressed: padaRingkas,
                style: FilledButton.styleFrom(
                  backgroundColor: ColorTokens.moonstone,
                  foregroundColor: ColorTokens.textPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  ),
                ),
                icon: const Icon(Icons.auto_awesome),
                label: Text(
                  l10n('Ringkas'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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

/// Hasil ringkasan memakai ListView.builder dengan konten per item.
class _HasilListView extends StatelessWidget {
  const _HasilListView({required this.hasil, required this.tugas});

  final AiSummary hasil;
  final List<Task> tugas;

  @override
  Widget build(BuildContext context) {
    final items = <_HasilItemDef>[
      _HasilItemDef(
        ikon: Icons.article_outlined,
        judul: l10n('Ringkasan'),
        isi: hasil.ringkasan,
      ),
      _HasilItemDef(
        ikon: Icons.checklist,
        judul: l10n('PoinKunci'),
        isi: hasil.poinKunci.map((e) => '• $e').join('\n'),
      ),
      _HasilItemDef(
        ikon: Icons.quiz_outlined,
        judul: l10n('Latihan'),
        isi: [
          for (var i = 0; i < hasil.pertanyaanLatihan.length; i++)
            '${i + 1}. ${hasil.pertanyaanLatihan[i]}',
        ].join('\n'),
      ),
    ];

    final barisLain = <Widget>[
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          l10n('SimpanSebagaiCatatan'),
          style: const TextStyle(
            fontFamily: AppTheme.inter,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ColorTokens.textPrimary,
          ),
        ),
      ),
      if (tugas.isEmpty)
        Text(
          l10n('BelumAdaTugasBuatDulu'),
          style: const TextStyle(
            fontFamily: AppTheme.inter,
            fontSize: 13,
            color: ColorTokens.textSecondary,
          ),
        )
      else
        for (final tugas_ in tugas)
          _KartuTugasCatatan(
            tugas: tugas_,
            ringkasanRingkas: hasil.ringkasan,
            padaSimpan: () => _simpan(context, tugas_),
          ),
    ];

    return ListView.builder(
      itemCount: items.length + barisLain.length,
      itemBuilder: (context, index) {
        if (index < items.length) {
          return _KartuTeks(
            ikon: items[index].ikon,
            judul: items[index].judul,
            isi: items[index].isi,
          );
        }
        return barisLain[index - items.length];
      },
    );
  }

  Future<void> _simpan(BuildContext context, Task tugas) async {
    final notifier = ProviderScope.containerOf(context, listen: false)
        .read(aiSummaryNotifierProvider.notifier);
    final berhasil = await notifier.simpanSebagaiCatatan(tugas);
    if (context.mounted == false) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          berhasil
              ? 'Catatan tersimpan di "${tugas.judul}"'
              : l10n('GagalSimpanCatatan'),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _HasilItemDef {
  const _HasilItemDef({
    required this.ikon,
    required this.judul,
    required this.isi,
  });

  final IconData ikon;
  final String judul;
  final String isi;
}

/// Kartu satu blok teks hasil (ringkasan/poin/latihan).
class _KartuTeks extends StatelessWidget {
  const _KartuTeks({
    required this.ikon,
    required this.judul,
    required this.isi,
  });

  final IconData ikon;
  final String judul;
  final String isi;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorTokens.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: ColorTokens.moonstone.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(ikon, size: 20, color: ColorTokens.moonstone,
                  semanticLabel: judul),
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
              // Dibungkus, tanpa ellipsis: judul panjang tetap terbaca.
              style: const TextStyle(
                fontFamily: AppTheme.inter,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: ColorTokens.textPrimary,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_added_outlined,
                size: 20, color: ColorTokens.moonstone),
            tooltip: l10n('SimpanSebagaiCatatanTugas'),
            onPressed: padaSimpan,
          ),
        ],
      ),
    );
  }
}
