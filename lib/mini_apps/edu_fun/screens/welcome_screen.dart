import 'package:flutter/material.dart';
import 'package:logic_lab/mini_apps/edu_fun/widgets/edu_components.dart';

class EduWelcomeScreen extends StatelessWidget {
  final VoidCallback onPlay;
  final VoidCallback onLeaderboard;

  const EduWelcomeScreen({
    super.key,
    required this.onPlay,
    required this.onLeaderboard,
  });

  @override
  Widget build(BuildContext context) {
    return EduScreen(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const _BrainHero(),
          const SizedBox(height: 30),
          const EduSectionTitle(
            eyebrow: 'NUMBER ADVENTURE',
            title: 'Train Your Number Brain! 🧠⭐',
            subtitle:
                'Solve 10 fun math and logic challenges, collect stars, and become a Number Champion.',
          ),
          const SizedBox(height: 34),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              children: [
                EduPrimaryButton(
                  label: 'START PLAYING',
                  onPressed: onPlay,
                  icon: Icons.rocket_launch_rounded,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onLeaderboard,
                    icon: const Icon(Icons.emoji_events_rounded),
                    label: const Text('View Leaderboard'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: EduColors.purple),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: const [
              _FeatureChip('🎯 Ages 5–7'),
              _FeatureChip('⭐ 10 Challenges'),
              _FeatureChip('🏆 Beat Your Best'),
            ],
          ),
        ],
      ),
    );
  }
}

class _BrainHero extends StatelessWidget {
  const _BrainHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [EduColors.pink, EduColors.purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: EduColors.pink.withValues(alpha: 0.28),
            blurRadius: 45,
            spreadRadius: 4,
          ),
        ],
      ),
      child: const Stack(
        alignment: Alignment.center,
        children: [
          Text('🧠', style: TextStyle(fontSize: 72)),
          Positioned(
              top: 10,
              right: 17,
              child: Text('⭐', style: TextStyle(fontSize: 26))),
          Positioned(
              bottom: 13,
              left: 11,
              child: Text('+',
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: EduColors.yellow))),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final String label;
  const _FeatureChip(this.label);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: Colors.white12),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
        ),
      );
}
