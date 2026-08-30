import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logic_lab/mini_apps/edu_fun/logic/game_engine.dart';
import 'package:logic_lab/mini_apps/edu_fun/logic/question_factory.dart';
import 'package:logic_lab/mini_apps/edu_fun/models/edu_fun_models.dart';
import 'package:logic_lab/mini_apps/edu_fun/widgets/edu_components.dart';

class EduGameScreen extends StatefulWidget {
  final EduPlayer player;
  final ValueChanged<EduSession> onComplete;

  const EduGameScreen({
    super.key,
    required this.player,
    required this.onComplete,
  });

  @override
  State<EduGameScreen> createState() => _EduGameScreenState();
}

class _EduGameScreenState extends State<EduGameScreen> {
  late final List<EduQuestion> _questions;
  final _engine = GameEngine();
  final _gameClock = Stopwatch();
  final _questionClock = Stopwatch();
  Timer? _nextTimer;

  int _index = 0;
  int? _selectedAnswer;
  AnswerOutcome? _outcome;

  EduQuestion get _question => _questions[_index];

  @override
  void initState() {
    super.initState();
    _questions = QuestionFactory.generateSession(widget.player.age);
    _gameClock.start();
    _questionClock.start();
  }

  @override
  void dispose() {
    _nextTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return EduScreen(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 42),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _GameMetric(
                  emoji: '⭐',
                  label: 'Score',
                  value: '${_engine.score}',
                  color: EduColors.yellow,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _GameMetric(
                  emoji: '🔥',
                  label: 'Streak',
                  value: '${_engine.streak}',
                  color: EduColors.pink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _ProgressTrack(current: _index),
          const SizedBox(height: 22),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween(
                  begin: const Offset(0.04, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: EduPanel(
              key: ValueKey(_question.id),
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.sizeOf(context).width > 600 ? 40 : 22,
                vertical: 30,
              ),
              borderColor: _question.isFinal
                  ? EduColors.yellow.withValues(alpha: 0.5)
                  : null,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: EduColors.purple.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          _question.isFinal
                              ? 'FINAL CHALLENGE'
                              : 'CHALLENGE ${_index + 1} OF 10',
                          style: tt.labelSmall?.copyWith(
                            color: _question.isFinal
                                ? EduColors.yellow
                                : EduColors.purple,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    _question.skill,
                    style: tt.labelMedium?.copyWith(color: Colors.white38),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _question.prompt,
                    textAlign: TextAlign.center,
                    style: tt.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                  if (_question.visual != null) ...[
                    const SizedBox(height: 20),
                    Text(
                      _question.visual!,
                      textAlign: TextAlign.center,
                      style: tt.titleLarge?.copyWith(
                        color: EduColors.cyan,
                        fontWeight: FontWeight.w700,
                        height: 1.55,
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  _AnswerChoices(
                    options: _question.options,
                    selected: _selectedAnswer,
                    correctAnswer:
                        _outcome == null ? null : _question.correctAnswer,
                    onSelected: _answer,
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 220),
                    child: _outcome == null
                        ? const SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.only(top: 22),
                            child: _Feedback(
                              outcome: _outcome!,
                              correctAnswer: _question.correctAnswer,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Take your time — careful thinking earns stars! ✨',
            textAlign: TextAlign.center,
            style: tt.bodySmall?.copyWith(color: Colors.white38),
          ),
        ],
      ),
    );
  }

  void _answer(int answer) {
    if (_outcome != null) return;
    _questionClock.stop();
    final outcome = _engine.answer(
      _question,
      answer,
      _questionClock.elapsed,
    );
    setState(() {
      _selectedAnswer = answer;
      _outcome = outcome;
    });

    _nextTimer = Timer(const Duration(milliseconds: 1050), () {
      if (!mounted) return;
      if (_index == _questions.length - 1) {
        _gameClock.stop();
        widget.onComplete(
          EduSession.completed(
            player: widget.player,
            score: _engine.score,
            correct: _engine.correct,
            bestStreak: _engine.bestStreak,
            durationSeconds: _gameClock.elapsed.inSeconds.clamp(10, 3600),
          ),
        );
        return;
      }

      setState(() {
        _index++;
        _selectedAnswer = null;
        _outcome = null;
      });
      _questionClock
        ..reset()
        ..start();
    });
  }
}

class _ProgressTrack extends StatelessWidget {
  final int current;
  const _ProgressTrack({required this.current});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Number Mission',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            Text(
              '${current + 1} / 10',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: EduColors.yellow,
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        Row(
          children: [
            for (var index = 0; index < 10; index++) ...[
              if (index > 0) const SizedBox(width: 4),
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  height: 8,
                  decoration: BoxDecoration(
                    color: index <= current
                        ? EduColors.yellow
                        : Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _AnswerChoices extends StatelessWidget {
  final List<int> options;
  final int? selected;
  final int? correctAnswer;
  final ValueChanged<int> onSelected;

  const _AnswerChoices({
    required this.options,
    required this.selected,
    required this.correctAnswer,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontal = constraints.maxWidth >= 520;
        final buttons = [
          for (final option in options)
            _AnswerButton(
              value: option,
              selected: selected == option,
              correct: correctAnswer == option,
              revealed: correctAnswer != null,
              onTap: () => onSelected(option),
            ),
        ];
        if (horizontal) {
          return Row(
            children: [
              for (var index = 0; index < buttons.length; index++) ...[
                if (index > 0) const SizedBox(width: 12),
                Expanded(child: buttons[index]),
              ],
            ],
          );
        }
        return Column(
          children: [
            for (var index = 0; index < buttons.length; index++) ...[
              if (index > 0) const SizedBox(height: 11),
              buttons[index],
            ],
          ],
        );
      },
    );
  }
}

class _AnswerButton extends StatelessWidget {
  final int value;
  final bool selected;
  final bool correct;
  final bool revealed;
  final VoidCallback onTap;

  const _AnswerButton({
    required this.value,
    required this.selected,
    required this.correct,
    required this.revealed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = revealed && correct
        ? EduColors.green
        : revealed && selected
            ? EduColors.pink
            : selected
                ? EduColors.yellow
                : EduColors.surfaceBright;
    return Semantics(
      button: true,
      label: 'Answer $value',
      child: InkWell(
        onTap: revealed ? null : onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          height: 76,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: revealed || selected ? 0.22 : 1),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: revealed || selected ? color : Colors.white12,
              width: 2,
            ),
          ),
          child: Text(
            '$value',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
          ),
        ),
      ),
    );
  }
}

class _Feedback extends StatelessWidget {
  final AnswerOutcome outcome;
  final int correctAnswer;

  const _Feedback({required this.outcome, required this.correctAnswer});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: (outcome.isCorrect ? EduColors.green : EduColors.pink)
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            outcome.isCorrect ? '⭐ Great Job!' : '💡 Almost!',
            style: tt.titleMedium?.copyWith(
              color: outcome.isCorrect ? EduColors.green : EduColors.pink,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            outcome.isCorrect
                ? '+${outcome.points} points${outcome.streakBonus > 0 ? ' · Streak bonus!' : ''}'
                : 'The answer is $correctAnswer — keep going!',
            textAlign: TextAlign.center,
            style: tt.bodyMedium?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _GameMetric extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final Color color;

  const _GameMetric({
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: Colors.white54),
              ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ],
        ),
      );
}
