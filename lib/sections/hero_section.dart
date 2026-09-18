import 'package:flutter/material.dart';
import 'package:logic_lab/data/portfolio_data.dart';
import 'package:logic_lab/widgets/fade_in.dart';

class HeroSection extends StatelessWidget {
  final VoidCallback onViewMiniApps;
  final VoidCallback onDownloadCv;
  final VoidCallback onEmail;
  final VoidCallback onPhone;
  final VoidCallback onLocation;
  final VoidCallback onGitHub;
  final VoidCallback onLinkedIn;

  const HeroSection({
    super.key,
    required this.onViewMiniApps,
    required this.onDownloadCv,
    required this.onEmail,
    required this.onPhone,
    required this.onLocation,
    required this.onGitHub,
    required this.onLinkedIn,
  });

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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
                      Flexible(
                        child: Text(
                          'Available for opportunities',
                          overflow: TextOverflow.ellipsis,
                          style: tt.labelSmall?.copyWith(
                            color: const Color(0xFF00D4FF),
                            letterSpacing: 0.5,
                          ),
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
              // Primary actions
              FadeIn(
                delay: const Duration(milliseconds: 320),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.icon(
                      onPressed: onViewMiniApps,
                      icon: const Icon(Icons.apps_rounded, size: 19),
                      label: const Text('View Mini Apps'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF00D4FF),
                        foregroundColor: const Color(0xFF080D1A),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: onDownloadCv,
                      icon: const Icon(Icons.download_rounded, size: 19),
                      label: const Text('Download CV'),
                      style: _secondaryButtonStyle(),
                    ),
                    OutlinedButton.icon(
                      onPressed: onEmail,
                      icon: const Icon(Icons.mail_outline_rounded, size: 19),
                      label: const Text('Email Me'),
                      style: _secondaryButtonStyle(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Contact row
              FadeIn(
                delay: const Duration(milliseconds: 390),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ContactChip(
                      icon: Icons.phone_rounded,
                      label: kContact.phone,
                      tooltip: 'Call Fauzi',
                      onTap: onPhone,
                    ),
                    _ContactChip(
                      icon: Icons.email_rounded,
                      label: kContact.email,
                      tooltip: 'Email Fauzi',
                      onTap: onEmail,
                    ),
                    _ContactChip(
                      icon: Icons.location_on_rounded,
                      label: kContact.location,
                      tooltip: 'View location on map',
                      onTap: onLocation,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              FadeIn(
                delay: const Duration(milliseconds: 430),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _SocialLink(
                      icon: Icons.code_rounded,
                      label: 'GitHub',
                      onTap: onGitHub,
                    ),
                    _SocialLink(
                      icon: Icons.work_outline_rounded,
                      label: 'LinkedIn',
                      onTap: onLinkedIn,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Tech stack pills
              FadeIn(
                delay: const Duration(milliseconds: 500),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    'Swift',
                    'Flutter',
                    'Kotlin',
                    'BLE / IoT',
                    'UIKit',
                    'SwiftUI',
                    'MVVM',
                    'Clean Arch',
                  ].map((t) => _TechPill(label: t)).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ButtonStyle _secondaryButtonStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: Colors.white,
      side: const BorderSide(color: Color(0xFF2A5272)),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      textStyle: const TextStyle(fontWeight: FontWeight.w700),
    );
  }
}

class _ContactChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String tooltip;
  final VoidCallback onTap;

  const _ContactChip({
    required this.icon,
    required this.label,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: TextButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16),
        label: Text(label),
        style: TextButton.styleFrom(
          foregroundColor: Colors.white70,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          visualDensity: VisualDensity.compact,
          side: BorderSide(
            color: const Color(0xFF00D4FF).withValues(alpha: 0.16),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class _SocialLink extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SocialLink({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 17),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF8DEAFF),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        visualDensity: VisualDensity.compact,
      ),
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
