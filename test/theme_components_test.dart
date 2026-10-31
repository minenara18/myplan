import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_study_planner/theme/components/icon_only_button.dart';

void main() {
  testWidgets('IconOnlyButton target sentuh minimal 48px dan Semantics ada',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: IconOnlyButton(
            icon: Icons.home,
            label: 'Beranda',
            onPressed: () {},
          ),
        ),
      ),
    );

    // Cari IconOnlyButton
    final button = find.byType(IconOnlyButton);
    expect(button, findsOneWidget);

    // Verifikasi ukuran container minimal 48x48
    final renderBox = tester.getSize(button);
    expect(renderBox.width, greaterThanOrEqualTo(48));
    expect(renderBox.height, greaterThanOrEqualTo(48));

    // Verifikasi Semantics label ada
    expect(find.bySemanticsLabel('Beranda'), findsOneWidget);
  });

  testWidgets('IconOnlyButton memanggil onPressed saat ditekan',
      (WidgetTester tester) async {
    var pressed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: IconOnlyButton(
            icon: Icons.home,
            label: 'Beranda',
            onPressed: () => pressed = true,
          ),
        ),
      ),
    );

    await tester.tap(find.bySemanticsLabel('Beranda'));
    expect(pressed, isTrue);
  });
}