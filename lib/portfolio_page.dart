import 'package:flutter/material.dart';
import 'package:logic_lab/sections/about_section.dart';
import 'package:logic_lab/sections/achievements_section.dart';
import 'package:logic_lab/sections/education_section.dart';
import 'package:logic_lab/sections/experience_section.dart';
import 'package:logic_lab/sections/footer_section.dart';
import 'package:logic_lab/sections/hero_section.dart';
import 'package:logic_lab/sections/projects_section.dart';
import 'package:logic_lab/sections/skills_section.dart';

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  final _scrollController = ScrollController();
  bool _showTopNav = false;

  static const _sections = [
    'About', 'Experience', 'Skills', 'Achievements', 'Education', 'Projects',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final shouldShow = _scrollController.offset > 300;
      if (shouldShow != _showTopNav) {
        setState(() => _showTopNav = shouldShow);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollTo(double offset) {
    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080D1A),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: const Column(
              children: [
                HeroSection(),
                AboutSection(),
                ExperienceSection(),
                SkillsSection(),
                AchievementsSection(),
                EducationSection(),
                ProjectsSection(),
                FooterSection(),
              ],
            ),
          ),
          // Floating top nav bar
          AnimatedSlide(
            offset: _showTopNav ? Offset.zero : const Offset(0, -1),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: AnimatedOpacity(
              opacity: _showTopNav ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: _TopNavBar(sections: _sections),
            ),
          ),
          // FAB scroll-to-top
          Positioned(
            bottom: 28,
            right: 28,
            child: AnimatedOpacity(
              opacity: _showTopNav ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: FloatingActionButton.small(
                onPressed: () => _scrollTo(0),
                backgroundColor: const Color(0xFF00D4FF),
                foregroundColor: const Color(0xFF080D1A),
                child: const Icon(Icons.keyboard_arrow_up_rounded),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopNavBar extends StatelessWidget {
  final List<String> sections;
  const _TopNavBar({required this.sections});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 48 : 16,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF080D1A).withValues(alpha: 0.92),
        border: const Border(
          bottom: BorderSide(color: Color(0xFF1E2D4A)),
        ),
      ),
      child: Row(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Colors.white, Color(0xFF00D4FF)],
            ).createShader(bounds),
            child: Text(
              'Fauzi',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          const Spacer(),
          if (isWide)
            Wrap(
              spacing: 24,
              children: sections
                  .map((s) => _NavItem(label: s))
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  const _NavItem({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Colors.white60,
          ),
    );
  }
}
