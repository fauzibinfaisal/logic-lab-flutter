import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:logic_lab/mini_apps/memory_quest/logic/memory_engine.dart';
import 'package:logic_lab/mini_apps/memory_quest/models/memory_models.dart';
import 'package:logic_lab/mini_apps/memory_quest/widgets/memory_components.dart';

class MemoryDuelGameScreen extends StatefulWidget {
  final String playerOne;
  final String playerTwo;
  final ValueChanged<DuelResult> onComplete;
  final Random? random;

  const MemoryDuelGameScreen({
    super.key,
    required this.playerOne,
    required this.playerTwo,
    required this.onComplete,
    this.random,
  });

  @override
  State<MemoryDuelGameScreen> createState() => _MemoryDuelGameScreenState();
}

class _MemoryDuelGameScreenState extends State<MemoryDuelGameScreen> {
  late final Random _random;
  late List<MemoryCardData> _cards;
  int _columns = 4;
  int _activePlayer = 0;
  int _playerOnePairs = 0;
  int _playerTwoPairs = 0;
  int _playerOneStreak = 0;
  int _playerTwoStreak = 0;
  int _playerOneBestStreak = 0;
  int _playerTwoBestStreak = 0;
  int _playerOneFastestMs = 0;
  int _playerTwoFastestMs = 0;
  int _tiebreakOne = 0;
  int _tiebreakTwo = 0;
  int? _firstIndex;
  int? _firstRevealMs;
  bool _locked = true;
  bool _tiebreaker = false;
  bool _finished = false;
  String _message = 'Choosing first player…';
  Color _messageColor = MemoryColors.cyan;

  String get _activeName =>
      _activePlayer == 0 ? widget.playerOne : widget.playerTwo;

  @override
  void initState() {
    super.initState();
    _random = widget.random ?? Random();
    _cards = MemoryBoardFactory.duelBoard(random: _random);
    _activePlayer = _random.nextBool() ? 0 : 1;
    Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() {
        _locked = false;
        _message = '${_activeName.toUpperCase()} STARTS!';
      });
    });
  }

  @override
  Widget build(BuildContext context) => MemoryScreen(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 40),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _PlayerScore(
                    name: widget.playerOne,
                    pairs: _playerOnePairs,
                    active: _activePlayer == 0,
                    color: MemoryColors.cyan,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'VS',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white38,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
                Expanded(
                  child: _PlayerScore(
                    name: widget.playerTwo,
                    pairs: _playerTwoPairs,
                    active: _activePlayer == 1,
                    color: MemoryColors.pink,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: _messageColor.withValues(alpha: 0.11),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: _messageColor.withValues(alpha: 0.25),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    _tiebreaker
                        ? '⚡ TIEBREAKER'
                        : "👉 ${_activeName.toUpperCase()}'S TURN",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: _messageColor,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.white60),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            MemoryBoard(
              cards: _cards,
              columns: _columns,
              locked: _locked,
              onCardTap: _tapCard,
            ),
            const SizedBox(height: 13),
            Text(
              'Match = keep your turn · Miss = pass to your friend',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.white38),
            ),
          ],
        ),
      );

  void _tapCard(int index) {
    if (_locked ||
        _finished ||
        _cards[index].isMatched ||
        _firstIndex == index) {
      return;
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    setState(() {
      _cards[index] = _cards[index].copyWith(isRevealed: true);
      if (_firstIndex == null) {
        _firstIndex = index;
        _firstRevealMs = now;
        _message = 'Find the matching card!';
      } else {
        _locked = true;
      }
    });
    if (_locked) _resolve(index, now);
  }

  Future<void> _resolve(int secondIndex, int now) async {
    final firstIndex = _firstIndex!;
    final matched = _cards[firstIndex].symbol == _cards[secondIndex].symbol;
    final gap = now - (_firstRevealMs ?? now);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!mounted || _finished) return;

    if (matched) {
      setState(() {
        _cards[firstIndex] =
            _cards[firstIndex].copyWith(isMatched: true, isRevealed: true);
        _cards[secondIndex] =
            _cards[secondIndex].copyWith(isMatched: true, isRevealed: true);
        _recordMatch(gap);
        _message = 'MATCH! ${_activeName.toUpperCase()} PLAYS AGAIN';
        _messageColor = MemoryColors.green;
        _firstIndex = null;
        _firstRevealMs = null;
      });

      if (_tiebreaker && (_tiebreakOne >= 2 || _tiebreakTwo >= 2)) {
        await Future<void>.delayed(const Duration(milliseconds: 650));
        _finish();
        return;
      }
      if (_cards.every((card) => card.isMatched)) {
        await Future<void>.delayed(const Duration(milliseconds: 650));
        if (_playerOnePairs == _playerTwoPairs) {
          _startTiebreaker();
        } else {
          _finish();
        }
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 420));
      if (mounted) setState(() => _locked = false);
      return;
    }

    setState(() {
      if (_activePlayer == 0) {
        _playerOneStreak = 0;
      } else {
        _playerTwoStreak = 0;
      }
      _message = 'No match — pass to ${_otherName()}';
      _messageColor = MemoryColors.yellow;
    });
    await Future<void>.delayed(const Duration(milliseconds: 760));
    if (!mounted || _finished) return;
    setState(() {
      _cards[firstIndex] = _cards[firstIndex].copyWith(isRevealed: false);
      _cards[secondIndex] = _cards[secondIndex].copyWith(isRevealed: false);
      _activePlayer = 1 - _activePlayer;
      _firstIndex = null;
      _firstRevealMs = null;
      _locked = false;
      _message = '${_activeName.toUpperCase()}, your turn!';
      _messageColor =
          _activePlayer == 0 ? MemoryColors.cyan : MemoryColors.pink;
    });
  }

  void _recordMatch(int gap) {
    if (_activePlayer == 0) {
      _playerOnePairs++;
      _playerOneStreak++;
      _playerOneBestStreak = max(_playerOneBestStreak, _playerOneStreak);
      if (_playerOneFastestMs == 0 || gap < _playerOneFastestMs) {
        _playerOneFastestMs = gap;
      }
      if (_tiebreaker) _tiebreakOne++;
    } else {
      _playerTwoPairs++;
      _playerTwoStreak++;
      _playerTwoBestStreak = max(_playerTwoBestStreak, _playerTwoStreak);
      if (_playerTwoFastestMs == 0 || gap < _playerTwoFastestMs) {
        _playerTwoFastestMs = gap;
      }
      if (_tiebreaker) _tiebreakTwo++;
    }
  }

  String _otherName() =>
      _activePlayer == 0 ? widget.playerTwo : widget.playerOne;

  void _startTiebreaker() {
    setState(() {
      _tiebreaker = true;
      _columns = 3;
      _cards = MemoryBoardFactory.duelBoard(tiebreaker: true, random: _random);
      _tiebreakOne = 0;
      _tiebreakTwo = 0;
      _locked = false;
      _activePlayer = _random.nextBool() ? 0 : 1;
      _message = 'First player to find 2 pairs wins!';
      _messageColor = MemoryColors.purple;
    });
  }

  void _finish() {
    if (_finished) return;
    _finished = true;
    final winner =
        _playerOnePairs > _playerTwoPairs ? widget.playerOne : widget.playerTwo;
    widget.onComplete(
      DuelResult(
        playerOne: widget.playerOne,
        playerTwo: widget.playerTwo,
        playerOnePairs: _playerOnePairs,
        playerTwoPairs: _playerTwoPairs,
        playerOneBestStreak: _playerOneBestStreak,
        playerTwoBestStreak: _playerTwoBestStreak,
        playerOneFastestMatchMs: _playerOneFastestMs,
        playerTwoFastestMatchMs: _playerTwoFastestMs,
        winner: winner,
        usedTiebreaker: _tiebreaker,
      ),
    );
  }
}

class _PlayerScore extends StatelessWidget {
  final String name;
  final int pairs;
  final bool active;
  final Color color;

  const _PlayerScore({
    required this.name,
    required this.pairs,
    required this.active,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: color.withValues(alpha: active ? 0.16 : 0.06),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: color.withValues(alpha: active ? 0.65 : 0.18),
            width: active ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 3),
            Text(
              '$pairs pairs',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ],
        ),
      );
}
