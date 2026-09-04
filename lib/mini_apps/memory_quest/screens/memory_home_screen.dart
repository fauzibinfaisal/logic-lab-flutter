import 'package:flutter/material.dart';
import 'package:logic_lab/mini_apps/memory_quest/models/memory_models.dart';
import 'package:logic_lab/mini_apps/memory_quest/widgets/memory_components.dart';

class MemoryHomeScreen extends StatelessWidget {
  final MemoryPlayer? player;
  final MemoryPlayerStats stats;
  final VoidCallback onSolo;
  final VoidCallback onDuel;
  final VoidCallback onLeaderboard;
  final VoidCallback onChangePlayer;

  const MemoryHomeScreen({
    super.key,
    required this.player,
    required this.stats,
    required this.onSolo,
    required this.onDuel,
    required this.onLeaderboard,
    required this.onChangePlayer,
  });

  @override
  Widget build(BuildContext context) {
    final returning = player != null;
    return MemoryScreen(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 126,
            height: 126,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [MemoryColors.cyan, MemoryColors.purple],
              ),
              boxShadow: [
                BoxShadow(
                  color: MemoryColors.cyan.withValues(alpha: 0.24),
                  blurRadius: 40,
                ),
              ],
            ),
            child: const Text('🧠', style: TextStyle(fontSize: 62)),
          ),
          const SizedBox(height: 24),
          MemoryTitle(
            eyebrow: returning
                ? 'WELCOME BACK, ${player!.nickname.toUpperCase()}!'
                : 'MEMORY QUEST',
            title: 'Remember. Match. Win.',
            subtitle: returning
                ? 'Your next memory adventure is ready.'
                : 'Train visual memory and focus—against the clock or a friend.',
          ),
          if (returning) ...[
            const SizedBox(height: 24),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 650),
              child: Row(
                children: [
                  Expanded(
                    child: MemoryStat(
                      emoji: '⭐',
                      label: 'Best Score',
                      value: compactScore(stats.bestScore),
                      color: MemoryColors.yellow,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: MemoryStat(
                      emoji: '🚀',
                      label: 'Best Stage',
                      value: '${stats.highestStage}',
                      color: MemoryColors.cyan,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: MemoryStat(
                      emoji: '🎴',
                      label: 'Pairs Found',
                      value: '${stats.totalPairs}',
                      color: MemoryColors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 28),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              children: [
                MemoryPrimaryButton(
                  label: returning
                      ? 'SOLO PLAY — BEAT YOUR BEST'
                      : 'SOLO PLAY — START ADVENTURE',
                  onPressed: onSolo,
                  icon: Icons.timer_rounded,
                ),
                const SizedBox(height: 11),
                MemoryPrimaryButton(
                  label: '2 PLAYER — CHALLENGE A FRIEND',
                  onPressed: onDuel,
                  icon: Icons.people_alt_rounded,
                  color: MemoryColors.cyan,
                ),
                const SizedBox(height: 11),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onLeaderboard,
                    icon: const Icon(Icons.emoji_events_rounded),
                    label: const Text('MEMORY CHAMPIONS'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: MemoryColors.purple),
                    ),
                  ),
                ),
                if (returning)
                  TextButton(
                    onPressed: onChangePlayer,
                    child: const Text('Change player'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
