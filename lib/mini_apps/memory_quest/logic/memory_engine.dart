import 'dart:math';

import 'package:logic_lab/mini_apps/memory_quest/models/memory_models.dart';

abstract final class MemoryBoardFactory {
  static const _themes = <String, List<String>>{
    'Animals': [
      '🐱',
      '🐶',
      '🐴',
      '🐯',
      '🐸',
      '🐼',
      '🦊',
      '🦁',
      '🐻',
      '🐨',
      '🐵',
      '🐰',
      '🦄',
      '🐙',
      '🦋',
      '🐞',
      '🦖',
      '🐧',
    ],
    'Fruits': [
      '🍎',
      '🍌',
      '🍉',
      '🍇',
      '🍓',
      '🍊',
      '🥝',
      '🍒',
      '🍍',
      '🥭',
      '🍑',
      '🍐',
      '🍋',
      '🫐',
      '🥥',
      '🍈',
      '🍅',
      '🥑',
    ],
    'Vehicles': [
      '🚗',
      '🚲',
      '🚀',
      '🚁',
      '🚂',
      '🚤',
      '🛴',
      '🚕',
      '🚌',
      '🚜',
      '🏎️',
      '🚒',
      '🛸',
      '🛶',
      '⛵',
      '🚚',
      '🏍️',
      '🛻',
    ],
    'Space': [
      '🌍',
      '🌙',
      '⭐',
      '☀️',
      '🪐',
      '☄️',
      '🚀',
      '👨‍🚀',
      '🛸',
      '🌌',
      '🔭',
      '🛰️',
      '🌑',
      '🌕',
      '🌟',
      '💫',
      '✨',
      '👽',
    ],
    'Adventure': [
      '⚽',
      '🎸',
      '🎁',
      '⌚',
      '📷',
      '✏️',
      '🎨',
      '🧩',
      '🎯',
      '🏆',
      '🎈',
      '🎲',
      '🪁',
      '🎹',
      '🥁',
      '🎮',
      '📚',
      '💡',
    ],
  };

  static MemoryStageConfig configFor(int stage) {
    final (columns, rows) = switch (stage) {
      1 => (4, 3),
      2 => (4, 4),
      3 => (5, 4),
      4 => (6, 4),
      5 => (6, 5),
      _ => (6, 6),
    };
    final themeNames = _themes.keys.toList();
    final modifier = switch (stage) {
      <= 2 => 'Easy',
      <= 4 => 'Normal',
      <= 6 => 'Hard',
      <= 9 => 'Similar Images',
      10 => 'Shuffle',
      _ => stage % 3 == 0 ? 'Shuffle' : 'Memory Master',
    };
    return MemoryStageConfig(
      stage: stage,
      columns: columns,
      rows: rows,
      baseTimeBonusSeconds: switch (stage) {
        1 => 15,
        2 => 14,
        3 => 13,
        4 => 12,
        5 => 11,
        6 => 10,
        _ => 8,
      },
      theme: themeNames[(stage - 1) % themeNames.length],
      modifier: modifier,
    );
  }

  static List<MemoryCardData> build({
    required MemoryStageConfig config,
    Random? random,
  }) {
    final rng = random ?? Random();
    final source = _themes[config.theme]!;
    final symbols = source.take(config.pairCount).toList();
    final paired = [...symbols, ...symbols]..shuffle(rng);
    return [
      for (var index = 0; index < paired.length; index++)
        MemoryCardData(id: index, symbol: paired[index]),
    ];
  }

  static List<MemoryCardData> duelBoard({
    bool tiebreaker = false,
    Random? random,
  }) {
    final config = MemoryStageConfig(
      stage: 1,
      columns: tiebreaker ? 3 : 4,
      rows: tiebreaker ? 2 : 4,
      baseTimeBonusSeconds: 0,
      theme: 'Animals',
      modifier: tiebreaker ? 'Tiebreaker' : 'Quick Duel',
    );
    return build(config: config, random: random);
  }
}

class MemoryScoring {
  static int pairScore({
    required int stage,
    required int combo,
    required int revealGapMs,
    required int pairs,
    required int moves,
  }) {
    final stageMultiplier = min(3.4, 1 + (stage - 1) * 0.16);
    final comboMultiplier = switch (combo) {
      <= 1 => 1.0,
      2 => 1.15,
      3 => 1.30,
      4 => 1.50,
      5 => 1.75,
      _ => 2.0,
    };
    final speedBonus = max(0, 120 - revealGapMs ~/ 14);
    final efficiencyBonus = moves == 0 ? 0 : (pairs / moves * 90).round();
    return (100 * stageMultiplier * comboMultiplier).round() +
        speedBonus +
        efficiencyBonus;
  }

  static int stageClearScore({
    required int stage,
    required int remainingTimeMs,
    required int pairs,
    required int moves,
    required int completionMs,
    required bool perfect,
  }) {
    final accuracy = moves == 0 ? 0.0 : pairs / moves;
    final timeComponent = remainingTimeMs ~/ max(8, 26 - stage);
    final efficiency = (accuracy * 850 * (1 + stage * 0.08)).round();
    final precision = 999 - completionMs % 1000;
    final perfectBonus = perfect ? 500 + stage * 75 : 0;
    return timeComponent + efficiency + precision + perfectBonus;
  }

  static int timeBonusMs({
    required MemoryStageConfig config,
    required int pairs,
    required int moves,
  }) {
    final perfect = moves == pairs;
    final accuracy = moves == 0 ? 0.0 : pairs / moves;
    final performanceSeconds = perfect ? 5 : (accuracy >= 0.8 ? 2 : 0);
    return (config.baseTimeBonusSeconds + performanceSeconds) * 1000;
  }
}
