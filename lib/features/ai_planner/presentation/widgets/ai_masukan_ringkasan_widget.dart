import 'package:flutter/material.dart';

import 'package:ai_study_planner/theme/components/glass_card.dart';
import 'package:ai_study_planner/theme/color_tokens.dart';

/// Ringkasan masukan rencana: rentang tanggal, jendela waktu luang,
/// dan catatan pengguna. Bisa diedit lewat tombol ikon pensil.
class AiMasukanRingkasanWidget extends StatelessWidget {
  const AiMasukanRingkasanWidget({
    super.key,
    required this.mulai,
    required this.sampai,
    this.catatan = '',
    this.onEdit,
    this.variant = GlassCardVariant.hero,
  });

  final DateTime mulai;
  final DateTime sampai;
  final String catatan;
  final VoidCallback? onEdit;

  /// Default hero memakai BackdropFilter; di dalam daftar yang bisa
  /// digulir harus memakai [GlassCardVariant.standard] agar tidak ada
  /// blur di item daftar.
  final GlassCardVariant variant;

  static const List<String> _namaHari = [
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
    'Min',
  ];

  String _format(DateTime hari) {
    final nama = _namaHari[hari.weekday - 1];

    return '$nama ${hari.day} ${_namaBulan(hari.month)}';
  }

  static String _namaBulan(int bulan) => const [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des',
      ][bulan - 1];

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      variant: variant,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.date_range,
                size: 18,
                color: ColorTokens.moonstone,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${_format(mulai)} – ${_format(sampai)}',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ColorTokens.textPrimary,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: ColorTokens.moonstone,
                  semanticLabel: 'Ubah masukan rencana',
                ),
                tooltip: 'Ubah masukan rencana',
                padding: const EdgeInsets.all(12),
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                onPressed: onEdit,
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.schedule, size: 18, color: ColorTokens.moonstoneTint),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Waktu luang 16.00 – 21.00 setiap hari',
                  // Membungkus tanpa ellipsis agar tetap terbaca penuh
                  // pada skala teks besar.
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: ColorTokens.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          if (catatan.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.sticky_note_2_outlined,
                  size: 18,
                  color: ColorTokens.moonstone,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    catatan.trim(),
                    // Membungkus, tanpa ellipsis, agar teks catatan tetap
                    // terbaca penuh pada skala teks besar.
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: ColorTokens.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
