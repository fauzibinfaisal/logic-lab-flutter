import 'package:flutter/material.dart';
import 'package:logic_lab/mini_apps/edu_fun/data/edu_fun_repository.dart';
import 'package:logic_lab/mini_apps/edu_fun/data/leaderboard_repository.dart';
import 'package:logic_lab/mini_apps/edu_fun/models/edu_fun_models.dart';
import 'package:logic_lab/mini_apps/edu_fun/screens/game_screen.dart';
import 'package:logic_lab/mini_apps/edu_fun/screens/home_screen.dart';
import 'package:logic_lab/mini_apps/edu_fun/screens/leaderboard_screen.dart';
import 'package:logic_lab/mini_apps/edu_fun/screens/profile_screen.dart';
import 'package:logic_lab/mini_apps/edu_fun/screens/results_screen.dart';
import 'package:logic_lab/mini_apps/edu_fun/screens/welcome_screen.dart';
import 'package:logic_lab/mini_apps/edu_fun/widgets/edu_components.dart';
import 'package:logic_lab/visit_counter/widgets/visit_count_badge.dart';

enum _EduView { loading, welcome, profile, home, game, results, leaderboard }

class EduFunPage extends StatefulWidget {
  final EduFunRepository? progressRepository;
  final LeaderboardRepository? leaderboardRepository;
  final int? visitCount;
  final bool visitCountLoading;

  const EduFunPage({
    super.key,
    this.progressRepository,
    this.leaderboardRepository,
    this.visitCount,
    this.visitCountLoading = false,
  });

  @override
  State<EduFunPage> createState() => _EduFunPageState();
}

class _EduFunPageState extends State<EduFunPage> {
  late final EduFunRepository _progressRepository;
  late final LeaderboardRepository _leaderboardRepository;

  _EduView _view = _EduView.loading;
  _EduView _leaderboardBackView = _EduView.welcome;
  EduPlayer? _player;
  PlayerStats _stats = PlayerStats.empty;
  EduSession? _result;
  int _previousBest = 0;
  int _gameNumber = 0;
  ScoreSubmissionState _submissionState = ScoreSubmissionState.loading;

  @override
  void initState() {
    super.initState();
    _progressRepository = widget.progressRepository ?? EduFunRepository();
    _leaderboardRepository =
        widget.leaderboardRepository ?? LeaderboardRepository();
    _loadPlayer();
  }

  @override
  void dispose() {
    if (widget.leaderboardRepository == null) {
      _leaderboardRepository.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EduColors.background,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.2,
            colors: [Color(0xFF2B1958), EduColors.background],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _EduTopBar(
                age: _player?.age,
                visitCount: widget.visitCount,
                visitCountLoading: widget.visitCountLoading,
                onExit: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  child: KeyedSubtree(
                    key: ValueKey('${_view.name}-$_gameNumber'),
                    child: _buildScreen(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScreen() => switch (_view) {
        _EduView.loading => const Center(
            child: CircularProgressIndicator(color: EduColors.yellow),
          ),
        _EduView.welcome => EduWelcomeScreen(
            onPlay: () => setState(() => _view = _EduView.profile),
            onLeaderboard: _showLeaderboard,
          ),
        _EduView.profile => EduProfileScreen(
            initialPlayer: _player,
            onContinue: _savePlayerAndStart,
          ),
        _EduView.home => EduHomeScreen(
            player: _player!,
            stats: _stats,
            onPlay: _startGame,
            onLeaderboard: _showLeaderboard,
            onChangePlayer: () => setState(() => _view = _EduView.profile),
          ),
        _EduView.game => EduGameScreen(
            player: _player!,
            onComplete: _completeGame,
          ),
        _EduView.results => EduResultsScreen(
            session: _result!,
            previousBest: _previousBest,
            submissionState: _submissionState,
            onLeaderboard: _showLeaderboard,
            onPlayAgain: _startGame,
            onHome: _showHome,
          ),
        _EduView.leaderboard => EduLeaderboardScreen(
            repository: _leaderboardRepository,
            initialAge: _player?.age ?? 6,
            currentNickname: _player?.nickname,
            onBack: _closeLeaderboard,
          ),
      };

  Future<void> _loadPlayer() async {
    final player = await _progressRepository.loadPlayer();
    final stats = player == null
        ? PlayerStats.empty
        : await _progressRepository.statsFor(player);
    if (!mounted) return;
    setState(() {
      _player = player;
      _stats = stats;
      _view = player == null ? _EduView.welcome : _EduView.home;
    });
  }

  Future<void> _savePlayerAndStart(EduPlayer player) async {
    await _progressRepository.savePlayer(player);
    if (!mounted) return;
    setState(() {
      _player = player;
      _stats = PlayerStats.empty;
    });
    _startGame();
  }

  void _startGame() {
    setState(() {
      _gameNumber++;
      _view = _EduView.game;
    });
  }

  Future<void> _completeGame(EduSession session) async {
    _previousBest = _stats.bestScore;
    setState(() {
      _result = session;
      _submissionState = ScoreSubmissionState.loading;
      _view = _EduView.results;
    });

    await _progressRepository.saveSession(session);
    final updatedStats = await _progressRepository.statsFor(session.player);
    try {
      await _leaderboardRepository.submitSession(session);
      if (!mounted) return;
      setState(() {
        _stats = updatedStats;
        _submissionState = ScoreSubmissionState.success;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _stats = updatedStats;
        _submissionState = ScoreSubmissionState.error;
      });
    }
  }

  void _showLeaderboard() {
    setState(() {
      _leaderboardBackView = _view == _EduView.leaderboard
          ? (_player == null ? _EduView.welcome : _EduView.home)
          : _view;
      _view = _EduView.leaderboard;
    });
  }

  void _closeLeaderboard() {
    setState(() {
      _view = _leaderboardBackView == _EduView.game
          ? _EduView.home
          : _leaderboardBackView;
    });
  }

  void _showHome() => setState(() => _view = _EduView.home);
}

class _EduTopBar extends StatelessWidget {
  final int? age;
  final int? visitCount;
  final bool visitCountLoading;
  final VoidCallback onExit;

  const _EduTopBar({
    required this.age,
    required this.visitCount,
    required this.visitCountLoading,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: EduColors.background.withValues(alpha: 0.9),
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
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: EduColors.yellow.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Text('🧠', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'NUMBER ADVENTURE',
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
            ),
          ),
          VisitCountBadge(
            count: visitCount,
            loading: visitCountLoading,
            color: EduColors.yellow,
            compact: true,
          ),
          if (age != null)
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: EduColors.cyan.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  'AGE $age',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: EduColors.cyan,
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
