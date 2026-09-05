import 'package:flutter/material.dart';
import 'package:logic_lab/mini_apps/memory_quest/models/memory_models.dart';
import 'package:logic_lab/mini_apps/memory_quest/widgets/memory_components.dart';

class MemorySoloResultScreen extends StatelessWidget {
  final MemorySession session;
  final int previousBest;
  final MemorySubmissionState submissionState;
  final VoidCallback onPlayAgain;
  final VoidCallback onLeaderboard;
  final VoidCallback onHome;

  const MemorySoloResultScreen({
    super.key,
    required this.session,
    required this.previousBest,
    required this.submissionState,
    required this.onPlayAgain,
    required this.onLeaderboard,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    final isBest = session.score > previousBest;
    return MemoryScreen(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('⏰ 🧠 ⭐', style: TextStyle(fontSize: 43)),
          const SizedBox(height: 14),
          MemoryTitle(
            eyebrow: isBest ? 'NEW BEST SCORE!' : "TIME'S UP!",
            title: 'Great memory, ${session.player.nickname}!',
            subtitle: isBest
                ? 'You improved your personal best by ${compactScore(session.score - previousBest)} points.'
                : 'Every board trains your focus. Ready for another run?',
          ),
          const SizedBox(height: 24),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 660),
            child: MemoryPanel(
              borderColor: MemoryColors.yellow.withValues(alpha: 0.4),
              child: Column(
                children: [
                  Text(
                    '⭐ ${compactScore(session.score)}',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: MemoryColors.yellow,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 18),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = (constraints.maxWidth - 10) / 2;
                      return Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          SizedBox(
                            width: width,
                            child: MemoryStat(
                              emoji: '🚀',
                              label: 'Stage Reached',
                              value: '${session.stageReached}',
                              color: MemoryColors.cyan,
                            ),
                          ),
                          SizedBox(
                            width: width,
                            child: MemoryStat(
                              emoji: '🎴',
                              label: 'Pairs Found',
                              value: '${session.pairsFound}',
                              color: MemoryColors.green,
                            ),
                          ),
                          SizedBox(
                            width: width,
                            child: MemoryStat(
                              emoji: '🎯',
                              label: 'Accuracy',
                              value: '${(session.accuracy * 100).round()}%',
                              color: MemoryColors.purple,
                            ),
                          ),
                          SizedBox(
                            width: width,
                            child: MemoryStat(
                              emoji: '🔥',
                              label: 'Best Combo',
                              value: '×${session.bestCombo}',
                              color: MemoryColors.pink,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  _SubmissionNotice(state: submissionState),
                  const SizedBox(height: 18),
                  MemoryPrimaryButton(
                    label: 'PLAY AGAIN',
                    onPressed: onPlayAgain,
                    icon: Icons.replay_rounded,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onLeaderboard,
                      icon: const Icon(Icons.emoji_events_rounded),
                      label: const Text('LEADERBOARD'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        side: const BorderSide(color: MemoryColors.purple),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: onHome, child: const Text('Back to Home')),
        ],
      ),
    );
  }
}

class _SubmissionNotice extends StatelessWidget {
  final MemorySubmissionState state;
  const _SubmissionNotice({required this.state});

  @override
  Widget build(BuildContext context) {
    final (icon, text, color) = switch (state) {
      MemorySubmissionState.loading => (
          Icons.cloud_upload_outlined,
          'Sending score to Memory Champions…',
          MemoryColors.cyan,
        ),
      MemorySubmissionState.success => (
          Icons.cloud_done_rounded,
          'Score added to Memory Champions!',
          MemoryColors.green,
        ),
      MemorySubmissionState.error => (
          Icons.cloud_off_rounded,
          'Saved on this device. Online leaderboard is unavailable.',
          MemoryColors.pink,
        ),
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          if (state == MemorySubmissionState.loading)
            const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}
