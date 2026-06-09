import 'package:flutter/material.dart';
import 'package:logic_lab/data/portfolio_data.dart';
import 'package:logic_lab/widgets/fade_in.dart';
import 'package:logic_lab/widgets/section_header.dart';

class SkillsSection extends StatelessWidget {
  const SkillsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 720;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 80 : 24,
        vertical: 72,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Core Skills'),
          const SizedBox(height: 36),
          for (var i = 0; i < kSkillGroups.length; i++)
            FadeIn(
              delay: Duration(milliseconds: 80 * i),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 28),
                child: _SkillGroupCard(group: kSkillGroups[i]),
              ),
            ),
        ],
      ),
    );
  }
}

class _SkillGroupCard extends StatelessWidget {
  final SkillGroup group;
  const _SkillGroupCard({required this.group});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1729),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E2D4A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            group.category,
            style: tt.labelMedium?.copyWith(
              color: const Color(0xFF00D4FF),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: group.skills.map((s) => _SkillChip(label: s)).toList(),
          ),
        ],
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  final String label;
  const _SkillChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF162040),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2A3F63)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white70,
            ),
      ),
    );
  }
}
