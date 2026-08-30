import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logic_lab/mini_apps/qibla/qibla_calculator.dart';
import 'package:logic_lab/mini_apps/qibla/qibla_page.dart';
import 'package:logic_lab/sections/mini_apps_section.dart';

void main() {
  group('QiblaCalculator', () {
    test('calculates the Qibla bearing from Jakarta', () {
      final bearing = QiblaCalculator.bearingFrom(-6.2088, 106.8456);

      expect(bearing, closeTo(295.15, 0.2));
      expect(QiblaCalculator.cardinalDirection(bearing), 'NW');
    });

    test('calculates relative direction from device heading', () {
      final direction = QiblaCalculator.relativeDirection(
        qiblaBearing: 295,
        heading: 280,
      );

      expect(direction, 15);
    });
  });

  testWidgets('QIBLA card opens and returns from the standalone mini app', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(useMaterial3: true),
        home: Builder(
          builder: (context) => Scaffold(
            body: SingleChildScrollView(
              child: MiniAppsSection(
                onOpenApp: (_) => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const QiblaPage()),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Traveling Apps'), findsOneWidget);
    expect(find.text('QIBLA App'), findsOneWidget);
    expect(find.text('Edu Fun'), findsOneWidget);
    expect(find.text('Number Adventure'), findsOneWidget);

    await tester.tap(find.text('QIBLA App'));
    await tester.pumpAndSettle();

    expect(find.byType(QiblaPage), findsOneWidget);
    expect(find.text('Use my location'), findsOneWidget);

    await tester.tap(find.byTooltip('Back to Mini Apps').first);
    await tester.pumpAndSettle();

    expect(find.text('Mini Apps'), findsOneWidget);
  });
}
