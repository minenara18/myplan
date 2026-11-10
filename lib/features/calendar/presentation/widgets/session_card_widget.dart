import 'package:flutter/material.dart';

import 'package:ai_study_planner/core/models/study_session.dart';
import 'package:ai_study_planner/l10n/app_localizations.dart';
import 'package:ai_study_planner/theme/color_tokens.dart';

/// Kartu sesi kaca di timeline vertikal.
class SessionCardWidget extends StatelessWidget {
  const SessionCardWidget({
    super.key,
    required this.session,
    required this.onTap,
  });

  final StudySession session;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final durasi = session.selesai.difference(session.mulai);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ColorTokens.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: ColorTokens.moonstone.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Ikon mata kuliah
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: ColorTokens.moonstone.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.book,
                      size: 20,
                      color: ColorTokens.moonstone,
                      semanticLabel: 'Sesi belajar'),
                ),
                const SizedBox(width: 12),
                // Detail sesi
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n('SessionCardTitle'),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: ColorTokens.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.access_time,
                              size: 14, color: ColorTokens.moonstone),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              // Satu baris 'jam • durasi' lalu membungkus,
                              // tidak melakukan pemotongan pada skala teks besar.
                              '${session.mulai.hour}:${session.mulai.minute.toString().padLeft(2, '0')}'
                              ' • ${durasi.inMinutes} ${l10n('MinuteUnit')}',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                color: ColorTokens.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Chip sumber
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: session.sumber == SessionSource.ai
                        ? ColorTokens.vanilla.withValues(alpha: 0.2)
                        : ColorTokens.moonstone.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    session.sumber == SessionSource.ai
                        ? l10n('SourceAI')
                        : l10n('SourceManual'),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: ColorTokens.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
