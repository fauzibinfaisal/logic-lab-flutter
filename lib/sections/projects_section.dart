import 'package:flutter/material.dart';
import 'package:logic_lab/data/portfolio_data.dart';
import 'package:logic_lab/widgets/fade_in.dart';
import 'package:logic_lab/widgets/section_header.dart';

class ProjectsSection extends StatelessWidget {
  const ProjectsSection({super.key});

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
          const SectionHeader(title: 'Selected Projects'),
          const SizedBox(height: 8),
          Text(
            '${kProjects.length} production apps shipped across iOS, Android & cross-platform',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white54,
                ),
          ),
          const SizedBox(height: 32),
          FadeIn(
            delay: const Duration(milliseconds: 100),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: kProjects
                  .map((p) => _ProjectChip(label: p))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectChip extends StatelessWidget {
  final String label;
  const _ProjectChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00D4FF).withValues(alpha: 0.08),
            const Color(0xFF0F1729),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF00D4FF).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.rocket_launch_rounded,
            size: 13,
            color: Color(0xFF00D4FF),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}
