import 'dart:math';

import 'package:logic_lab/mini_apps/edu_fun/models/edu_fun_models.dart';

class QuestionFactory {
  const QuestionFactory._();

  static List<EduQuestion> generateSession(int age, {Random? random}) {
    final rng = random ?? Random();
    return [
      _count(age, rng, 1),
      _addition(age, rng, 2),
      _comparison(age, rng, 3),
      _subtraction(age, rng, 4),
      _missingNumber(age, rng, 5),
      _sequence(age, rng, 6),
      _addition(age, rng, 7, harder: true),
      _numberBond(age, rng, 8),
      _sequence(age, rng, 9, harder: true),
      _finalChallenge(age, rng),
    ];
  }

  static EduQuestion _count(int age, Random rng, int index) {
    final max = age == 5
        ? 7
        : age == 6
            ? 12
            : 16;
    final answer = 3 + rng.nextInt(max - 2);
    const objects = ['🍎', '⭐', '🐝', '🎈'];
    final object = objects[rng.nextInt(objects.length)];
    return EduQuestion(
      id: 'count-$index-$answer',
      prompt: 'How many can you count?',
      visual: List.filled(answer, object).join(' '),
      options: _options(answer, 0, max + 2, rng),
      correctAnswer: answer,
      skill: 'Number Sense',
    );
  }

  static EduQuestion _addition(
    int age,
    Random rng,
    int index, {
    bool harder = false,
  }) {
    final limit = age == 5
        ? 10
        : age == 6
            ? 20
            : harder
                ? 50
                : 30;
    final first = 1 + rng.nextInt(max(2, limit ~/ 2));
    final second = 1 + rng.nextInt(max(2, limit - first));
    final answer = first + second;
    return EduQuestion(
      id: 'add-$index-$first-$second',
      prompt: '$first + $second = ?',
      visual: harder ? '✨  Think carefully  ✨' : null,
      options: _options(answer, 0, limit + 4, rng),
      correctAnswer: answer,
      skill: 'Addition',
    );
  }

  static EduQuestion _subtraction(int age, Random rng, int index) {
    final limit = age == 5
        ? 10
        : age == 6
            ? 20
            : 45;
    final first = 4 + rng.nextInt(limit - 3);
    final second = rng.nextInt(first + 1);
    final answer = first - second;
    return EduQuestion(
      id: 'subtract-$index-$first-$second',
      prompt: '$first − $second = ?',
      options: _options(answer, 0, limit, rng),
      correctAnswer: answer,
      skill: 'Subtraction',
    );
  }

  static EduQuestion _comparison(int age, Random rng, int index) {
    final limit = age == 5
        ? 10
        : age == 6
            ? 20
            : 50;
    final values = <int>{};
    while (values.length < 3) {
      values.add(1 + rng.nextInt(limit));
    }
    final options = values.toList()..shuffle(rng);
    final answer = values.reduce(max);
    return EduQuestion(
      id: 'compare-$index-${values.join('-')}',
      prompt: 'Which number is the biggest?',
      visual: '🔍  Look closely',
      options: options,
      correctAnswer: answer,
      skill: 'Comparison',
    );
  }

  static EduQuestion _missingNumber(int age, Random rng, int index) {
    final limit = age == 5
        ? 10
        : age == 6
            ? 20
            : 40;
    final total = 5 + rng.nextInt(limit - 4);
    final first = 1 + rng.nextInt(total - 1);
    final answer = total - first;
    return EduQuestion(
      id: 'missing-$index-$total-$first',
      prompt: '$first + ? = $total',
      visual: '🧩  Find the missing piece',
      options: _options(answer, 0, limit, rng),
      correctAnswer: answer,
      skill: 'Missing Number',
    );
  }

  static EduQuestion _sequence(
    int age,
    Random rng,
    int index, {
    bool harder = false,
  }) {
    final step = age == 5
        ? 1 + rng.nextInt(2)
        : age == 6
            ? 2 + rng.nextInt(3)
            : 3 + rng.nextInt(5);
    final start = age == 5 ? rng.nextInt(3) : 1 + rng.nextInt(harder ? 10 : 5);
    final values = List.generate(4, (i) => start + step * i);
    final answer = start + step * 4;
    return EduQuestion(
      id: 'sequence-$index-$start-$step',
      prompt: 'What number comes next?',
      visual: '${values.join('  →  ')}  →  ?',
      options: _options(answer, 0, answer + step * 3, rng),
      correctAnswer: answer,
      skill: 'Pattern',
    );
  }

  static EduQuestion _numberBond(int age, Random rng, int index) {
    final limit = age == 5
        ? 10
        : age == 6
            ? 20
            : 40;
    final leftA = 1 + rng.nextInt(max(2, limit ~/ 2));
    final leftB = 1 + rng.nextInt(max(2, limit ~/ 2));
    final rightA = 1 + rng.nextInt(leftA + leftB - 1);
    final answer = leftA + leftB - rightA;
    return EduQuestion(
      id: 'bond-$index-$leftA-$leftB-$rightA',
      prompt: '$leftA + $leftB = $rightA + ?',
      visual: '⚖️  Make both sides equal',
      options: _options(answer, 0, limit, rng),
      correctAnswer: answer,
      skill: 'Arithmetic Logic',
    );
  }

  static EduQuestion _finalChallenge(int age, Random rng) {
    if (age == 5) {
      final first = 3 + rng.nextInt(4);
      final second = 1 + rng.nextInt(3);
      final answer = first + second;
      return EduQuestion(
        id: 'final-5-$first-$second',
        prompt: '$first + $second = ?',
        visual: '🏆  FINAL CHALLENGE  🏆',
        options: _options(answer, 0, 10, rng),
        correctAnswer: answer,
        skill: 'Addition',
        isFinal: true,
      );
    }

    final first = age == 6 ? 8 + rng.nextInt(8) : 15 + rng.nextInt(25);
    final add = 2 + rng.nextInt(age == 6 ? 5 : 10);
    final subtract = 1 + rng.nextInt(add);
    final answer = first + add - subtract;
    return EduQuestion(
      id: 'final-$age-$first-$add-$subtract',
      prompt: '$first + $add − $subtract = ?',
      visual: '🏆  FINAL CHALLENGE  🏆',
      options: _options(answer, 0, answer + 8, rng),
      correctAnswer: answer,
      skill: 'Arithmetic Logic',
      isFinal: true,
    );
  }

  static List<int> _options(
    int correct,
    int minimum,
    int maximum,
    Random rng,
  ) {
    final values = <int>{correct};
    final spread = max(3, min(8, maximum - minimum));
    while (values.length < 3) {
      final delta = 1 + rng.nextInt(spread);
      final candidate = rng.nextBool() ? correct + delta : correct - delta;
      if (candidate >= minimum && candidate <= maximum) values.add(candidate);
    }
    return values.toList()..shuffle(rng);
  }
}
