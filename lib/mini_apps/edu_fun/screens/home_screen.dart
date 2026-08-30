import 'package:flutter/material.dart';
import 'package:logic_lab/mini_apps/edu_fun/models/edu_fun_models.dart';
import 'package:logic_lab/mini_apps/edu_fun/widgets/edu_components.dart';

class EduHomeScreen extends StatelessWidget {
  final EduPlayer player;
  final PlayerStats stats;
  final VoidCallback onPlay;
  final VoidCallback onLeaderboard;
  final VoidCallback onChangePlayer;

  const EduHomeScreen({
    super.key,
    required this.player,
    required this.stats,
    required this.onPlay,
    required this.onLeaderboard,
    required this.onChangePlayer,
  });

  @override
  Widget build(BuildContext context) {
    return EduScreen(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          EduSectionTitle(
            eyebrow: 'WELCOME BACK',
            title: 'Hi, ${player.nickname}! 👋',
            subtitle: 'Age ${player.age} · Ready for another Number Adventure?',
          ),
          const SizedBox(height: 28),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: EduPanel(
              child: Column(
                children: [
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
                              emoji: '⭐',
                              label: 'Best Score',
                              value: '${stats.bestScore}',
                              color: EduColors.yellow,
                            ),
                          ),
                          SizedBox(
                            width: width,
                            child: EduStatTile(
                              emoji: '🎯',
                              label: 'Best Accuracy',
                              value: '${(stats.bestAccuracy * 100).round()}%',
                              color: EduColors.cyan,
                            ),
                          ),
                          SizedBox(
                            width: width,
                            child: EduStatTile(
                              emoji: '🔥',
                              label: 'Best Streak',
                              value: '${stats.bestStreak}',
                              color: EduColors.pink,
                            ),
                          ),
                          SizedBox(
                            width: width,
                            child: EduStatTile(
                              emoji: '🚀',
                              label: 'Games Played',
                              value: '${stats.gamesPlayed}',
                              color: EduColors.purple,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 22),
                  EduPrimaryButton(
                    label: 'PLAY AGAIN',
                    onPressed: onPlay,
                    icon: Icons.play_arrow_rounded,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onLeaderboard,
                      icon: const Icon(Icons.emoji_events_rounded),
                      label: const Text('Leaderboard'),
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
          const SizedBox(height: 18),
          TextButton(
            onPressed: onChangePlayer,
            child: Text('Not ${player.nickname}? Change Player'),
          ),
        ],
      ),
    );
  }
}
