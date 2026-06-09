import 'package:flutter/material.dart';
import 'package:logic_lab/data/portfolio_data.dart';
import 'package:logic_lab/widgets/fade_in.dart';
import 'package:logic_lab/widgets/section_header.dart';

class AchievementsSection extends StatelessWidget {
  const AchievementsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 720;
    return Container(
      width: double.infinity,
      color: const Color(0xFF0A1020),
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 80 : 24,
        vertical: 72,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Key Achievements'),
          const SizedBox(height: 36),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              for (var i = 0; i < kAchievements.length; i++)
                FadeIn(
                  delay: Duration(milliseconds: 80 * i),
                  child: SizedBox(
                    width: isWide ? 300 : double.infinity,
                    child: _AchievementCard(achievement: kAchievements[i]),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;
  const _AchievementCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00D4FF).withValues(alpha: 0.07),
            const Color(0xFF0F1729),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00D4FF).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(achievement.emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.metric,
                  style: tt.titleLarge?.copyWith(
                    color: const Color(0xFF00D4FF),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: tt.bodySmall?.copyWith(
                    color: Colors.white60,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
