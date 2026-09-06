import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logic_lab/mini_apps/edu_fun/edu_fun_page.dart'
    deferred as edu_fun;
import 'package:logic_lab/mini_apps/memory_quest/memory_quest_page.dart'
    deferred as memory_quest;
import 'package:logic_lab/mini_apps/models/mini_app.dart';
import 'package:logic_lab/mini_apps/qibla/qibla_page.dart' deferred as qibla;
import 'package:logic_lab/sections/about_section.dart';
import 'package:logic_lab/sections/achievements_section.dart';
import 'package:logic_lab/sections/education_section.dart';
import 'package:logic_lab/sections/experience_section.dart';
import 'package:logic_lab/sections/footer_section.dart';
import 'package:logic_lab/sections/hero_section.dart';
import 'package:logic_lab/sections/mini_apps_section.dart';
import 'package:logic_lab/sections/projects_section.dart';
import 'package:logic_lab/sections/skills_section.dart';
import 'package:logic_lab/visit_counter/data/visit_counter_api.dart';
import 'package:logic_lab/visit_counter/data/visit_counter_repository.dart';

class PortfolioPage extends StatefulWidget {
  final VisitCounterRepository? visitCounterRepository;

  const PortfolioPage({super.key, this.visitCounterRepository});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  static const _topNavHeight = 64.0;
  static const _sections = [
    'About',
    'Experience',
    'Skills',
    'Achievements',
    'Education',
    'Projects',
    'Mini Apps',
  ];

  final _scrollController = ScrollController();
  late final VisitCounterRepository _visitCounterRepository;
  final Map<String, GlobalKey> _sectionKeys = {
    for (final section in _sections)
      section: GlobalKey(debugLabel: '${section.toLowerCase()}-section'),
  };
  bool _showTopNav = false;
  bool _visitCountsLoading = true;
  Map<String, int> _visitCounts = const {};

  @override
  void initState() {
    super.initState();
    _visitCounterRepository =
        widget.visitCounterRepository ?? VisitCounterRepository();
    unawaited(_recordSiteVisit());
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
    if (widget.visitCounterRepository == null) {
      _visitCounterRepository.dispose();
    }
    super.dispose();
  }

  void _scrollTo(double offset) {
    _scrollController.animateTo(
      offset.clamp(0.0, _scrollController.position.maxScrollExtent).toDouble(),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  void _scrollToSection(String section) {
    final sectionContext = _sectionKeys[section]?.currentContext;
    final renderBox = sectionContext?.findRenderObject();

    if (renderBox is! RenderBox || !renderBox.attached) return;

    final sectionTop = renderBox.localToGlobal(Offset.zero).dy;
    final targetOffset = _scrollController.offset + sectionTop - _topNavHeight;
    _scrollTo(targetOffset);
  }

  Future<void> _openMiniApp(MiniAppDefinition app) async {
    final visitCountFuture = _recordMiniAppVisit(app.id);
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _DeferredMiniAppPage(
          app: app,
          visitCountFuture: visitCountFuture,
        ),
        settings: RouteSettings(name: '/mini-apps/${app.id}'),
      ),
    );
    if (mounted) unawaited(_refreshVisitCounts());
  }

  Future<void> _recordSiteVisit() async {
    try {
      final counts = await _visitCounterRepository.recordVisit(VisitScope.site);
      if (!mounted) return;
      setState(() {
        _visitCounts = counts.values;
        _visitCountsLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _visitCountsLoading = false);
    }
  }

  Future<int?> _recordMiniAppVisit(String scope) async {
    try {
      final counts = await _visitCounterRepository.recordVisit(scope);
      if (mounted) setState(() => _visitCounts = counts.values);
      return counts[scope];
    } catch (_) {
      return _visitCounts[scope];
    }
  }

  Future<void> _refreshVisitCounts() async {
    try {
      final counts = await _visitCounterRepository.fetchCounts();
      if (mounted) setState(() => _visitCounts = counts.values);
    } catch (_) {
      // Visitor counters are non-critical and never block the portfolio.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080D1A),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                const HeroSection(),
                AboutSection(key: _sectionKeys['About']),
                ExperienceSection(key: _sectionKeys['Experience']),
                SkillsSection(key: _sectionKeys['Skills']),
                AchievementsSection(key: _sectionKeys['Achievements']),
                EducationSection(key: _sectionKeys['Education']),
                ProjectsSection(key: _sectionKeys['Projects']),
                MiniAppsSection(
                  key: _sectionKeys['Mini Apps'],
                  onOpenApp: _openMiniApp,
                  visitCounts: _visitCounts,
                  visitCountsLoading: _visitCountsLoading,
                ),
                FooterSection(
                  siteVisitCount: _visitCounts[VisitScope.site],
                  visitCountLoading: _visitCountsLoading,
                ),
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
              child: _TopNavBar(
                sections: _sections,
                onSectionTap: _scrollToSection,
              ),
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

class _DeferredMiniAppPage extends StatefulWidget {
  final MiniAppDefinition app;
  final Future<int?> visitCountFuture;

  const _DeferredMiniAppPage({
    required this.app,
    required this.visitCountFuture,
  });

  @override
  State<_DeferredMiniAppPage> createState() => _DeferredMiniAppPageState();
}

class _DeferredMiniAppPageState extends State<_DeferredMiniAppPage> {
  late Future<void> _loadFuture;
  int? _visitCount;
  bool _visitCountLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFuture = _load();
    unawaited(_resolveVisitCount());
  }

  Future<void> _resolveVisitCount() async {
    final count = await widget.visitCountFuture;
    if (!mounted) return;
    setState(() {
      _visitCount = count;
      _visitCountLoading = false;
    });
  }

  Future<void> _load() => switch (widget.app.id) {
        'qibla' => qibla.loadLibrary(),
        'number-adventure' => edu_fun.loadLibrary(),
        'memory-quest' => memory_quest.loadLibrary(),
        _ => Future<void>.error('Unknown mini app: ${widget.app.id}'),
      };

  Widget _loadedApp() => switch (widget.app.id) {
        'qibla' => qibla.QiblaPage(
            visitCount: _visitCount,
            visitCountLoading: _visitCountLoading,
          ),
        'number-adventure' => edu_fun.EduFunPage(
            visitCount: _visitCount,
            visitCountLoading: _visitCountLoading,
          ),
        'memory-quest' => memory_quest.MemoryQuestPage(
            visitCount: _visitCount,
            visitCountLoading: _visitCountLoading,
          ),
        _ => const SizedBox.shrink(),
      };

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            !snapshot.hasError) {
          return _loadedApp();
        }

        return Scaffold(
          backgroundColor: const Color(0xFF080D1A),
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (snapshot.hasError)
                      Icon(
                        Icons.cloud_off_rounded,
                        color: widget.app.accentColor,
                        size: 44,
                      )
                    else
                      CircularProgressIndicator(
                        color: widget.app.accentColor,
                      ),
                    const SizedBox(height: 22),
                    Text(
                      snapshot.hasError
                          ? 'Could not load ${widget.app.title}'
                          : 'Loading ${widget.app.title}…',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    if (snapshot.hasError) ...[
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () => setState(() => _loadFuture = _load()),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Try again'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TopNavBar extends StatelessWidget {
  final List<String> sections;
  final ValueChanged<String> onSectionTap;

  const _TopNavBar({required this.sections, required this.onSectionTap});

  @override
  Widget build(BuildContext context) {
    final showFullNavigation = MediaQuery.sizeOf(context).width >= 1050;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: showFullNavigation ? 48 : 16,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF080D1A).withValues(alpha: 0.92),
        border: const Border(bottom: BorderSide(color: Color(0xFF1E2D4A))),
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
          if (showFullNavigation)
            Wrap(
              spacing: 24,
              children: sections
                  .map(
                    (section) => _NavItem(
                      label: section,
                      onTap: () => onSectionTap(section),
                    ),
                  )
                  .toList(),
            )
          else
            PopupMenuButton<String>(
              tooltip: 'Open navigation menu',
              onSelected: onSectionTap,
              color: const Color(0xFF0F1729),
              position: PopupMenuPosition.under,
              icon: const Icon(Icons.menu_rounded, color: Colors.white),
              itemBuilder: (context) => [
                for (final section in sections)
                  PopupMenuItem<String>(
                    value: section,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: Color(0xFF00D4FF),
                        ),
                        const SizedBox(width: 10),
                        Text(section),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _NavItem({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: ButtonStyle(
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        minimumSize: const WidgetStatePropertyAll(Size(0, 36)),
        overlayColor: WidgetStatePropertyAll(
          const Color(0xFF00D4FF).withValues(alpha: 0.08),
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.hovered) ||
                  states.contains(WidgetState.focused)
              ? const Color(0xFF00D4FF)
              : Colors.white60,
        ),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}
