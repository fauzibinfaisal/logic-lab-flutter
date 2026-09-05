import 'package:flutter/material.dart';
import 'package:logic_lab/mini_apps/memory_quest/data/memory_leaderboard_repository.dart';
import 'package:logic_lab/mini_apps/memory_quest/data/memory_repository.dart';
import 'package:logic_lab/mini_apps/memory_quest/models/memory_models.dart';
import 'package:logic_lab/mini_apps/memory_quest/screens/memory_duel_game_screen.dart';
import 'package:logic_lab/mini_apps/memory_quest/screens/memory_duel_result_screen.dart';
import 'package:logic_lab/mini_apps/memory_quest/screens/memory_home_screen.dart';
import 'package:logic_lab/mini_apps/memory_quest/screens/memory_leaderboard_screen.dart';
import 'package:logic_lab/mini_apps/memory_quest/screens/memory_setup_screens.dart';
import 'package:logic_lab/mini_apps/memory_quest/screens/memory_solo_game_screen.dart';
import 'package:logic_lab/mini_apps/memory_quest/screens/memory_solo_result_screen.dart';
import 'package:logic_lab/mini_apps/memory_quest/widgets/memory_components.dart';

enum _MemoryView {
  loading,
  home,
  soloSetup,
  soloGame,
  soloResult,
  leaderboard,
  duelSetup,
  duelGame,
  duelResult,
}

class MemoryQuestPage extends StatefulWidget {
  final MemoryRepository? progressRepository;
  final MemoryLeaderboardRepository? leaderboardRepository;

  const MemoryQuestPage({
    super.key,
    this.progressRepository,
    this.leaderboardRepository,
  });

  @override
  State<MemoryQuestPage> createState() => _MemoryQuestPageState();
}

class _MemoryQuestPageState extends State<MemoryQuestPage> {
  late final MemoryRepository _progressRepository;
  late final MemoryLeaderboardRepository _leaderboardRepository;

  _MemoryView _view = _MemoryView.loading;
  _MemoryView _leaderboardBackView = _MemoryView.home;
  MemoryPlayer? _player;
  MemoryPlayerStats _stats = MemoryPlayerStats.empty;
  MemorySession? _soloResult;
  DuelResult? _duelResult;
  int _previousBest = 0;
  int _gameKey = 0;
  String _duelOne = '';
  String _duelTwo = '';
  MemorySubmissionState _submissionState = MemorySubmissionState.loading;

  @override
  void initState() {
    super.initState();
    _progressRepository = widget.progressRepository ?? MemoryRepository();
    _leaderboardRepository =
        widget.leaderboardRepository ?? MemoryLeaderboardRepository();
    _loadProgress();
  }

  @override
  void dispose() {
    if (widget.leaderboardRepository == null) {
      _leaderboardRepository.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: MemoryColors.background,
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topRight,
              radius: 1.3,
              colors: [Color(0xFF173E67), MemoryColors.background],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _MemoryTopBar(onExit: () => Navigator.of(context).pop()),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 230),
                    child: KeyedSubtree(
                      key: ValueKey('${_view.name}-$_gameKey'),
                      child: _screen(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _screen() => switch (_view) {
        _MemoryView.loading => const Center(
            child: CircularProgressIndicator(color: MemoryColors.cyan),
          ),
        _MemoryView.home => MemoryHomeScreen(
            player: _player,
            stats: _stats,
            onSolo: _player == null
                ? () => setState(() => _view = _MemoryView.soloSetup)
                : _startSolo,
            onDuel: () => setState(() => _view = _MemoryView.duelSetup),
            onLeaderboard: _showLeaderboard,
            onChangePlayer: () => setState(() => _view = _MemoryView.soloSetup),
          ),
        _MemoryView.soloSetup => MemorySoloSetupScreen(
            initialPlayer: _player,
            onStart: _savePlayerAndStart,
            onBack: _showHome,
          ),
        _MemoryView.soloGame => MemorySoloGameScreen(
            player: _player!,
            onComplete: _completeSolo,
          ),
        _MemoryView.soloResult => MemorySoloResultScreen(
            session: _soloResult!,
            previousBest: _previousBest,
            submissionState: _submissionState,
            onPlayAgain: _startSolo,
            onLeaderboard: _showLeaderboard,
            onHome: _showHome,
          ),
        _MemoryView.leaderboard => MemoryLeaderboardScreen(
            repository: _leaderboardRepository,
            currentNickname: _player?.nickname,
            onBack: _closeLeaderboard,
          ),
        _MemoryView.duelSetup => MemoryDuelSetupScreen(
            suggestedPlayerOne: _player?.nickname,
            onStart: _startDuel,
            onBack: _showHome,
          ),
        _MemoryView.duelGame => MemoryDuelGameScreen(
            playerOne: _duelOne,
            playerTwo: _duelTwo,
            onComplete: (result) => setState(() {
              _duelResult = result;
              _view = _MemoryView.duelResult;
            }),
          ),
        _MemoryView.duelResult => MemoryDuelResultScreen(
            result: _duelResult!,
            onRematch: () => _startDuel(_duelOne, _duelTwo),
            onHome: _showHome,
          ),
      };

  Future<void> _loadProgress() async {
    final player = await _progressRepository.loadPlayer();
    final stats = player == null
        ? MemoryPlayerStats.empty
        : await _progressRepository.statsFor(player);
    if (!mounted) return;
    setState(() {
      _player = player;
      _stats = stats;
      _view = _MemoryView.home;
    });
  }

  Future<void> _savePlayerAndStart(MemoryPlayer player) async {
    await _progressRepository.savePlayer(player);
    final stats = await _progressRepository.statsFor(player);
    if (!mounted) return;
    setState(() {
      _player = player;
      _stats = stats;
    });
    _startSolo();
  }

  void _startSolo() => setState(() {
        _gameKey++;
        _view = _MemoryView.soloGame;
      });

  Future<void> _completeSolo(MemorySession session) async {
    _previousBest = _stats.bestScore;
    setState(() {
      _soloResult = session;
      _submissionState = MemorySubmissionState.loading;
      _view = _MemoryView.soloResult;
    });

    await _progressRepository.saveSession(session);
    final stats = await _progressRepository.statsFor(session.player);
    try {
      await _leaderboardRepository.submit(session);
      if (!mounted) return;
      setState(() {
        _stats = stats;
        _submissionState = MemorySubmissionState.success;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _stats = stats;
        _submissionState = MemorySubmissionState.error;
      });
    }
  }

  void _startDuel(String one, String two) => setState(() {
        _duelOne = one;
        _duelTwo = two;
        _gameKey++;
        _view = _MemoryView.duelGame;
      });

  void _showLeaderboard() => setState(() {
        _leaderboardBackView =
            _view == _MemoryView.soloGame || _view == _MemoryView.duelGame
                ? _MemoryView.home
                : _view;
        _view = _MemoryView.leaderboard;
      });

  void _closeLeaderboard() => setState(() {
        _view = _leaderboardBackView == _MemoryView.leaderboard
            ? _MemoryView.home
            : _leaderboardBackView;
      });

  void _showHome() => setState(() => _view = _MemoryView.home);
}

class _MemoryTopBar extends StatelessWidget {
  final VoidCallback onExit;
  const _MemoryTopBar({required this.onExit});

  @override
  Widget build(BuildContext context) => Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: MemoryColors.background.withValues(alpha: 0.9),
          border: const Border(bottom: BorderSide(color: Colors.white10)),
        ),
        child: Row(
          children: [
            IconButton(
              tooltip: 'Back to Mini Apps',
              onPressed: onExit,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const SizedBox(width: 4),
            Container(
              width: 37,
              height: 37,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [MemoryColors.cyan, MemoryColors.purple],
                ),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Text('🧠', style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'MEMORY QUEST',
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: MemoryColors.cyan.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                'REMEMBER · MATCH · WIN',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: MemoryColors.cyan,
                      fontWeight: FontWeight.w900,
                      fontSize: 9,
                    ),
              ),
            ),
          ],
        ),
      );
}
