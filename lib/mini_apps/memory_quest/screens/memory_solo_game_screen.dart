import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:logic_lab/mini_apps/memory_quest/logic/memory_engine.dart';
import 'package:logic_lab/mini_apps/memory_quest/models/memory_models.dart';
import 'package:logic_lab/mini_apps/memory_quest/widgets/memory_components.dart';

class MemorySoloGameScreen extends StatefulWidget {
  final MemoryPlayer player;
  final ValueChanged<MemorySession> onComplete;
  final int initialTimeMs;
  final Random? random;
  final int Function()? nowMs;

  const MemorySoloGameScreen({
    super.key,
    required this.player,
    required this.onComplete,
    this.initialTimeMs = 60000,
    this.random,
    this.nowMs,
  });

  @override
  State<MemorySoloGameScreen> createState() => _MemorySoloGameScreenState();
}

class _MemorySoloGameScreenState extends State<MemorySoloGameScreen>
    with WidgetsBindingObserver {
  late final Random _random;
  late final int Function() _nowMs;
  late final DateTime _startedAt;
  late MemoryStageConfig _config;
  late List<MemoryCardData> _cards;
  Timer? _ticker;

  int _stage = 1;
  int _remainingMs = 60000;
  int _elapsedActiveMs = 0;
  int _score = 0;
  int _pairsFound = 0;
  int _moves = 0;
  int _combo = 0;
  int _bestCombo = 0;
  int _stagePairs = 0;
  int _stageMoves = 0;
  int _stageMisses = 0;
  int _fastestStageMs = 0;
  int? _firstIndex;
  int? _firstRevealEpochMs;
  int _stageStartedElapsedMs = 0;
  int _lastTickMs = 0;
  bool _locked = false;
  bool _paused = false;
  bool _finished = false;
  bool _stageShuffled = false;
  String _feedback = 'Find the first pair!';
  Color _feedbackColor = MemoryColors.cyan;
  _StageClearData? _stageClear;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _random = widget.random ?? Random();
    _nowMs = widget.nowMs ?? () => DateTime.now().millisecondsSinceEpoch;
    _startedAt = DateTime.now();
    _remainingMs = widget.initialTimeMs;
    _prepareStage();
    _lastTickMs = _nowMs();
    _ticker = Timer.periodic(const Duration(milliseconds: 50), (_) => _tick());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed && !_finished) {
      setState(() => _paused = true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final urgent = _remainingMs <= 10000;
    return Stack(
      children: [
        MemoryScreen(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 40),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _HudTile(
                      label: 'STAGE',
                      value: '$_stage',
                      color: MemoryColors.cyan,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _HudTile(
                      label: 'TIME',
                      value: _time(_remainingMs),
                      color: urgent ? MemoryColors.pink : MemoryColors.yellow,
                      urgent: urgent,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _HudTile(
                      label: 'SCORE',
                      value: compactScore(_score),
                      color: MemoryColors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _StatusPill(
                      label: '🔥 Combo ×$_combo',
                      color: MemoryColors.pink,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatusPill(
                      label: '${_config.theme} · ${_config.modifier}',
                      color: MemoryColors.purple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 11),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: _feedbackColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: _feedbackColor.withValues(alpha: 0.22),
                  ),
                ),
                child: Text(
                  _feedback,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: _feedbackColor,
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
              const SizedBox(height: 14),
              MemoryBoard(
                cards: _cards,
                columns: _config.columns,
                locked: _locked || _paused || _stageClear != null,
                onCardTap: _tapCard,
              ),
              const SizedBox(height: 13),
              Text(
                '$_stagePairs/${_config.pairCount} pairs · $_stageMoves moves',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.white.withValues(alpha: 0.45)),
              ),
            ],
          ),
        ),
        if (_paused && _stageClear == null)
          _GameOverlay(
            emoji: '👋',
            title: 'Welcome back!',
            message: 'The timer paused while the game was out of focus.',
            buttonLabel: 'RESUME GAME',
            onPressed: _resume,
          ),
        if (_stageClear case final data?)
          _GameOverlay(
            emoji: data.perfect ? '🧠✨' : '🎉',
            title: data.perfect ? 'PERFECT MEMORY!' : 'STAGE CLEAR!',
            message:
                '${data.pairs} pairs · ${data.moves} moves · ${data.accuracy}% accuracy\n+${data.bonusSeconds} SEC · +${compactScore(data.scoreBonus)} points',
          ),
      ],
    );
  }

  void _prepareStage() {
    _config = MemoryBoardFactory.configFor(_stage);
    _cards = MemoryBoardFactory.build(config: _config, random: _random);
    _stagePairs = 0;
    _stageMoves = 0;
    _stageMisses = 0;
    _stageShuffled = false;
    _firstIndex = null;
    _firstRevealEpochMs = null;
    _stageStartedElapsedMs = _elapsedActiveMs;
  }

  void _tick() {
    if (!mounted || _paused || _stageClear != null || _finished) {
      _lastTickMs = _nowMs();
      return;
    }
    final now = _nowMs();
    final delta = (now - _lastTickMs).clamp(0, 250);
    _lastTickMs = now;
    final next = _remainingMs - delta;
    if (next <= 0) {
      setState(() {
        _remainingMs = 0;
        _feedback = "TIME'S UP!";
        _feedbackColor = MemoryColors.pink;
      });
      _finish();
      return;
    }
    setState(() {
      _remainingMs = next;
      _elapsedActiveMs += delta;
    });
  }

  void _tapCard(int index) {
    if (_locked || _paused || _finished || _cards[index].isMatched) return;
    if (_firstIndex == index) return;

    final now = _nowMs();
    setState(() {
      _cards[index] = _cards[index].copyWith(isRevealed: true);
      if (_firstIndex == null) {
        _firstIndex = index;
        _firstRevealEpochMs = now;
        _feedback = 'Remember it… now find the pair!';
        _feedbackColor = MemoryColors.cyan;
      } else {
        _locked = true;
      }
    });
    if (_locked) _resolvePair(index, now);
  }

  Future<void> _resolvePair(int secondIndex, int nowMs) async {
    final firstIndex = _firstIndex!;
    final matched = _cards[firstIndex].symbol == _cards[secondIndex].symbol;
    final gap = nowMs - (_firstRevealEpochMs ?? nowMs);
    _stageMoves++;
    _moves++;
    await Future<void>.delayed(const Duration(milliseconds: 280));
    if (!mounted || _finished) return;

    if (matched) {
      _combo++;
      _bestCombo = max(_bestCombo, _combo);
      _stagePairs++;
      _pairsFound++;
      final points = MemoryScoring.pairScore(
        stage: _stage,
        combo: _combo,
        revealGapMs: gap,
        pairs: _stagePairs,
        moves: _stageMoves,
      );
      setState(() {
        _cards[firstIndex] =
            _cards[firstIndex].copyWith(isMatched: true, isRevealed: true);
        _cards[secondIndex] =
            _cards[secondIndex].copyWith(isMatched: true, isRevealed: true);
        _score += points;
        _feedback = _combo >= 3
            ? '🔥 PERFECT MATCH! Combo ×$_combo · +$points'
            : 'MATCH! +$points';
        _feedbackColor = MemoryColors.green;
        _firstIndex = null;
        _firstRevealEpochMs = null;
      });

      if (_stagePairs == _config.pairCount) {
        await Future<void>.delayed(const Duration(milliseconds: 520));
        if (mounted && !_finished) _completeStage();
      } else if (_shouldShuffle) {
        await _shuffleHiddenCards();
      } else {
        await Future<void>.delayed(const Duration(milliseconds: 420));
        if (mounted) setState(() => _locked = false);
      }
      return;
    }

    _combo = 0;
    _stageMisses++;
    setState(() {
      _feedback = 'TRY AGAIN — you have seen both cards!';
      _feedbackColor = MemoryColors.yellow;
    });
    await Future<void>.delayed(const Duration(milliseconds: 720));
    if (!mounted || _finished) return;
    setState(() {
      _cards[firstIndex] = _cards[firstIndex].copyWith(isRevealed: false);
      _cards[secondIndex] = _cards[secondIndex].copyWith(isRevealed: false);
      _firstIndex = null;
      _firstRevealEpochMs = null;
      _locked = false;
    });
  }

  bool get _shouldShuffle =>
      !_stageShuffled &&
      _config.modifier == 'Shuffle' &&
      _stagePairs >= _config.pairCount ~/ 2;

  Future<void> _shuffleHiddenCards() async {
    _stageShuffled = true;
    setState(() {
      _feedback = '🔀 BOARD SHUFFLE! Watch carefully…';
      _feedbackColor = MemoryColors.purple;
    });
    await Future<void>.delayed(const Duration(milliseconds: 850));
    if (!mounted || _finished) return;
    final hidden = _cards.where((card) => !card.isMatched).toList()
      ..shuffle(_random);
    var hiddenIndex = 0;
    setState(() {
      for (var index = 0; index < _cards.length; index++) {
        if (_cards[index].isMatched) continue;
        _cards[index] = MemoryCardData(
          id: _cards[index].id,
          symbol: hidden[hiddenIndex++].symbol,
        );
      }
      _feedback = 'Cards moved! Keep your focus.';
      _locked = false;
    });
  }

  Future<void> _completeStage() async {
    final completionMs = _elapsedActiveMs - _stageStartedElapsedMs;
    if (_fastestStageMs == 0 || completionMs < _fastestStageMs) {
      _fastestStageMs = completionMs;
    }
    final perfect = _stageMisses == 0;
    final scoreBonus = MemoryScoring.stageClearScore(
      stage: _stage,
      remainingTimeMs: _remainingMs,
      pairs: _stagePairs,
      moves: _stageMoves,
      completionMs: completionMs,
      perfect: perfect,
    );
    final timeBonus = MemoryScoring.timeBonusMs(
      config: _config,
      pairs: _stagePairs,
      moves: _stageMoves,
    );
    setState(() {
      _locked = true;
      _stageClear = _StageClearData(
        pairs: _stagePairs,
        moves: _stageMoves,
        accuracy: (_stagePairs / _stageMoves * 100).round(),
        perfect: perfect,
        bonusSeconds: timeBonus ~/ 1000,
        scoreBonus: scoreBonus,
      );
    });
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (!mounted || _finished) return;
    setState(() {
      _score += scoreBonus;
      _remainingMs += timeBonus;
      _stage++;
      _stageClear = null;
      _locked = false;
      _feedback = 'New board, new memory challenge!';
      _feedbackColor = MemoryColors.cyan;
      _prepareStage();
      _lastTickMs = _nowMs();
    });
  }

  void _resume() {
    setState(() {
      _paused = false;
      _lastTickMs = _nowMs();
    });
  }

  void _finish() {
    if (_finished) return;
    _finished = true;
    _ticker?.cancel();
    widget.onComplete(
      MemorySession.completed(
        player: widget.player,
        score: _score,
        stageReached: _stage,
        pairsFound: _pairsFound,
        moves: _moves,
        bestCombo: _bestCombo,
        remainingTimeMs: _remainingMs,
        fastestStageMs: _fastestStageMs,
        durationMs: max(1000, _elapsedActiveMs),
        startedAt: _startedAt,
      ),
    );
  }

  String _time(int milliseconds) {
    final seconds = milliseconds / 1000;
    return seconds.toStringAsFixed(seconds < 10 ? 1 : 0);
  }
}

class _HudTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool urgent;

  const _HudTile({
    required this.label,
    required this.value,
    required this.color,
    this.urgent = false,
  });

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: urgent ? 0.17 : 0.09),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white54,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 3),
            FittedBox(
              child: Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ),
          ],
        ),
      );
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
        ),
      );
}

class _GameOverlay extends StatelessWidget {
  final String emoji;
  final String title;
  final String message;
  final String? buttonLabel;
  final VoidCallback? onPressed;

  const _GameOverlay({
    required this.emoji,
    required this.title,
    required this.message,
    this.buttonLabel,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) => Positioned.fill(
        child: ColoredBox(
          color: MemoryColors.background.withValues(alpha: 0.93),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: MemoryPanel(
                  borderColor: MemoryColors.cyan.withValues(alpha: 0.4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 48)),
                      const SizedBox(height: 12),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(color: Colors.white60, height: 1.5),
                      ),
                      if (buttonLabel != null) ...[
                        const SizedBox(height: 20),
                        MemoryPrimaryButton(
                          label: buttonLabel!,
                          onPressed: onPressed,
                          icon: Icons.play_arrow_rounded,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

class _StageClearData {
  final int pairs;
  final int moves;
  final int accuracy;
  final bool perfect;
  final int bonusSeconds;
  final int scoreBonus;

  const _StageClearData({
    required this.pairs,
    required this.moves,
    required this.accuracy,
    required this.perfect,
    required this.bonusSeconds,
    required this.scoreBonus,
  });
}
