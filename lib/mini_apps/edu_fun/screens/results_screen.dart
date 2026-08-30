import 'package:flutter/material.dart';
import 'package:logic_lab/mini_apps/edu_fun/models/edu_fun_models.dart';
import 'package:logic_lab/mini_apps/edu_fun/widgets/edu_components.dart';

class EduResultsScreen extends StatelessWidget {
  final EduSession session;
  final int previousBest;
  final ScoreSubmissionState submissionState;
  final VoidCallback onLeaderboard;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  const EduResultsScreen({
    super.key,
    required this.session,
    required this.previousBest,
    required this.submissionState,
    required this.onLeaderboard,
    required this.onPlayAgain,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    final perfect = session.correct == 10;
    final isNewBest = session.score > previousBest;
    final tt = Theme.of(context).textTheme;

    return EduScreen(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            perfect ? '🏆 ⭐ 🎉' : '⭐ 🚀 ⭐',
            style: const TextStyle(fontSize: 45),
          ),
          const SizedBox(height: 14),
          EduSectionTitle(
            eyebrow: perfect
                ? 'NUMBER MASTER'
                : isNewBest
                    ? 'NEW BEST SCORE!'
                    : 'ADVENTURE COMPLETE',
            title: perfect
                ? 'PERFECT, ${session.player.nickname}!'
                : 'Amazing, ${session.player.nickname}!',
            subtitle: isNewBest
                ? 'You beat your previous best by ${session.score - previousBest} points.'
                : 'Great thinking! Every adventure makes your number brain stronger.',
          ),
          const SizedBox(height: 28),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: EduPanel(
              borderColor: EduColors.yellow.withValues(alpha: 0.4),
              child: Column(
                children: [
                  Text(
                    'YOUR SCORE',
                    style: tt.labelMedium?.copyWith(
                      color: Colors.white54,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '⭐ ${session.score}',
                    style: tt.displayMedium?.copyWith(
                      color: EduColors.yellow,
                      fontWeight: FontWeight.w900,
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
                          SizedBox(
                            width: width,
                            child: EduStatTile(
                              emoji: '🎯',
                              label: 'Correct',
                              value: '${session.correct} / 10',
                              color: EduColors.cyan,
                            ),
                          ),
                          SizedBox(
                            width: width,
                            child: EduStatTile(
                              emoji: '💯',
                              label: 'Accuracy',
                              value: '${(session.accuracy * 100).round()}%',
                              color: EduColors.green,
                            ),
                          ),
                          SizedBox(
                            width: width,
                            child: EduStatTile(
                              emoji: '🔥',
                              label: 'Best Streak',
                              value: '${session.bestStreak}',
                              color: EduColors.pink,
                            ),
                          ),
                          SizedBox(
                            width: width,
                            child: EduStatTile(
                              emoji: '⏱️',
                              label: 'Time',
                              value: _duration(session.durationSeconds),
                              color: EduColors.purple,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  _SubmissionNotice(state: submissionState),
                  const SizedBox(height: 20),
                  EduPrimaryButton(
                    label: 'BEAT MY SCORE',
                    onPressed: onPlayAgain,
                    icon: Icons.replay_rounded,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onLeaderboard,
                      icon: const Icon(Icons.emoji_events_rounded),
                      label: const Text('SEE LEADERBOARD'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        side: const BorderSide(color: EduColors.purple),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(onPressed: onHome, child: const Text('Back to Home')),
        ],
      ),
    );
  }

  String _duration(int seconds) =>
      '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
}

class _SubmissionNotice extends StatelessWidget {
  final ScoreSubmissionState state;
  const _SubmissionNotice({required this.state});

  @override
  Widget build(BuildContext context) {
    final (icon, label, color) = switch (state) {
      ScoreSubmissionState.loading => (
          Icons.cloud_upload_outlined,
          'Sending score to the leaderboard…',
          EduColors.cyan,
        ),
      ScoreSubmissionState.success => (
          Icons.cloud_done_rounded,
          'Score added to the leaderboard!',
          EduColors.green,
        ),
      ScoreSubmissionState.error => (
          Icons.cloud_off_rounded,
          'Score saved on this device. Leaderboard sync is unavailable.',
          EduColors.pink,
        ),
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          if (state == ScoreSubmissionState.loading)
            const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                    height: 1.35,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
