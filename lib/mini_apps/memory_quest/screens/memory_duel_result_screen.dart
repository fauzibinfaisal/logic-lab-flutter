import 'package:flutter/material.dart';
import 'package:logic_lab/mini_apps/memory_quest/models/memory_models.dart';
import 'package:logic_lab/mini_apps/memory_quest/widgets/memory_components.dart';

class MemoryDuelResultScreen extends StatelessWidget {
  final DuelResult result;
  final VoidCallback onRematch;
  final VoidCallback onHome;

  const MemoryDuelResultScreen({
    super.key,
    required this.result,
    required this.onRematch,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) => MemoryScreen(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🏆 ✨ 🎴', style: TextStyle(fontSize: 46)),
            const SizedBox(height: 13),
            MemoryTitle(
              eyebrow: result.usedTiebreaker
                  ? 'TIEBREAKER CHAMPION'
                  : 'DUEL COMPLETE',
              title: '${result.winner.toUpperCase()} WINS!',
              subtitle:
                  'More pairs means victory. Great memory from both players!',
            ),
            const SizedBox(height: 24),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: MemoryPanel(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _DuelPlayerResult(
                            name: result.playerOne,
                            pairs: result.playerOnePairs,
                            streak: result.playerOneBestStreak,
                            fastestMs: result.playerOneFastestMatchMs,
                            winner: result.winner == result.playerOne,
                            color: MemoryColors.cyan,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _DuelPlayerResult(
                            name: result.playerTwo,
                            pairs: result.playerTwoPairs,
                            streak: result.playerTwoBestStreak,
                            fastestMs: result.playerTwoFastestMatchMs,
                            winner: result.winner == result.playerTwo,
                            color: MemoryColors.pink,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    MemoryPrimaryButton(
                      label: 'REMATCH',
                      onPressed: onRematch,
                      icon: Icons.replay_rounded,
                      color: MemoryColors.cyan,
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                        onPressed: onHome, child: const Text('Back to Home')),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}

class _DuelPlayerResult extends StatelessWidget {
  final String name;
  final int pairs;
  final int streak;
  final int fastestMs;
  final bool winner;
  final Color color;

  const _DuelPlayerResult({
    required this.name,
    required this.pairs,
    required this.streak,
    required this.fastestMs,
    required this.winner,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: winner ? 0.15 : 0.06),
          borderRadius: BorderRadius.circular(18),
          border:
              Border.all(color: color.withValues(alpha: winner ? 0.6 : 0.2)),
        ),
        child: Column(
          children: [
            Text(winner ? '👑' : '🧠', style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 6),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 8),
            Text('$pairs pairs',
                style: TextStyle(color: color, fontWeight: FontWeight.w900)),
            Text('Best streak ×$streak',
                style: const TextStyle(color: Colors.white54)),
            Text(
              fastestMs == 0
                  ? 'Fastest —'
                  : 'Fastest ${(fastestMs / 1000).toStringAsFixed(1)}s',
              style: const TextStyle(color: Colors.white54),
            ),
          ],
        ),
      );
}
