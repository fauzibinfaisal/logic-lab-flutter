import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: tt.labelSmall?.copyWith(
            color: const Color(0xFF00D4FF),
            letterSpacing: 2.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 36,
          height: 2,
          decoration: BoxDecoration(
            color: const Color(0xFF00D4FF),
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00D4FF).withValues(alpha: 0.5),
                blurRadius: 8,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
