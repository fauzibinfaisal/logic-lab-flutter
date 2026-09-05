class MemoryPlayer {
  final String nickname;

  const MemoryPlayer({required this.nickname});

  Map<String, Object> toJson() => {'nickname': nickname};

  factory MemoryPlayer.fromJson(Map<String, dynamic> json) =>
      MemoryPlayer(nickname: json['nickname'] as String);
}

class MemoryStageConfig {
  final int stage;
  final int columns;
  final int rows;
  final int baseTimeBonusSeconds;
  final String theme;
  final String modifier;

  const MemoryStageConfig({
    required this.stage,
    required this.columns,
    required this.rows,
    required this.baseTimeBonusSeconds,
    required this.theme,
    required this.modifier,
  });

  int get pairCount => columns * rows ~/ 2;
}

class MemoryCardData {
  final int id;
  final String symbol;
  final bool isRevealed;
  final bool isMatched;

  const MemoryCardData({
    required this.id,
    required this.symbol,
    this.isRevealed = false,
    this.isMatched = false,
  });

  MemoryCardData copyWith({bool? isRevealed, bool? isMatched}) =>
      MemoryCardData(
        id: id,
        symbol: symbol,
        isRevealed: isRevealed ?? this.isRevealed,
        isMatched: isMatched ?? this.isMatched,
      );
}

class MemorySession {
  final String sessionId;
  final MemoryPlayer player;
  final int score;
  final int stageReached;
  final int pairsFound;
  final int moves;
  final int bestCombo;
  final int remainingTimeMs;
  final int fastestStageMs;
  final int durationMs;
  final DateTime startedAt;
  final DateTime completedAt;

  const MemorySession({
    required this.sessionId,
    required this.player,
    required this.score,
    required this.stageReached,
    required this.pairsFound,
    required this.moves,
    required this.bestCombo,
    required this.remainingTimeMs,
    required this.fastestStageMs,
    required this.durationMs,
    required this.startedAt,
    required this.completedAt,
  });

  double get accuracy => moves == 0 ? 0 : pairsFound / moves;

  factory MemorySession.completed({
    required MemoryPlayer player,
    required int score,
    required int stageReached,
    required int pairsFound,
    required int moves,
    required int bestCombo,
    required int remainingTimeMs,
    required int fastestStageMs,
    required int durationMs,
    required DateTime startedAt,
  }) {
    final completedAt = DateTime.now();
    return MemorySession(
      sessionId:
          '${completedAt.microsecondsSinceEpoch}-${player.nickname.hashCode.abs()}-$score',
      player: player,
      score: score,
      stageReached: stageReached,
      pairsFound: pairsFound,
      moves: moves,
      bestCombo: bestCombo,
      remainingTimeMs: remainingTimeMs,
      fastestStageMs: fastestStageMs,
      durationMs: durationMs,
      startedAt: startedAt,
      completedAt: completedAt,
    );
  }

  Map<String, Object> toJson() => {
        'sessionId': sessionId,
        'player': player.toJson(),
        'score': score,
        'stageReached': stageReached,
        'pairsFound': pairsFound,
        'moves': moves,
        'bestCombo': bestCombo,
        'remainingTimeMs': remainingTimeMs,
        'fastestStageMs': fastestStageMs,
        'durationMs': durationMs,
        'startedAt': startedAt.toIso8601String(),
        'completedAt': completedAt.toIso8601String(),
      };

  factory MemorySession.fromJson(Map<String, dynamic> json) => MemorySession(
        sessionId: json['sessionId'] as String,
        player: MemoryPlayer.fromJson(json['player'] as Map<String, dynamic>),
        score: json['score'] as int,
        stageReached: json['stageReached'] as int,
        pairsFound: json['pairsFound'] as int,
        moves: json['moves'] as int,
        bestCombo: json['bestCombo'] as int,
        remainingTimeMs: json['remainingTimeMs'] as int,
        fastestStageMs: json['fastestStageMs'] as int? ?? 0,
        durationMs: json['durationMs'] as int,
        startedAt: DateTime.parse(json['startedAt'] as String),
        completedAt: DateTime.parse(json['completedAt'] as String),
      );
}

class MemoryPlayerStats {
  final int gamesPlayed;
  final int bestScore;
  final int highestStage;
  final int totalPairs;
  final int bestCombo;
  final double bestAccuracy;

  const MemoryPlayerStats({
    required this.gamesPlayed,
    required this.bestScore,
    required this.highestStage,
    required this.totalPairs,
    required this.bestCombo,
    required this.bestAccuracy,
  });

  static const empty = MemoryPlayerStats(
    gamesPlayed: 0,
    bestScore: 0,
    highestStage: 0,
    totalPairs: 0,
    bestCombo: 0,
    bestAccuracy: 0,
  );
}

enum MemoryLeaderboardPeriod { today, week, allTime }

enum MemorySubmissionState { loading, success, error }

class MemoryLeaderboardEntry {
  final int rank;
  final String nickname;
  final int score;
  final int stageReached;
  final int pairsFound;
  final int accuracyPermille;
  final int remainingTimeMs;
  final int fastestStageMs;
  final DateTime completedAt;

  const MemoryLeaderboardEntry({
    required this.rank,
    required this.nickname,
    required this.score,
    required this.stageReached,
    required this.pairsFound,
    required this.accuracyPermille,
    required this.remainingTimeMs,
    required this.fastestStageMs,
    required this.completedAt,
  });

  factory MemoryLeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      MemoryLeaderboardEntry(
        rank: json['rank'] as int,
        nickname: json['nickname'] as String,
        score: json['score'] as int,
        stageReached: json['stageReached'] as int,
        pairsFound: json['pairsFound'] as int,
        accuracyPermille: json['accuracyPermille'] as int,
        remainingTimeMs: json['remainingTimeMs'] as int,
        fastestStageMs: json['fastestStageMs'] as int,
        completedAt: DateTime.parse(json['completedAt'] as String),
      );
}

class DuelResult {
  final String playerOne;
  final String playerTwo;
  final int playerOnePairs;
  final int playerTwoPairs;
  final int playerOneBestStreak;
  final int playerTwoBestStreak;
  final int playerOneFastestMatchMs;
  final int playerTwoFastestMatchMs;
  final String winner;
  final bool usedTiebreaker;

  const DuelResult({
    required this.playerOne,
    required this.playerTwo,
    required this.playerOnePairs,
    required this.playerTwoPairs,
    required this.playerOneBestStreak,
    required this.playerTwoBestStreak,
    required this.playerOneFastestMatchMs,
    required this.playerTwoFastestMatchMs,
    required this.winner,
    required this.usedTiebreaker,
  });
}
