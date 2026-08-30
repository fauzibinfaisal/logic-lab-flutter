class EduPlayer {
  final String nickname;
  final int age;
  final String location;

  const EduPlayer({
    required this.nickname,
    required this.age,
    this.location = 'Unknown',
  });

  Map<String, Object> toJson() => {
        'nickname': nickname,
        'age': age,
        'location': location,
      };

  factory EduPlayer.fromJson(Map<String, dynamic> json) => EduPlayer(
        nickname: json['nickname'] as String,
        age: json['age'] as int,
        location: json['location'] as String? ?? 'Unknown',
      );
}

class EduQuestion {
  final String id;
  final String prompt;
  final String? visual;
  final List<int> options;
  final int correctAnswer;
  final String skill;
  final bool isFinal;

  const EduQuestion({
    required this.id,
    required this.prompt,
    required this.options,
    required this.correctAnswer,
    required this.skill,
    this.visual,
    this.isFinal = false,
  });
}

class AnswerOutcome {
  final bool isCorrect;
  final int points;
  final int speedBonus;
  final int streakBonus;
  final int streak;

  const AnswerOutcome({
    required this.isCorrect,
    required this.points,
    required this.speedBonus,
    required this.streakBonus,
    required this.streak,
  });
}

class EduSession {
  final String sessionId;
  final EduPlayer player;
  final int score;
  final int correct;
  final int bestStreak;
  final int durationSeconds;
  final DateTime completedAt;

  const EduSession({
    required this.sessionId,
    required this.player,
    required this.score,
    required this.correct,
    required this.bestStreak,
    required this.durationSeconds,
    required this.completedAt,
  });

  double get accuracy => correct / 10;

  factory EduSession.completed({
    required EduPlayer player,
    required int score,
    required int correct,
    required int bestStreak,
    required int durationSeconds,
  }) {
    final completedAt = DateTime.now();
    final sessionId =
        '${completedAt.microsecondsSinceEpoch}-${player.nickname.hashCode.abs()}-$score';
    return EduSession(
      sessionId: sessionId,
      player: player,
      score: score,
      correct: correct,
      bestStreak: bestStreak,
      durationSeconds: durationSeconds,
      completedAt: completedAt,
    );
  }

  Map<String, Object> toJson() => {
        'sessionId': sessionId,
        'player': player.toJson(),
        'score': score,
        'correct': correct,
        'bestStreak': bestStreak,
        'durationSeconds': durationSeconds,
        'completedAt': completedAt.toIso8601String(),
      };

  factory EduSession.fromJson(Map<String, dynamic> json) => EduSession(
        sessionId: json['sessionId'] as String? ??
            '${json['completedAt']}-${json['score']}-${json['correct']}',
        player: EduPlayer.fromJson(json['player'] as Map<String, dynamic>),
        score: json['score'] as int,
        correct: json['correct'] as int,
        bestStreak: json['bestStreak'] as int,
        durationSeconds: json['durationSeconds'] as int,
        completedAt: DateTime.parse(json['completedAt'] as String),
      );
}

class PlayerStats {
  final int gamesPlayed;
  final int bestScore;
  final double bestAccuracy;
  final int bestStreak;

  const PlayerStats({
    required this.gamesPlayed,
    required this.bestScore,
    required this.bestAccuracy,
    required this.bestStreak,
  });

  static const empty = PlayerStats(
    gamesPlayed: 0,
    bestScore: 0,
    bestAccuracy: 0,
    bestStreak: 0,
  );
}

enum LeaderboardPeriod { today, week, allTime }

enum ScoreSubmissionState { loading, success, error }

class LeaderboardEntry {
  final int rank;
  final String nickname;
  final int age;
  final int score;
  final int completionTimeMs;
  final int correctAnswers;
  final int bestStreak;
  final DateTime completedAt;

  const LeaderboardEntry({
    required this.rank,
    required this.nickname,
    required this.age,
    required this.score,
    required this.completionTimeMs,
    required this.correctAnswers,
    required this.bestStreak,
    required this.completedAt,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      LeaderboardEntry(
        rank: json['rank'] as int,
        nickname: json['nickname'] as String,
        age: json['age'] as int,
        score: json['score'] as int,
        completionTimeMs: json['completionTimeMs'] as int,
        correctAnswers: json['correctAnswers'] as int,
        bestStreak: json['bestStreak'] as int,
        completedAt: DateTime.parse(json['completedAt'] as String),
      );
}
