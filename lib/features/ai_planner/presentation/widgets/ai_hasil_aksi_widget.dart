import 'package:flutter/material.dart';

import 'package:ai_study_planner/theme/color_tokens.dart';

/// Baris aksi hasil: tombol ikon sparkle "Generate Ulang"
/// dan tombol utama "Terapkan ke Kalender".
class AiHasilAksiWidget extends StatelessWidget {
  const AiHasilAksiWidget({
    super.key,
    required this.padaTerapkan,
    required this.padaUlang,
    this.menyimpan = false,
  });

  final VoidCallback padaTerapkan;
  final VoidCallback padaUlang;
  final bool menyimpan;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Semantics(
          label: 'Generate ulang rencana',
          button: true,
          child: InkWell(
            onTap: menyimpan ? null : padaUlang,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: ColorTokens.vanilla, width: 2),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: ColorTokens.textPrimary,
                size: 22,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Semantics(
            label: 'Terapkan rencana ke kalender',
            button: true,
            child: SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: menyimpan ? null : padaTerapkan,
                style: FilledButton.styleFrom(
                  backgroundColor: ColorTokens.moonstone,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: menyimpan
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: ColorTokens.textPrimary,
                        ),
                      )
                    : const Text(
                        'Terapkan ke Kalender',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ColorTokens.textPrimary,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
