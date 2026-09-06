import 'package:flutter/material.dart';
import 'package:logic_lab/data/portfolio_data.dart';
import 'package:logic_lab/visit_counter/widgets/visit_count_badge.dart';

class FooterSection extends StatelessWidget {
  final int? siteVisitCount;
  final bool visitCountLoading;

  const FooterSection({
    super.key,
    this.siteVisitCount,
    this.visitCountLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final isWide = MediaQuery.of(context).size.width > 720;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 80 : 24,
        vertical: 48,
      ),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFF1E2D4A)),
        ),
      ),
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Colors.white, Color(0xFF00D4FF)],
            ).createShader(bounds),
            child: Text(
              'Fauzi',
              style: tt.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Senior Mobile Application Engineer',
            style: tt.bodyMedium?.copyWith(color: Colors.white54),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 24,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _FooterLink(icon: Icons.phone_rounded, label: kContact.phone),
              _FooterLink(icon: Icons.email_rounded, label: kContact.email),
              _FooterLink(
                  icon: Icons.location_on_rounded, label: kContact.location),
            ],
          ),
          const SizedBox(height: 32),
          VisitCountBadge(
            count: siteVisitCount,
            loading: visitCountLoading,
            color: const Color(0xFF00D4FF),
          ),
          const SizedBox(height: 18),
          Text(
            '© 2026 Fauzi. Built with Flutter.',
            style: tt.bodySmall?.copyWith(color: Colors.white30),
          ),
        ],
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FooterLink({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF00D4FF)),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.white54),
        ),
      ],
    );
  }
}
