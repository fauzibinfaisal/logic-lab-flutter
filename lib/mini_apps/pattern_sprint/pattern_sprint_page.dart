import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logic_lab/mini_apps/pattern_sprint/logic/pattern_engine.dart';
import 'package:logic_lab/visit_counter/widgets/visit_count_badge.dart';

const _ink = Color(0xFF11162D);
const _purple = Color(0xFF7C5CFC);
const _pink = Color(0xFFFF6FAE);
const _mint = Color(0xFF67E8C2);
const _cream = Color(0xFFFFF8EE);

enum _SprintView { welcome, playing, results }

class PatternSprintPage extends StatefulWidget {
  final int? visitCount;
  final bool visitCountLoading;
  final VoidCallback? onExit;

  const PatternSprintPage({
    super.key,
    this.visitCount,
    this.visitCountLoading = false,
    this.onExit,
  });

  @override
  State<PatternSprintPage> createState() => _PatternSprintPageState();
}

class _PatternSprintPageState extends State<PatternSprintPage> {
  _SprintView _view = _SprintView.welcome;
  List<PatternRound> _rounds = const [];
  int _roundIndex = 0;
  int _score = 0;
  int _correct = 0;
  int _streak = 0;
  int _bestStreak = 0;
  int _lives = PatternEngine.startingLives;
  int _secondsRemaining = PatternEngine.totalSeconds;
  int _age = 5;
  PatternSprintMode _mode = PatternSprintMode.classic;
  DateTime _roundStartedAt = DateTime.now();
  int _timeBonusEarned = 0;
  int _totalBonusSeconds = 0;
  PatternToken? _selected;
  bool _answerLocked = false;
  Timer? _timer;

  PatternRound get _round => _rounds[_roundIndex];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startGame() {
    _timer?.cancel();
    setState(() {
      _rounds = PatternEngine.createSession(age: _age, mode: _mode);
      _roundIndex = 0;
      _score = 0;
      _correct = 0;
      _streak = 0;
      _bestStreak = 0;
      _lives = PatternEngine.startingLives;
      _secondsRemaining = PatternEngine.initialSeconds(_mode);
      _roundStartedAt = DateTime.now();
      _timeBonusEarned = 0;
      _totalBonusSeconds = 0;
      _selected = null;
      _answerLocked = false;
      _view = _SprintView.playing;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _view != _SprintView.playing) return;
      if (_secondsRemaining <= 1) {
        setState(() => _secondsRemaining = 0);
        _finishGame();
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  Future<void> _choose(PatternToken mark) async {
    if (_answerLocked || _view != _SprintView.playing) return;
    final isCorrect = mark == _round.answer;
    final responseTime = DateTime.now().difference(_roundStartedAt);
    final timeBonus = isCorrect && _mode == PatternSprintMode.timeBoost
        ? PatternEngine.timeBonusFor(responseTime)
        : 0;
    setState(() {
      _answerLocked = true;
      _selected = mark;
      if (isCorrect) {
        _correct++;
        _streak++;
        if (_streak > _bestStreak) _bestStreak = _streak;
        _score += PatternEngine.pointsFor(
          streak: _streak,
          secondsRemaining: _secondsRemaining,
        );
        _secondsRemaining += timeBonus;
        _timeBonusEarned = timeBonus;
        _totalBonusSeconds += timeBonus;
      } else {
        _streak = 0;
        _lives--;
      }
    });

    await Future<void>.delayed(const Duration(milliseconds: 520));
    if (!mounted || _view != _SprintView.playing) return;
    if (_lives == 0 || _roundIndex == _rounds.length - 1) {
      _finishGame();
      return;
    }
    setState(() {
      _roundIndex++;
      _selected = null;
      _answerLocked = false;
      _roundStartedAt = DateTime.now();
      _timeBonusEarned = 0;
    });
  }

  void _finishGame() {
    _timer?.cancel();
    if (!mounted || _view == _SprintView.results) return;
    setState(() {
      _answerLocked = true;
      _view = _SprintView.results;
    });
  }

  void _showWelcome() {
    _timer?.cancel();
    setState(() => _view = _SprintView.welcome);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: _ink,
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topRight,
              radius: 1.35,
              colors: [Color(0xFF362A73), _ink],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _TopBar(
                  visitCount: widget.visitCount,
                  visitCountLoading: widget.visitCountLoading,
                  onBack: widget.onExit ?? () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 240),
                    child: KeyedSubtree(
                      key: ValueKey(_view),
                      child: switch (_view) {
                        _SprintView.welcome => _Welcome(
                            age: _age,
                            mode: _mode,
                            onAgeChanged: (age) => setState(() => _age = age),
                            onModeChanged: (mode) =>
                                setState(() => _mode = mode),
                            onStart: _startGame,
                          ),
                        _SprintView.playing => _Game(
                            round: _round,
                            roundIndex: _roundIndex,
                            totalRounds: _rounds.length,
                            score: _score,
                            streak: _streak,
                            lives: _lives,
                            secondsRemaining: _secondsRemaining,
                            mode: _mode,
                            timeBonusEarned: _timeBonusEarned,
                            selected: _selected,
                            locked: _answerLocked,
                            onChoose: _choose,
                          ),
                        _SprintView.results => _Results(
                            score: _score,
                            correct: _correct,
                            attempted: _roundIndex + 1,
                            bestStreak: _bestStreak,
                            secondsRemaining: _secondsRemaining,
                            mode: _mode,
                            totalBonusSeconds: _totalBonusSeconds,
                            onReplay: _startGame,
                            onHome: _showWelcome,
                          ),
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _TopBar extends StatelessWidget {
  final VoidCallback onBack;
  final int? visitCount;
  final bool visitCountLoading;

  const _TopBar({
    required this.onBack,
    required this.visitCount,
    required this.visitCountLoading,
  });

  @override
  Widget build(BuildContext context) => Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: _ink.withValues(alpha: 0.82),
          border: const Border(bottom: BorderSide(color: Colors.white10)),
        ),
        child: Row(
          children: [
            IconButton(
              tooltip: 'Back to Mini Apps',
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const SizedBox(width: 5),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _purple.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(Icons.auto_graph_rounded, color: _mint),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Pattern Sprint',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
              ),
            ),
            VisitCountBadge(
              count: visitCount,
              loading: visitCountLoading,
              color: _mint,
              compact: true,
            ),
          ],
        ),
      );
}

class _Welcome extends StatelessWidget {
  final int age;
  final PatternSprintMode mode;
  final ValueChanged<int> onAgeChanged;
  final ValueChanged<PatternSprintMode> onModeChanged;
  final VoidCallback onStart;

  const _Welcome({
    required this.age,
    required this.mode,
    required this.onAgeChanged,
    required this.onModeChanged,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 32, 20, 48),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Column(
              children: [
                const _PatternPreview(),
                const SizedBox(height: 28),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: _mint.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: _mint.withValues(alpha: 0.35)),
                  ),
                  child: const Text(
                    'QUICK BRAIN WARM-UP',
                    style: TextStyle(
                      color: _mint,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.25,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Spot the pattern.\nBeat the clock.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        height: 1.08,
                      ),
                ),
                const SizedBox(height: 14),
                Text(
                  mode == PatternSprintMode.classic
                      ? 'Choose the shape or number that comes next. Every session mixes 10 age-friendly challenges.'
                      : 'Solve 12 trickier patterns. Answer quickly to earn extra seconds and keep the sprint alive.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white60,
                        height: 1.55,
                      ),
                ),
                const SizedBox(height: 26),
                Text(
                  'Player age',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 10),
                SegmentedButton<int>(
                  key: const Key('pattern-age-selector'),
                  segments: const [
                    ButtonSegment(
                      value: 5,
                      label: Text('5', semanticsLabel: 'Age 5'),
                    ),
                    ButtonSegment(
                      value: 6,
                      label: Text('6', semanticsLabel: 'Age 6'),
                    ),
                    ButtonSegment(
                      value: 7,
                      label: Text('7', semanticsLabel: 'Age 7'),
                    ),
                  ],
                  selected: {age},
                  showSelectedIcon: false,
                  onSelectionChanged: (selection) =>
                      onAgeChanged(selection.first),
                  style: ButtonStyle(
                    foregroundColor: const WidgetStatePropertyAll(Colors.white),
                    backgroundColor: WidgetStateProperty.resolveWith(
                      (states) => states.contains(WidgetState.selected)
                          ? _purple
                          : Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'Game type',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _ModeOption(
                        key: const Key('pattern-mode-classic'),
                        selected: mode == PatternSprintMode.classic,
                        icon: Icons.self_improvement_rounded,
                        title: 'Classic',
                        subtitle: '60s · steady',
                        onTap: () => onModeChanged(PatternSprintMode.classic),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ModeOption(
                        key: const Key('pattern-mode-timeBoost'),
                        selected: mode == PatternSprintMode.timeBoost,
                        icon: Icons.bolt_rounded,
                        title: 'Time Boost',
                        subtitle: '30s · earn time',
                        onTap: () => onModeChanged(PatternSprintMode.timeBoost),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _RuleChip(
                      icon: Icons.grid_view_rounded,
                      label: mode == PatternSprintMode.classic
                          ? '10 rounds'
                          : '12 rounds',
                    ),
                    _RuleChip(
                      icon: Icons.timer_outlined,
                      label: mode == PatternSprintMode.classic
                          ? '60 seconds'
                          : '30 seconds',
                    ),
                    if (mode == PatternSprintMode.timeBoost)
                      const _RuleChip(
                        icon: Icons.add_alarm_rounded,
                        label: 'Up to +5s',
                      )
                    else
                      const _RuleChip(
                        icon: Icons.favorite_rounded,
                        label: '3 lives',
                      ),
                  ],
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: 260,
                  height: 54,
                  child: FilledButton.icon(
                    key: const Key('pattern-start'),
                    onPressed: onStart,
                    icon: const Icon(Icons.bolt_rounded),
                    label: Text(
                      mode == PatternSprintMode.classic
                          ? 'Start sprint'
                          : 'Start Time Boost',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: _purple,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _PatternPreview extends StatelessWidget {
  const _PatternPreview();

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: Colors.white12),
          boxShadow: [
            BoxShadow(
              color: _purple.withValues(alpha: 0.15),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _MarkTile(
              token: PatternToken.shape(PatternShape.circle),
              compact: true,
            ),
            _MarkTile(token: PatternToken.number(2), compact: true),
            _MarkTile(
              token: PatternToken.shape(PatternShape.triangle),
              compact: true,
            ),
            _MarkTile(token: PatternToken.number(4), compact: true),
            _QuestionTile(compact: true),
          ],
        ),
      );
}

class _ModeOption extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ModeOption({
    super.key,
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Material(
        color: selected
            ? _purple.withValues(alpha: 0.2)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            constraints: const BoxConstraints(minHeight: 92),
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected ? _purple : Colors.white12,
                width: selected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: selected ? _mint : Colors.white54, size: 22),
                const SizedBox(height: 6),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      );
}

class _RuleChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _RuleChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: _mint),
            const SizedBox(width: 7),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      );
}

class _Game extends StatelessWidget {
  final PatternRound round;
  final int roundIndex;
  final int totalRounds;
  final int score;
  final int streak;
  final int lives;
  final int secondsRemaining;
  final PatternSprintMode mode;
  final int timeBonusEarned;
  final PatternToken? selected;
  final bool locked;
  final ValueChanged<PatternToken> onChoose;

  const _Game({
    required this.round,
    required this.roundIndex,
    required this.totalRounds,
    required this.score,
    required this.streak,
    required this.lives,
    required this.secondsRemaining,
    required this.mode,
    required this.timeBonusEarned,
    required this.selected,
    required this.locked,
    required this.onChoose,
  });

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 22, 16, 42),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _Metric(
                        icon: Icons.bolt_rounded,
                        label: '$score',
                        color: _mint,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _Metric(
                        icon: Icons.local_fire_department_rounded,
                        label: '${streak}x',
                        color: const Color(0xFFFFB65C),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _Metric(
                        icon: Icons.timer_rounded,
                        label: '${secondsRemaining}s',
                        color: secondsRemaining <= 10 ? _pink : _mint,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          minHeight: 8,
                          value: (roundIndex + 1) / totalRounds,
                          backgroundColor: Colors.white10,
                          color: _purple,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${roundIndex + 1}/$totalRounds',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 12),
                    for (var index = 0;
                        index < PatternEngine.startingLives;
                        index++)
                      Padding(
                        padding: const EdgeInsets.only(left: 3),
                        child: Icon(
                          index < lives
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 18,
                          color: index < lives ? _pink : Colors.white24,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 30),
                if (mode == PatternSprintMode.timeBoost) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                    decoration: BoxDecoration(
                      color: _mint.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: _mint.withValues(alpha: 0.25)),
                    ),
                    child: const Text(
                      'TIME BOOST · ANSWER FAST TO EARN TIME',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _mint,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.7,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  'What comes next?',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Look carefully, then pick one answer.',
                  style: TextStyle(color: Colors.white54),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
                  decoration: BoxDecoration(
                    color: _cream,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: _purple.withValues(alpha: 0.18),
                        blurRadius: 36,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxWidth < 430;
                      return Wrap(
                        alignment: WrapAlignment.center,
                        runAlignment: WrapAlignment.center,
                        spacing: compact ? 7 : 12,
                        runSpacing: 10,
                        children: [
                          for (final mark in round.sequence)
                            _MarkTile(token: mark, compact: compact),
                          _QuestionTile(compact: compact),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 22),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = (constraints.maxWidth - 12) / 2;
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        for (final option in round.options)
                          SizedBox(
                            width: width,
                            height: 92,
                            child: _AnswerButton(
                              key: Key('pattern-option-${option.key}'),
                              token: option,
                              selected: selected == option,
                              correct: locked && option == round.answer,
                              wrong: locked &&
                                  selected == option &&
                                  option != round.answer,
                              onTap: locked ? null : () => onChoose(option),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 180),
                  child: locked
                      ? Padding(
                          padding: const EdgeInsets.only(top: 18),
                          child: Text(
                            selected == round.answer
                                ? timeBonusEarned > 0
                                    ? 'Fast! +${timeBonusEarned}s · ${round.rule}'
                                    : 'Nice! ${round.rule}'
                                : 'Almost! ${round.rule}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: selected == round.answer ? _mint : _pink,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      );
}

class _Metric extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Metric({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      );
}

class _AnswerButton extends StatelessWidget {
  final PatternToken token;
  final bool selected;
  final bool correct;
  final bool wrong;
  final VoidCallback? onTap;

  const _AnswerButton({
    super.key,
    required this.token,
    required this.selected,
    required this.correct,
    required this.wrong,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = correct
        ? _mint
        : wrong
            ? _pink
            : selected
                ? _purple
                : Colors.white24;
    return Material(
      color:
          color.withValues(alpha: correct || wrong || selected ? 0.18 : 0.06),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color, width: correct || wrong ? 2 : 1),
          ),
          child: Center(
            child: _TokenVisual(token: token, size: 42),
          ),
        ),
      ),
    );
  }
}

class _MarkTile extends StatelessWidget {
  final PatternToken token;
  final bool compact;

  const _MarkTile({required this.token, required this.compact});

  @override
  Widget build(BuildContext context) {
    final size = compact ? 43.0 : 58.0;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _colorFor(token).withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(compact ? 13 : 17),
      ),
      child: _TokenVisual(token: token, size: compact ? 25 : 33),
    );
  }
}

class _QuestionTile extends StatelessWidget {
  final bool compact;

  const _QuestionTile({required this.compact});

  @override
  Widget build(BuildContext context) {
    final size = compact ? 43.0 : 58.0;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _purple.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(compact ? 13 : 17),
        border: Border.all(color: _purple.withValues(alpha: 0.5)),
      ),
      child: Text(
        '?',
        style: TextStyle(
          color: _purple,
          fontSize: compact ? 22 : 28,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _Results extends StatelessWidget {
  final int score;
  final int correct;
  final int attempted;
  final int bestStreak;
  final int secondsRemaining;
  final PatternSprintMode mode;
  final int totalBonusSeconds;
  final VoidCallback onReplay;
  final VoidCallback onHome;

  const _Results({
    required this.score,
    required this.correct,
    required this.attempted,
    required this.bestStreak,
    required this.secondsRemaining,
    required this.mode,
    required this.totalBonusSeconds,
    required this.onReplay,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    final title = correct >= 9
        ? 'Pattern master!'
        : correct >= 6
            ? 'Great sprint!'
            : 'Good warm-up!';
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 38, 20, 48),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Column(
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_purple, _pink]),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: _purple.withValues(alpha: 0.3),
                      blurRadius: 34,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: Colors.white,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                mode == PatternSprintMode.timeBoost
                    ? 'Quick thinking earned $totalBonusSeconds extra seconds.'
                    : 'Every pattern you spot makes the next one easier.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60, height: 1.5),
              ),
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  children: [
                    const Text(
                      'FINAL SCORE',
                      style: TextStyle(
                        color: _mint,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$score',
                      style:
                          Theme.of(context).textTheme.displayMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _ResultStat(
                            value: '$correct/$attempted',
                            label: 'Correct',
                          ),
                        ),
                        Expanded(
                          child: _ResultStat(
                            value: '${bestStreak}x',
                            label: 'Best streak',
                          ),
                        ),
                        Expanded(
                          child: _ResultStat(
                            value: '${secondsRemaining}s',
                            label: 'Time left',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  key: const Key('pattern-replay'),
                  onPressed: onReplay,
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Sprint again'),
                  style: FilledButton.styleFrom(
                    backgroundColor: _purple,
                    textStyle: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(onPressed: onHome, child: const Text('How to play')),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultStat extends StatelessWidget {
  final String value;
  final String label;

  const _ResultStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ],
      );
}

class _TokenVisual extends StatelessWidget {
  final PatternToken token;
  final double size;

  const _TokenVisual({required this.token, required this.size});

  @override
  Widget build(BuildContext context) => token.isNumber
      ? Text(
          '${token.number}',
          semanticsLabel: 'Number ${token.number}',
          style: TextStyle(
            color: _colorFor(token),
            fontSize: size * 0.82,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        )
      : Icon(
          _iconFor(token.shape!),
          size: size,
          color: _colorFor(token),
          semanticLabel: token.shape!.name,
        );
}

IconData _iconFor(PatternShape shape) => switch (shape) {
      PatternShape.circle => Icons.circle_rounded,
      PatternShape.triangle => Icons.change_history_rounded,
      PatternShape.square => Icons.square_rounded,
      PatternShape.star => Icons.star_rounded,
      PatternShape.heart => Icons.favorite_rounded,
      PatternShape.diamond => Icons.diamond_rounded,
    };

Color _colorFor(PatternToken token) {
  if (token.isNumber) {
    const colors = [_purple, Color(0xFF5B8DEF), _pink, _mint];
    return colors[token.number!.abs() % colors.length];
  }
  return switch (token.shape!) {
    PatternShape.circle => const Color(0xFF5B8DEF),
    PatternShape.triangle => const Color(0xFFFF9F43),
    PatternShape.square => const Color(0xFF38C9A5),
    PatternShape.star => const Color(0xFFFFC857),
    PatternShape.heart => const Color(0xFFFF6FAE),
    PatternShape.diamond => const Color(0xFF9B7BFF),
  };
}
