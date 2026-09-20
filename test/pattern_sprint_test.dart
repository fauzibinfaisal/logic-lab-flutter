import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logic_lab/mini_apps/pattern_sprint/logic/pattern_engine.dart';
import 'package:logic_lab/mini_apps/pattern_sprint/pattern_sprint_page.dart';

void main() {
  group('PatternEngine', () {
    test('creates a complete session with valid unique choices', () {
      for (final age in PatternEngine.supportedAges) {
        final session = PatternEngine.createSession(age: age, seed: 7);

        expect(session, hasLength(10));
        expect(session.where((round) => round.answer.isNumber), hasLength(5));
        expect(
          session.where((round) => !round.answer.isNumber),
          hasLength(5),
        );
        for (final round in session) {
          expect(round.sequence, isNotEmpty);
          expect(round.options, hasLength(4));
          expect(round.options.toSet(), hasLength(4));
          expect(round.options, contains(round.answer));
        }
      }
    });

    test('rejects ages outside the 5–7 range', () {
      expect(
        () => PatternEngine.createSession(age: 4),
        throwsArgumentError,
      );
    });

    test('Time Boost adds harder rounds and rewards quick answers', () {
      for (final age in PatternEngine.supportedAges) {
        final session = PatternEngine.createSession(
          age: age,
          mode: PatternSprintMode.timeBoost,
          seed: 7,
        );

        expect(session, hasLength(12));
        expect(session.where((round) => round.answer.isNumber), hasLength(6));
        expect(
          session.where((round) => !round.answer.isNumber),
          hasLength(6),
        );
      }
      expect(PatternEngine.initialSeconds(PatternSprintMode.timeBoost), 30);
      expect(PatternEngine.timeBonusFor(const Duration(seconds: 3)), 5);
      expect(PatternEngine.timeBonusFor(const Duration(seconds: 6)), 3);
      expect(PatternEngine.timeBonusFor(const Duration(seconds: 8)), 0);
    });

    test('awards a capped streak and time bonus', () {
      expect(
        PatternEngine.pointsFor(streak: 1, secondsRemaining: 59),
        179,
      );
      expect(
        PatternEngine.pointsFor(streak: 99, secondsRemaining: 99),
        260,
      );
    });
  });

  testWidgets('Pattern Sprint selects age and mixes shape with number rounds', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(useMaterial3: true),
        home: const PatternSprintPage(visitCount: 61),
      ),
    );

    expect(find.text('Spot the pattern.\nBeat the clock.'), findsOneWidget);
    expect(find.text('61 visits'), findsOneWidget);
    expect(find.byKey(const Key('pattern-age-selector')), findsOneWidget);

    final startButton = find.byKey(const Key('pattern-start'));
    await tester.ensureVisible(startButton);
    await tester.pumpAndSettle();
    await tester.tap(startButton);
    await tester.pump();

    expect(find.text('What comes next?'), findsOneWidget);
    expect(find.text('1/10'), findsOneWidget);

    await tester.tap(
      find.byKey(const Key('pattern-option-shape-triangle')),
    );
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('2/10'), findsOneWidget);
    expect(find.byKey(const Key('pattern-option-number-6')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Time Boost adds time for a fast correct answer', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(useMaterial3: true),
        home: const PatternSprintPage(),
      ),
    );

    final boostMode = find.byKey(const Key('pattern-mode-timeBoost'));
    await tester.ensureVisible(boostMode);
    await tester.pumpAndSettle();
    await tester.tap(boostMode);
    await tester.pump();

    expect(find.text('12 rounds'), findsOneWidget);
    expect(find.text('Up to +5s'), findsOneWidget);

    final startButton = find.byKey(const Key('pattern-start'));
    await tester.ensureVisible(startButton);
    await tester.pumpAndSettle();
    await tester.tap(startButton);
    await tester.pump();

    expect(find.text('1/12'), findsOneWidget);
    expect(find.text('30s'), findsOneWidget);

    await tester.tap(find.byKey(const Key('pattern-option-shape-heart')));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('35s'), findsOneWidget);
    expect(find.textContaining('Fast! +5s'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('2/12'), findsOneWidget);
    expect(find.byKey(const Key('pattern-option-number-9')), findsOneWidget);
  });
}
