import 'dart:math';

enum PatternShape { circle, triangle, square, star, heart, diamond }

enum PatternSprintMode { classic, timeBoost }

class PatternToken {
  final PatternShape? shape;
  final int? number;

  const PatternToken.shape(PatternShape this.shape) : number = null;

  const PatternToken.number(int this.number) : shape = null;

  bool get isNumber => number != null;

  String get key => isNumber ? 'number-$number' : 'shape-${shape!.name}';

  @override
  bool operator ==(Object other) =>
      other is PatternToken && other.shape == shape && other.number == number;

  @override
  int get hashCode => Object.hash(shape, number);
}

class PatternRound {
  final List<PatternToken> sequence;
  final PatternToken answer;
  final List<PatternToken> options;
  final String rule;

  const PatternRound({
    required this.sequence,
    required this.answer,
    required this.options,
    required this.rule,
  });

  PatternRound shuffled(Random random) {
    final shuffledOptions = [...options]..shuffle(random);
    return PatternRound(
      sequence: sequence,
      answer: answer,
      options: shuffledOptions,
      rule: rule,
    );
  }
}

const _circle = PatternToken.shape(PatternShape.circle);
const _triangle = PatternToken.shape(PatternShape.triangle);
const _square = PatternToken.shape(PatternShape.square);
const _star = PatternToken.shape(PatternShape.star);
const _heart = PatternToken.shape(PatternShape.heart);
const _diamond = PatternToken.shape(PatternShape.diamond);

PatternToken _number(int value) => PatternToken.number(value);

abstract final class PatternEngine {
  static const totalSeconds = 60;
  static const timeBoostSeconds = 30;
  static const startingLives = 3;
  static const supportedAges = [5, 6, 7];

  static const _shapeRounds = [
    PatternRound(
      sequence: [_circle, _triangle, _circle, _triangle, _circle],
      answer: _triangle,
      options: [_circle, _triangle, _square, _star],
      rule: 'Two shapes take turns.',
    ),
    PatternRound(
      sequence: [_star, _star, _heart, _star, _star],
      answer: _heart,
      options: [_heart, _star, _circle, _diamond],
      rule: 'Two stars, then one heart.',
    ),
    PatternRound(
      sequence: [_circle, _triangle, _square, _circle, _triangle],
      answer: _square,
      options: [_square, _triangle, _diamond, _heart],
      rule: 'Three shapes repeat in order.',
    ),
    PatternRound(
      sequence: [_diamond, _heart, _heart, _diamond, _heart],
      answer: _heart,
      options: [_heart, _diamond, _star, _square],
      rule: 'One diamond, then two hearts.',
    ),
    PatternRound(
      sequence: [_triangle, _triangle, _square, _square, _triangle, _triangle],
      answer: _square,
      options: [_square, _triangle, _circle, _star],
      rule: 'Pairs alternate: two triangles, two squares.',
    ),
    PatternRound(
      sequence: [_circle, _circle, _triangle, _square, _circle, _circle],
      answer: _triangle,
      options: [_triangle, _square, _circle, _diamond],
      rule: 'A four-shape group repeats.',
    ),
    PatternRound(
      sequence: [_star, _heart, _diamond, _diamond, _star, _heart, _diamond],
      answer: _diamond,
      options: [_diamond, _heart, _star, _triangle],
      rule: 'The last shape in each group appears twice.',
    ),
    PatternRound(
      sequence: [_square, _circle, _circle, _triangle, _square, _circle],
      answer: _circle,
      options: [_circle, _triangle, _square, _heart],
      rule: 'One square, two circles, one triangle.',
    ),
    PatternRound(
      sequence: [
        _circle,
        _triangle,
        _triangle,
        _square,
        _square,
        _square,
        _circle,
        _triangle,
        _triangle,
      ],
      answer: _square,
      options: [_square, _triangle, _circle, _diamond],
      rule: 'Groups grow from one, to two, to three shapes.',
    ),
    PatternRound(
      sequence: [
        _heart,
        _star,
        _diamond,
        _star,
        _heart,
        _heart,
        _star,
        _diamond,
        _star,
      ],
      answer: _heart,
      options: [_heart, _diamond, _star, _circle],
      rule: 'The five-shape mirror repeats.',
    ),
  ];

  static List<PatternRound> createSession({
    required int age,
    PatternSprintMode mode = PatternSprintMode.classic,
    int? seed,
  }) {
    if (!supportedAges.contains(age)) {
      throw ArgumentError.value(age, 'age', 'Age must be 5, 6, or 7.');
    }

    final isBoost = mode == PatternSprintMode.timeBoost;
    final roundCount = isBoost ? 6 : 5;
    final shapeStart = isBoost
        ? switch (age) {
            5 => 1,
            6 => 2,
            _ => 4,
          }
        : age - 5;
    final shapes = _shapeRounds.skip(shapeStart).take(roundCount);
    final numbers = isBoost ? _boostNumberRounds(age) : _numberRounds(age);
    final rounds = <PatternRound>[];
    for (var index = 0; index < roundCount; index++) {
      rounds
        ..add(shapes.elementAt(index))
        ..add(numbers[index]);
    }

    final random = Random(seed);
    return [for (final round in rounds) round.shuffled(random)];
  }

  static List<PatternRound> _numberRounds(int age) => switch (age) {
        5 => [
            _numeric([1, 2, 3, 4, 5], 6, [5, 6, 7, 8], 'Count forward by one.'),
            _numeric(
                [2, 4, 6, 8], 10, [9, 10, 11, 12], 'Count forward by two.'),
            _numeric([5, 4, 3, 2], 1, [0, 1, 2, 3], 'Count backward by one.'),
            _numeric(
                [1, 1, 2, 2, 3], 3, [2, 3, 4, 5], 'Each number appears twice.'),
            _numeric(
                [2, 3, 2, 3, 2], 3, [1, 2, 3, 4], 'Two numbers take turns.'),
          ],
        6 => [
            _numeric([2, 4, 6, 8], 10, [8, 9, 10, 12], 'Count forward by two.'),
            _numeric([10, 8, 6, 4], 2, [0, 1, 2, 3], 'Count backward by two.'),
            _numeric(
                [1, 3, 5, 7], 9, [8, 9, 10, 11], 'These are the odd numbers.'),
            _numeric(
                [3, 6, 9, 12], 15, [13, 14, 15, 16], 'Count forward by three.'),
            _numeric([2, 3, 4, 2, 3], 4, [2, 3, 4, 5],
                'A group of three numbers repeats.'),
          ],
        _ => [
            _numeric([5, 10, 15, 20], 25, [21, 23, 25, 30],
                'Count forward by five.'),
            _numeric(
                [2, 4, 8, 16], 32, [20, 24, 30, 32], 'Each number doubles.'),
            _numeric(
                [1, 4, 7, 10], 13, [11, 12, 13, 14], 'Count forward by three.'),
            _numeric([20, 18, 15, 11], 6, [5, 6, 7, 8],
                'Subtract 2, then 3, then 4, then 5.'),
            _numeric([1, 2, 4, 7, 11], 16, [14, 15, 16, 17],
                'Add 1, then 2, then 3, then 4, then 5.'),
          ],
      };

  static List<PatternRound> _boostNumberRounds(int age) => switch (age) {
        5 => [
            _numeric([1, 3, 5, 7], 9, [8, 9, 10, 11], 'Count forward by two.'),
            _numeric([10, 8, 6, 4], 2, [1, 2, 3, 4], 'Count backward by two.'),
            _numeric(
                [1, 1, 2, 2, 3], 3, [2, 3, 4, 5], 'Each number appears twice.'),
            _numeric(
                [2, 4, 2, 4, 2], 4, [2, 3, 4, 5], 'Two numbers take turns.'),
            _numeric([2, 3, 4, 2, 3], 4, [2, 3, 4, 5],
                'A group of three numbers repeats.'),
            _numeric(
                [3, 6, 9, 12], 15, [12, 13, 14, 15], 'Count forward by three.'),
          ],
        6 => [
            _numeric(
                [3, 6, 9, 12], 15, [13, 14, 15, 16], 'Count forward by three.'),
            _numeric(
                [15, 12, 9, 6], 3, [2, 3, 4, 5], 'Count backward by three.'),
            _numeric(
                [2, 4, 8, 16], 32, [24, 28, 30, 32], 'Each number doubles.'),
            _numeric([1, 2, 4, 7], 11, [9, 10, 11, 12],
                'Add 1, then 2, then 3, then 4.'),
            _numeric(
                [2, 5, 2, 5, 2], 5, [2, 3, 4, 5], 'Two numbers take turns.'),
            _numeric([1, 3, 3, 5, 5], 7, [5, 6, 7, 8],
                'Odd numbers appear in pairs.'),
          ],
        _ => [
            _numeric(
                [2, 4, 8, 16], 32, [24, 28, 30, 32], 'Each number doubles.'),
            _numeric([1, 2, 4, 7, 11], 16, [14, 15, 16, 17],
                'The gap grows by one each time.'),
            _numeric([30, 27, 23, 18], 12, [10, 11, 12, 13],
                'Subtract 3, then 4, then 5, then 6.'),
            _numeric([2, 5, 10, 17], 26, [24, 25, 26, 27],
                'Add 3, then 5, then 7, then 9.'),
            _numeric([1, 4, 9, 16], 25, [20, 24, 25, 26],
                'These are square numbers.'),
            _numeric([2, 3, 5, 8, 13], 21, [18, 19, 20, 21],
                'Add the previous two numbers.'),
          ],
      };

  static PatternRound _numeric(
    List<int> sequence,
    int answer,
    List<int> options,
    String rule,
  ) =>
      PatternRound(
        sequence: sequence.map(_number).toList(growable: false),
        answer: _number(answer),
        options: options.map(_number).toList(growable: false),
        rule: rule,
      );

  static int pointsFor({
    required int streak,
    required int secondsRemaining,
  }) {
    return 100 + min(streak, 5) * 20 + min(secondsRemaining, 60);
  }

  static int initialSeconds(PatternSprintMode mode) =>
      mode == PatternSprintMode.timeBoost ? timeBoostSeconds : totalSeconds;

  static int timeBonusFor(Duration responseTime) {
    if (responseTime <= const Duration(seconds: 4)) return 5;
    if (responseTime <= const Duration(seconds: 7)) return 3;
    return 0;
  }
}
