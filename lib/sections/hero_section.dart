import 'package:flutter/material.dart';
import 'package:logic_lab/data/portfolio_data.dart';
import 'package:logic_lab/widgets/fade_in.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final isWide = MediaQuery.of(context).size.width > 720;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 80 : 24,
        vertical: isWide ? 100 : 72,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF080D1A), Color(0xFF0D1B35), Color(0xFF080D1A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Background glow
          Positioned(
            top: -60,
            right: isWide ? 100 : -40,
            child: Container(
              width: 340,
              height: 340,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF00D4FF).withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge
              FadeIn(
                delay: const Duration(milliseconds: 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: const Color(0xFF00D4FF).withValues(alpha: 0.5)),
                    borderRadius: BorderRadius.circular(20),
                    color: const Color(0xFF00D4FF).withValues(alpha: 0.08),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF00D4FF),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Available for opportunities',
                        style: tt.labelSmall?.copyWith(
                          color: const Color(0xFF00D4FF),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              // Name
              FadeIn(
                delay: const Duration(milliseconds: 100),
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.white, Color(0xFF00D4FF)],
                  ).createShader(bounds),
                  child: Text(
                    'Fauzi',
                    style: tt.displayLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      fontSize: isWide ? 72 : 48,
                      height: 1.05,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Title
              FadeIn(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  'Mobile Application Developer',
                  style: tt.headlineSmall?.copyWith(
                    color: const Color(0xFF00D4FF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FadeIn(
                delay: const Duration(milliseconds: 250),
                child: Text(
                  'Swift  ·  Flutter  ·  Kotlin  ·  IoT & BLE Integration',
                  style: tt.bodyLarge?.copyWith(
                    color: Colors.white60,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const SizedBox(height: 36),
              // Contact row
              FadeIn(
                delay: const Duration(milliseconds: 350),
                child: Wrap(
                  spacing: 20,
                  runSpacing: 12,
                  children: [
                    _ContactChip(
                        icon: Icons.phone_rounded, label: kContact.phone),
                    _ContactChip(
                        icon: Icons.email_rounded, label: kContact.email),
                    _ContactChip(
                        icon: Icons.location_on_rounded,
                        label: kContact.location),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              // Tech stack pills
              FadeIn(
                delay: const Duration(milliseconds: 450),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    'Swift', 'Flutter', 'Kotlin', 'BLE / IoT',
                    'UIKit', 'SwiftUI', 'MVVM', 'Clean Arch',
                  ]
                      .map((t) => _TechPill(label: t))
                      .toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContactChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ContactChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: const Color(0xFF00D4FF)),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
        ),
      ],
    );
  }
}

class _TechPill extends StatelessWidget {
  final String label;
  const _TechPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2D4A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2A3F63)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white70,
              letterSpacing: 0.3,
            ),
      ),
    );
  }
}
