import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:logic_lab/mini_apps/memory_quest/data/memory_leaderboard_api.dart';
import 'package:logic_lab/mini_apps/memory_quest/logic/memory_engine.dart';
import 'package:logic_lab/mini_apps/memory_quest/models/memory_models.dart';
import 'package:logic_lab/mini_apps/memory_quest/screens/memory_setup_screens.dart';
import 'package:logic_lab/mini_apps/memory_quest/screens/memory_solo_game_screen.dart';

void main() {
  group('Memory Quest engine', () {
    test('progresses from 4x3 to a capped 6x6 board', () {
      expect(MemoryBoardFactory.configFor(1).pairCount, 6);
      expect(MemoryBoardFactory.configFor(2).pairCount, 8);
      expect(MemoryBoardFactory.configFor(3).pairCount, 10);
      expect(MemoryBoardFactory.configFor(5).pairCount, 15);
      expect(MemoryBoardFactory.configFor(6).pairCount, 18);
      expect(MemoryBoardFactory.configFor(20).pairCount, 18);
      expect(MemoryBoardFactory.configFor(10).modifier, 'Shuffle');
    });

    test('creates exactly two cards for every symbol', () {
      final config = MemoryBoardFactory.configFor(4);
      final cards = MemoryBoardFactory.build(
        config: config,
        random: Random(42),
      );
      final counts = <String, int>{};
      for (final card in cards) {
        counts.update(card.symbol, (value) => value + 1, ifAbsent: () => 1);
      }

      expect(cards, hasLength(24));
      expect(counts, hasLength(12));
      expect(counts.values, everyElement(2));
    });

    test('rewards stage, combo, speed, efficiency, and perfect memory', () {
      final baseline = MemoryScoring.pairScore(
        stage: 1,
        combo: 1,
        revealGapMs: 2000,
        pairs: 1,
        moves: 2,
      );
      final skilled = MemoryScoring.pairScore(
        stage: 6,
        combo: 5,
        revealGapMs: 250,
        pairs: 6,
        moves: 6,
      );
      final normalClear = MemoryScoring.stageClearScore(
        stage: 2,
        remainingTimeMs: 30000,
        pairs: 8,
        moves: 12,
        completionMs: 18427,
        perfect: false,
      );
      final perfectClear = MemoryScoring.stageClearScore(
        stage: 2,
        remainingTimeMs: 30000,
        pairs: 8,
        moves: 8,
        completionMs: 18427,
        perfect: true,
      );

      expect(skilled, greaterThan(baseline));
      expect(perfectClear, greaterThan(normalClear));
    });
  });

  test('Memory leaderboard submission contains no location or token', () async {
    late Map<String, dynamic> submitted;
    final client = MockClient((request) async {
      submitted = jsonDecode(request.body) as Map<String, dynamic>;
      expect(request.url.path, '/api/v1/memory/scores');
      return http.Response('{"accepted":true}', 202);
    });
    final api = MemoryLeaderboardApi(
      baseUrl: 'https://leaderboard.example.test',
      client: client,
    );
    final session = MemorySession(
      sessionId: 'memory-session-000001',
      player: const MemoryPlayer(nickname: 'Naya'),
      score: 48729,
      stageReached: 8,
      pairsFound: 68,
      moves: 81,
      bestCombo: 7,
      remainingTimeMs: 0,
      fastestStageMs: 18427,
      durationMs: 342000,
      startedAt: DateTime.utc(2026, 9, 4, 13),
      completedAt: DateTime.utc(2026, 9, 4, 13, 5, 42),
    );

    await api.submit(session);

    expect(submitted['nickname'], 'Naya');
    expect(submitted.containsKey('location'), isFalse);
    expect(
      submitted.keys.any((key) => key.toLowerCase().contains('token')),
      isFalse,
    );
  });

  test('Memory leaderboard response maps ranking details', () async {
    final client = MockClient((_) async => http.Response(
          jsonEncode({
            'period': 'all',
            'entries': [
              {
                'rank': 1,
                'nickname': 'Naya',
                'score': 98742,
                'stageReached': 11,
                'pairsFound': 102,
                'accuracyPermille': 840,
                'remainingTimeMs': 0,
                'fastestStageMs': 15420,
                'completedAt': '2026-09-04T10:00:00.000Z',
              },
            ],
          }),
          200,
        ));
    final api = MemoryLeaderboardApi(
      baseUrl: 'https://leaderboard.example.test',
      client: client,
    );

    final entries = await api.fetch(period: MemoryLeaderboardPeriod.allTime);

    expect(entries, hasLength(1));
    expect(entries.first.stageReached, 11);
    expect(entries.first.score, 98742);
  });

  testWidgets('Solo setup is usable on a small phone', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    MemoryPlayer? player;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(useMaterial3: true),
        home: Scaffold(
          body: MemorySoloSetupScreen(
            onStart: (value) => player = value,
            onBack: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Bima');
    await tester.ensureVisible(find.text('START GAME'));
    await tester.tap(find.text('START GAME'));

    expect(player?.nickname, 'Bima');
    expect(tester.takeException(), isNull);
  });

  testWidgets('Solo game ends when its precise countdown reaches zero',
      (tester) async {
    var nowMs = 1000;
    MemorySession? completed;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(useMaterial3: true),
        home: MemorySoloGameScreen(
          player: const MemoryPlayer(nickname: 'Naya'),
          initialTimeMs: 200,
          random: Random(7),
          nowMs: () => nowMs,
          onComplete: (session) => completed = session,
        ),
      ),
    );

    nowMs = 1250;
    await tester.pump(const Duration(milliseconds: 50));

    expect(completed, isNotNull);
    expect(completed!.remainingTimeMs, 0);
    expect(completed!.durationMs, 1000);
    expect(find.text("TIME'S UP!"), findsOneWidget);
  });
}
