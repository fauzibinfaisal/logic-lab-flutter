import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logic_lab/main.dart';
import 'package:logic_lab/number_page.dart';
import 'package:logic_lab/sections/mini_apps_section.dart';
import 'package:logic_lab/sections/projects_section.dart';

void main() {
  group('Number Reversal Logic Tests', () {
    test('computes reverse difference correctly for 21', () {
      final result = computeReverseDifference(21);
      expect(result.reversed, 12);
      expect(result.difference, 9);
    });

    test('computes reverse difference correctly for 30', () {
      final result = computeReverseDifference(30);
      expect(result.reversed, 3);
      expect(result.difference, 27);
    });

    test('returns 0 difference for palindrome 121', () {
      final result = computeReverseDifference(121);
      expect(result.reversed, 121);
      expect(result.difference, 0);
    });
  });

  testWidgets('portfolio navigation scrolls to the selected section', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PortfolioApp());
    await tester.pump(const Duration(seconds: 2));

    final scrollable = find.byType(Scrollable).first;
    await tester.drag(scrollable, const Offset(0, -400));
    await tester.pumpAndSettle();

    const sectionLabels = [
      'About',
      'Experience',
      'Skills',
      'Achievements',
      'Education',
      'Projects',
      'Mini Apps',
    ];
    for (final label in sectionLabels) {
      expect(find.widgetWithText(TextButton, label), findsOneWidget);
    }

    final scrollPosition = tester.state<ScrollableState>(scrollable).position;
    final offsetBeforeTap = scrollPosition.pixels;

    await tester.tap(find.widgetWithText(TextButton, 'Projects'));
    await tester.pumpAndSettle();

    expect(scrollPosition.pixels, greaterThan(offsetBeforeTap));
    final projectsTop = tester.getTopLeft(find.byType(ProjectsSection)).dy;
    expect(
      projectsTop,
      greaterThanOrEqualTo(64),
    );
    expect(projectsTop, lessThan(900));

    final projectsOffset = scrollPosition.pixels;
    await tester.tap(find.widgetWithText(TextButton, 'Mini Apps'));
    await tester.pumpAndSettle();

    expect(scrollPosition.pixels, greaterThan(projectsOffset));
    expect(tester.getTopLeft(find.byType(MiniAppsSection)).dy, lessThan(900));
  });
}
