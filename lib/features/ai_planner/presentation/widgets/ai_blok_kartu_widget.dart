import 'package:flutter/material.dart';

import 'package:ai_study_planner/core/models/ai_plan_block.dart';
import 'package:ai_study_planner/core/models/course.dart';
import 'package:ai_study_planner/core/models/task.dart';
import 'package:ai_study_planner/theme/app_theme.dart';
import 'package:ai_study_planner/theme/color_tokens.dart';
import 'package:ai_study_planner/theme/components/priority_chip.dart' as chip;

/// Kartu satu blok sesi hasil AI: ikon mata kuliah, judul tugas,
/// jam, durasi, chip prioritas, alasan, dan tombol Ubah.
class AiBlokKartuWidget extends StatelessWidget {
  const AiBlokKartuWidget({
    super.key,
    required this.blok,
    required this.tugas,
    required this.mataKuliah,
    this.onUbah,
  });

  final AiPlanBlock blok;
  final Task? tugas;
  final Course? mataKuliah;
  final VoidCallback? onUbah;

  String get _durasiTeks {
    final menit = blok.durasi.inMinutes;
    if (menit >= 60) {
      final jam = menit ~/ 60;
      final sisa = menit % 60;

      return sisa == 0 ? '$jam jam' : '$jam j $sisa mnt';
    }

    return '$menit mnt';
  }

  String _formatJam(DateTime waktu) {
    final jam = waktu.hour.toString().padLeft(2, '0');
    final menit = waktu.minute.toString().padLeft(2, '0');

    return '$jam.$menit';
  }

  @override
  Widget build(BuildContext context) {
    final icon = mataKuliah?.ikon ?? Icons.school_outlined;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorTokens.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: ColorTokens.moonstone.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: ColorTokens.moonstone.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: ColorTokens.moonstone.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Icon(icon, color: ColorTokens.moonstone),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tugas?.judul ?? 'Tugas',
                      style: const TextStyle(
                        fontFamily: AppTheme.inter,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ColorTokens.textPrimary,
                      ),
                      // Judul dibungkus penuh, tanpa ellipsis, aman skala 2.0.
                    ),
                    const SizedBox(height: 2),
                    Text(
                      mataKuliah?.nama ?? 'Mata kuliah',
                      style: const TextStyle(
                        fontFamily: AppTheme.inter,
                        fontSize: 12,
                        color: ColorTokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (onUbah != null)
                Semantics(
                  label: 'Ubah jam sesi',
                  button: true,
                  child: IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 20,
                      color: ColorTokens.moonstoneTint,
                    ),
                    tooltip: 'Ubah jam sesi',
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                    onPressed: onUbah,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 16,
                color: ColorTokens.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                '${_formatJam(blok.mulai)} – ${_formatJam(blok.selesai)}',
                style: const TextStyle(
                  fontFamily: AppTheme.inter,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: ColorTokens.textPrimary,
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.timelapse_outlined,
                size: 16,
                color: ColorTokens.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                _durasiTeks,
                style: const TextStyle(
                  fontFamily: AppTheme.inter,
                  fontSize: 13,
                  color: ColorTokens.textSecondary,
                ),
              ),
              const Spacer(),
              // Chip prioritas Vanilla agar kontras dengan latar putih.
              chip.PriorityChip(priority: _chipPrioritas(tugas?.prioritas)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            blok.alasan,
            style: const TextStyle(
              fontFamily: AppTheme.inter,
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: ColorTokens.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Peta prioritas model tugas → prioritas chip tema.
  static chip.Priority _chipPrioritas(Priority? tugasPrioritas) {
    return switch (tugasPrioritas) {
      Priority.tinggi => chip.Priority.tinggi,
      Priority.rendah => chip.Priority.rendah,
      Priority.sedang || null => chip.Priority.sedang,
    };
  }
}
