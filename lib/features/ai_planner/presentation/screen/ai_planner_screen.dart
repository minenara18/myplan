import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ai_study_planner/core/models/ai_plan_block.dart';
import 'package:ai_study_planner/core/models/ai_plan_result.dart';
import 'package:ai_study_planner/features/ai_planner/presentation/notifier/ai_planner_notifier.dart';
import 'package:ai_study_planner/features/ai_planner/presentation/widgets/ai_blok_kartu_widget.dart';
import 'package:ai_study_planner/features/ai_planner/presentation/widgets/ai_hasil_aksi_widget.dart';
import 'package:ai_study_planner/features/ai_planner/presentation/widgets/ai_input_bar_widget.dart';
import 'package:ai_study_planner/features/ai_planner/presentation/widgets/ai_masukan_ringkasan_widget.dart';
import 'package:ai_study_planner/features/ai_planner/presentation/widgets/ai_sheet_edit_masukan.dart';
import 'package:ai_study_planner/features/ai_planner/presentation/widgets/ai_skeleton_timeline_widget.dart';
import 'package:ai_study_planner/routing/routes.dart';
import 'package:ai_study_planner/theme/app_theme.dart';
import 'package:ai_study_planner/theme/color_tokens.dart';
import 'package:ai_study_planner/theme/components/error_retry_card.dart';

/// Layar tab tengah: penyusun rencana belajar AI.
class AiPlannerScreen extends ConsumerStatefulWidget {
  const AiPlannerScreen({super.key});

  @override
  ConsumerState<AiPlannerScreen> createState() => _AiPlannerScreenState();
}

class _AiPlannerScreenState extends ConsumerState<AiPlannerScreen> {
  final _kontrolTeks = TextEditingController();

  @override
  void dispose() {
    _kontrolTeks.dispose();
    super.dispose();
  }

  AiPlannerNotifier get _notifier => ref.read(aiPlannerNotifierProvider.notifier);

  void _susun({String? catatan}) {
    _notifier.susun(catatan: catatan?.trim());
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AiPlannerState>(
      aiPlannerNotifierProvider.select((notifier) => notifier.state),
      (sebelumna, sekarang) {
        if (sekarang is AiPlannerTersimpan && sebelumna is! AiPlannerTersimpan) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Rencana diterapkan ke kalender'),
              duration: Duration(seconds: 2),
            ),
          );
          context.go(AppRoutes.kalender);
        }
      },
    );

    final state = ref.watch(aiPlannerNotifierProvider).state;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              _header,
              const SizedBox(height: 12),
              Expanded(child: _isi(state)),
              const SizedBox(height: 12),
              AiInputBarWidget(
                kontroler: _kontrolTeks,
                aktif: state is! AiPlannerMenyimpan,
                padaKirim: () => _susun(catatan: _kontrolTeks.text),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget get _header {
    return const Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rencana AI',
              style: TextStyle(
                fontFamily: AppTheme.dmSerifDisplay,
                fontSize: AppTheme.spacing32,
                color: ColorTokens.textPrimary,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Susun slot belajar otomatis',
              style: TextStyle(
                fontFamily: AppTheme.inter,
                fontSize: 14,
                color: ColorTokens.textSecondary,
              ),
            ),
          ],
        ),
        Spacer(),
      ],
    );
  }

  Widget _isi(AiPlannerState state) {
    return switch (state) {
      AiPlannerLoading() => const SingleChildScrollView(
          child: AiSkeletonTimelineWidget(jumlah: 3),
        ),
      AiPlannerError() => ErrorRetryCard(
          message: state.failure.message,
          icon: Icons.smart_toy_outlined,
          onRetry:
              state.bisaCobaLagi ? _notifier.cobaUlang : _notifier.reset,
        ),
      AiPlannerReady() => _bisaHasil(state),
      AiPlannerIdle() => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _masukanAwal(),
              const SizedBox(height: 16),
              _tombolAksiCepat(),
            ],
          ),
        ),
    };
  }

  Widget _masukanAwal() {
    final masukan = _notifier.masukanDefault;

    return AiMasukanRingkasanWidget(
      mulai: masukan.mulai,
      sampai: masukan.sampai,
      catatan: _kontrolTeks.text,
      onEdit: _bukaSheetEdit,
    );
  }

  Widget _tombolAksiCepat() {
    return Semantics(
      label: 'Susun jadwal minggu ini',
      button: true,
      child: SizedBox(
        height: 48,
        child: FilledButton.icon(
          onPressed: () => _susun(catatan: _kontrolTeks.text),
          style: FilledButton.styleFrom(
            backgroundColor: ColorTokens.moonstone,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
          ),
          icon: const Icon(Icons.auto_awesome, color: Colors.white),
          label: const Text(
            'Susun jadwal minggu ini',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _bisaHasil(AiPlannerReady state) {
    if (state.hasil.sesi.isEmpty) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _masukanAwal(),
            const SizedBox(height: 16),
            _tombolAksiCepat(),
          ],
        ),
      );
    }

    return ListView(
      children: [
        AiMasukanRingkasanWidget(
          mulai: state.hasil.rentangMulai,
          sampai: state.hasil.rentangSampai,
          catatan: state.catatan,
          onEdit: _bukaSheetEdit,
        ),
        const SizedBox(height: 8),
        if (state.hasil.sumber == AiPlanSumber.fallback)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              'AI tidak merespons — pakai penjadwalan fallback dasar.',
              style: TextStyle(
                fontFamily: AppTheme.inter,
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: ColorTokens.textSecondary,
              ),
            ),
          ),
        for (final blok in state.hasil.sesi)
          _kartuBlok(blok, state),
        AiHasilAksiWidget(
          menyimpan: state is AiPlannerMenyimpan,
          padaTerapkan: _notifier.terapkan,
          padaUlang: () => _susun(),
        ),
      ],
    );
  }

  Widget _kartuBlok(AiPlanBlock blok, AiPlannerReady state) {
    final tugas = state.tugas[blok.taskId];

    return AiBlokKartuWidget(
      blok: blok,
      tugas: tugas,
      mataKuliah: tugas == null ? null : state.mataKuliah[tugas.courseId],
      onUbah: () => _ubahJam(blok),
    );
  }

  Future<void> _bukaSheetEdit() async {
    final defaultMasukan = _notifier.masukanDefault;
    final hasil = await showModalBottomSheet<Object>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
      ),
      builder: (_) => AiSheetEditMasukan(
        mulaiAwal: defaultMasukan.mulai,
        sampaiAwal: defaultMasukan.sampai,
        jamMulaiAwal: defaultMasukan.jamMulai,
        jamSelesaiAwal: defaultMasukan.jamSelesai,
      ),
    );

    if (hasil is (DateTime, DateTime, int, int)) {
      final (hariMulai, hariSampai, jamMulai, jamSelesai) = hasil;
      await _notifier.susun(
        mulai: DateTime(hariMulai.year, hariMulai.month, hariMulai.day, jamMulai),
        sampai: DateTime(hariSampai.year, hariSampai.month, hariSampai.day, jamSelesai),
        catatan: _kontrolTeks.text,
      );
    }
  }

  Future<void> _ubahJam(AiPlanBlock blok) async {
    final jamMulaiDipilih = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(blok.mulai),
    );
    if (jamMulaiDipilih == null || mounted == false) return;

    final jamSelesaiDipilih = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(blok.selesai),
    );
    if (jamSelesaiDipilih == null || mounted == false) return;

    final mulai = DateTime(
      blok.mulai.year,
      blok.mulai.month,
      blok.mulai.day,
      jamMulaiDipilih.hour,
      jamMulaiDipilih.minute,
    );
    final selesai = DateTime(
      blok.selesai.year,
      blok.selesai.month,
      blok.selesai.day,
      jamSelesaiDipilih.hour,
      jamSelesaiDipilih.minute,
    );

    if (selesai.isAfter(mulai)) {
      _notifier.perbaruiBlok(blok, mulai, selesai);
    }
  }
}
