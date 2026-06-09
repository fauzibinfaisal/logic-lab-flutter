import 'package:flutter/material.dart';
import 'package:logic_lab/data/portfolio_data.dart';
import 'package:logic_lab/widgets/fade_in.dart';
import 'package:logic_lab/widgets/section_header.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return _SectionWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'About Me'),
          const SizedBox(height: 28),
          FadeIn(
            delay: const Duration(milliseconds: 100),
            child: Text(
              kAbout,
              style: tt.bodyLarge?.copyWith(
                color: Colors.white70,
                height: 1.75,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 36),
          FadeIn(
            delay: const Duration(milliseconds: 200),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _StatCard(value: '7+', label: 'Years Experience'),
                _StatCard(value: '100k+', label: 'Users Impacted'),
                _StatCard(value: '13+', label: 'Apps Delivered'),
                _StatCard(value: '8', label: 'Companies'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00D4FF).withValues(alpha: 0.12),
            const Color(0xFF0A0F1E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00D4FF).withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: tt.headlineMedium?.copyWith(
              color: const Color(0xFF00D4FF),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: tt.bodySmall?.copyWith(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}

// Shared section padding wrapper
class _SectionWrapper extends StatelessWidget {
  final Widget child;
  const _SectionWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 720;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 80 : 24,
        vertical: 72,
      ),
      child: child,
    );
  }
}
