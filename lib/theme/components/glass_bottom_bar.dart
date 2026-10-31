import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:ai_study_planner/theme/color_tokens.dart';

/// Navigasi bawah dengan 5 ikon tanpa teks. AI di tengah menonjol.
/// Ikon aktif berada di balutan Vanilla dengan titik kecil.
class GlassBottomBar extends StatelessWidget {
  const GlassBottomBar({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  static const List<IconData> _icons = [
    Icons.home,
    Icons.calendar_today,
    Icons.smart_toy, // AI
    Icons.bar_chart,
    Icons.person,
  ];

  static const List<String> _semanticsLabels = [
    'Beranda',
    'Kalender',
    'AI',
    'Grafik',
    'Profil',
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.6),
            border: Border(
              top: BorderSide(
                color: ColorTokens.moonstone.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_icons.length, (i) {
              final isActive = i == selectedIndex;
              final isCenter = i == 2; // AI di tengah
              return _BottomIcon(
                icon: _icons[i],
                label: _semanticsLabels[i],
                isActive: isActive,
                isCenter: isCenter,
                onTap: () => onChanged(i),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _BottomIcon extends StatelessWidget {
  const _BottomIcon({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.isCenter,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final bool isCenter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final activeColor = ColorTokens.vanilla;
    final inactiveColor = ColorTokens.moonstone.withValues(alpha: 0.5);

    Widget child = Icon(
      icon,
      color: isActive ? activeColor : inactiveColor,
      size: isCenter ? 30 : 24,
      semanticLabel: label,
    );

    if (isActive) {
      // Balutan Vanilla dengan titik kecil
      child = Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: activeColor,
              shape: BoxShape.circle,
            ),
          ),
          Icon(
            icon,
            color: ColorTokens.textPrimary,
            size: isCenter ? 24 : 20,
          ),
          if (isCenter)
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: ColorTokens.moonstone,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      );
    }

    return Semantics(
      label: label,
      button: true,
      selected: isActive,
      child: SizedBox(
        width: 64,
        height: 48,
        child: InkWell(
          onTap: onTap,
          child: Center(child: child),
        ),
      ),
    );
  }
}