import 'dart:math';

import 'package:logic_lab/mini_apps/edu_fun/models/edu_fun_models.dart';

class GameEngine {
  int score = 0;
  int correct = 0;
  int streak = 0;
  int bestStreak = 0;

  AnswerOutcome answer(
    EduQuestion question,
    int selected,
    Duration responseTime,
  ) {
    final isCorrect = selected == question.correctAnswer;
    if (!isCorrect) {
      streak = 0;
      return const AnswerOutcome(
        isCorrect: false,
        points: 0,
        speedBonus: 0,
        streakBonus: 0,
        streak: 0,
      );
    }

    correct++;
    streak++;
    bestStreak = max(bestStreak, streak);

    final speedBonus = max(0, 50 - responseTime.inSeconds * 3);
    final streakBonus = switch (streak) {
      3 => 30,
      5 => 50,
      8 => 100,
      _ => 0,
    };
    final finalBonus = question.isFinal ? 100 : 0;
    final points = 100 + speedBonus + streakBonus + finalBonus;
    score += points;

    return AnswerOutcome(
      isCorrect: true,
      points: points,
      speedBonus: speedBonus,
      streakBonus: streakBonus,
      streak: streak,
    );
  }
}
