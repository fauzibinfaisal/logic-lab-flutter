import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:logic_lab/mini_apps/edu_fun/data/leaderboard_api_service.dart';
import 'package:logic_lab/mini_apps/edu_fun/data/leaderboard_repository.dart';
import 'package:logic_lab/mini_apps/edu_fun/logic/game_engine.dart';
import 'package:logic_lab/mini_apps/edu_fun/logic/question_factory.dart';
import 'package:logic_lab/mini_apps/edu_fun/models/edu_fun_models.dart';
import 'package:logic_lab/mini_apps/edu_fun/screens/leaderboard_screen.dart';
import 'package:logic_lab/mini_apps/edu_fun/screens/profile_screen.dart';
import 'package:logic_lab/mini_apps/edu_fun/screens/welcome_screen.dart';

void main() {
  group('Number Adventure game logic', () {
    for (final age in [5, 6, 7]) {
      test('builds a balanced 10-question session for age $age', () {
        final questions = QuestionFactory.generateSession(
          age,
          random: Random(100 + age),
        );

        expect(questions, hasLength(10));
        expect(questions.last.isFinal, isTrue);
        expect(questions.map((question) => question.skill).toSet().length,
            greaterThanOrEqualTo(5));
        for (final question in questions) {
          expect(question.options, hasLength(3));
          expect(question.options.toSet(), hasLength(3));
          expect(question.options, contains(question.correctAnswer));
        }
      });
    }

    test('awards points without removing points for an incorrect answer', () {
      final question = QuestionFactory.generateSession(
        6,
        random: Random(42),
      ).first;
      final engine = GameEngine();

      final correct = engine.answer(
        question,
        question.correctAnswer,
        const Duration(seconds: 2),
      );
      final incorrect = engine.answer(
        question,
        question.options.firstWhere((value) => value != question.correctAnswer),
        const Duration(seconds: 2),
      );

      expect(correct.isCorrect, isTrue);
      expect(correct.points, greaterThanOrEqualTo(100));
      expect(incorrect.points, 0);
      expect(engine.score, correct.points);
    });
  });

  test('leaderboard submission sends no location or secret fields', () async {
    late Map<String, dynamic> submitted;
    final client = MockClient((request) async {
      submitted = jsonDecode(request.body) as Map<String, dynamic>;
      return http.Response('{"accepted":true}', 202);
    });
    final service = LeaderboardApiService(
      baseUrl: 'https://leaderboard.example.test',
      client: client,
    );
    final session = EduSession(
      sessionId: 'session-test-000001',
      player: const EduPlayer(
        nickname: 'Bima',
        age: 6,
        location: 'Jakarta, Indonesia',
      ),
      score: 1240,
      correct: 8,
      bestStreak: 5,
      durationSeconds: 258,
      completedAt: DateTime.utc(2026, 8, 30),
    );

    await service.submit(session);

    expect(submitted['nickname'], 'Bima');
    expect(submitted.containsKey('location'), isFalse);
    expect(submitted.keys.any((key) => key.toLowerCase().contains('token')),
        isFalse);
  });

  test('leaderboard response maps ranked entries', () async {
    final client = MockClient((_) async => http.Response(
          jsonEncode({
            'age': 6,
            'period': 'today',
            'entries': [
              {
                'rank': 1,
                'nickname': 'Naya',
                'age': 6,
                'score': 1520,
                'completionTimeMs': 210000,
                'correctAnswers': 10,
                'bestStreak': 7,
                'completedAt': '2026-08-30T10:00:00.000Z',
              },
            ],
          }),
          200,
        ));
    final service = LeaderboardApiService(
      baseUrl: 'https://leaderboard.example.test',
      client: client,
    );

    final entries = await service.fetch(
      age: 6,
      period: LeaderboardPeriod.today,
    );

    expect(entries, hasLength(1));
    expect(entries.first.rank, 1);
    expect(entries.first.nickname, 'Naya');
  });

  testWidgets('leaderboard opens All Time so older scores stay visible', (
    tester,
  ) async {
    late Uri requestedUri;
    final client = MockClient((request) async {
      requestedUri = request.url;
      return http.Response(
        jsonEncode({
          'age': 5,
          'period': 'all',
          'entries': [
            {
              'rank': 1,
              'nickname': 'Fauzi',
              'age': 5,
              'score': 1639,
              'completionTimeMs': 63000,
              'correctAnswers': 10,
              'bestStreak': 10,
              'completedAt': '2026-08-31T13:30:15.968Z',
            },
          ],
        }),
        200,
      );
    });
    final repository = LeaderboardRepository(
      api: LeaderboardApiService(
        baseUrl: 'https://leaderboard.example.test',
        client: client,
      ),
    );
    addTearDown(repository.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(useMaterial3: true),
        home: Scaffold(
          body: EduLeaderboardScreen(
            repository: repository,
            initialAge: 5,
            onBack: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(requestedUri.queryParameters['period'], 'all');
    expect(find.text('ALL-TIME CHAMPIONS'), findsOneWidget);
    expect(find.text('Fauzi'), findsOneWidget);
    expect(find.text('⭐ 1639'), findsOneWidget);
  });

  testWidgets('welcome and player setup stay usable on a small phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var started = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(useMaterial3: true),
        home: Scaffold(
          body: EduWelcomeScreen(
            onPlay: () => started = true,
            onLeaderboard: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('START PLAYING'));
    await tester.tap(find.text('START PLAYING'));
    expect(started, isTrue);

    EduPlayer? player;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(useMaterial3: true),
        home: Scaffold(
          body: EduProfileScreen(onContinue: (value) => player = value),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Bima');
    await tester.tap(find.text('6'));
    await tester.ensureVisible(find.text("LET'S PLAY"));
    await tester.tap(find.text("LET'S PLAY"));

    expect(player?.nickname, 'Bima');
    expect(player?.age, 6);
  });
}
