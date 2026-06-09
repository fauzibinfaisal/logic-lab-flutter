import 'package:flutter/material.dart';
import 'package:logic_lab/data/portfolio_data.dart';
import 'package:logic_lab/widgets/fade_in.dart';
import 'package:logic_lab/widgets/section_header.dart';

class ExperienceSection extends StatelessWidget {
  const ExperienceSection({super.key});

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
          const SectionHeader(title: 'Experience'),
          const SizedBox(height: 40),
          for (var i = 0; i < kExperiences.length; i++)
            FadeIn(
              delay: Duration(milliseconds: 80 * i),
              child: _TimelineItem(
                experience: kExperiences[i],
                isLast: i == kExperiences.length - 1,
              ),
            ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final Experience experience;
  final bool isLast;
  const _TimelineItem({required this.experience, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline spine: dot + line
        SizedBox(
          width: 32,
          child: Column(
            children: [
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00D4FF),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00D4FF).withValues(alpha: 0.5),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Container(
                  width: 1,
                  height: 260, // tall enough for any role card
                  margin: const EdgeInsets.only(top: 4),
                  color: const Color(0xFF1E2D4A),
                ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Content
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Period badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D4FF).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    experience.period,
                    style: tt.labelSmall?.copyWith(
                      color: const Color(0xFF00D4FF),
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  experience.title,
                  style: tt.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${experience.company} · ${experience.location}',
                  style: tt.bodySmall?.copyWith(color: Colors.white54),
                ),
                const SizedBox(height: 14),
                for (final b in experience.bullets)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF00D4FF),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            b,
                            style: tt.bodyMedium?.copyWith(
                              color: Colors.white60,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
