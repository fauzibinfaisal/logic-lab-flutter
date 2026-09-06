import 'package:flutter/material.dart';
import 'package:logic_lab/mini_apps/data/mini_apps_catalog.dart';
import 'package:logic_lab/mini_apps/models/mini_app.dart';
import 'package:logic_lab/visit_counter/widgets/visit_count_badge.dart';
import 'package:logic_lab/widgets/fade_in.dart';

class MiniAppsSection extends StatelessWidget {
  final ValueChanged<MiniAppDefinition> onOpenApp;
  final Map<String, int> visitCounts;
  final bool visitCountsLoading;

  const MiniAppsSection({
    super.key,
    required this.onOpenApp,
    this.visitCounts = const {},
    this.visitCountsLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width > 720;

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF090E1D), Color(0xFF0B1722), Color(0xFF09101E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -160,
            right: -120,
            child: IgnorePointer(
              child: Container(
                width: 420,
                height: 420,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF6EE7B7).withValues(alpha: 0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 80 : 24,
              vertical: isWide ? 88 : 72,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _MiniAppsHeader(),
                const SizedBox(height: 52),
                for (final category in miniAppCatalog)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: _CategoryBlock(
                      category: category,
                      onOpenApp: onOpenApp,
                      visitCounts: visitCounts,
                      visitCountsLoading: visitCountsLoading,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniAppsHeader extends StatelessWidget {
  const _MiniAppsHeader();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return FadeIn(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFF6EE7B7).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                  color: const Color(0xFF6EE7B7).withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                'INTERACTIVE LAB',
                style: tt.labelSmall?.copyWith(
                  color: const Color(0xFF6EE7B7),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Mini Apps',
              style: tt.displaySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Small, focused tools made to solve one useful problem beautifully.',
              style: tt.bodyLarge?.copyWith(
                color: Colors.white60,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryBlock extends StatelessWidget {
  final MiniAppCategoryDefinition category;
  final ValueChanged<MiniAppDefinition> onOpenApp;
  final Map<String, int> visitCounts;
  final bool visitCountsLoading;

  const _CategoryBlock({
    required this.category,
    required this.onOpenApp,
    required this.visitCounts,
    required this.visitCountsLoading,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return FadeIn(
      delay: const Duration(milliseconds: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF17273A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF25405A)),
                ),
                child: Icon(
                  category.icon,
                  size: 20,
                  color: const Color(0xFF6EE7B7),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.title,
                      style: tt.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category.description,
                      style: tt.bodyMedium?.copyWith(color: Colors.white54),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) => Wrap(
              spacing: 18,
              runSpacing: 18,
              children: [
                for (final app in category.apps)
                  SizedBox(
                    width: constraints.maxWidth >= 760
                        ? 440
                        : constraints.maxWidth,
                    child: _MiniAppCard(
                      app: app,
                      onTap: () => onOpenApp(app),
                      visitCount: visitCounts[app.id],
                      visitCountLoading: visitCountsLoading,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniAppCard extends StatefulWidget {
  final MiniAppDefinition app;
  final VoidCallback onTap;
  final int? visitCount;
  final bool visitCountLoading;

  const _MiniAppCard({
    required this.app,
    required this.onTap,
    required this.visitCount,
    required this.visitCountLoading,
  });

  @override
  State<_MiniAppCard> createState() => _MiniAppCardState();
}

class _MiniAppCardState extends State<_MiniAppCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedScale(
        scale: _hovered ? 1.015 : 1,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(22),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF142434),
                    _hovered
                        ? const Color(0xFF12342F)
                        : const Color(0xFF101B2A),
                  ],
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: widget.app.accentColor.withValues(
                    alpha: _hovered ? 0.65 : 0.28,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.app.accentColor.withValues(
                      alpha: _hovered ? 0.1 : 0.04,
                    ),
                    blurRadius: 28,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _AppPreview(app: widget.app),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.app.eyebrow,
                          style: tt.labelSmall?.copyWith(
                            color: widget.app.accentColor,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.app.title,
                          style: tt.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          widget.app.description,
                          style: tt.bodyMedium?.copyWith(
                            color: Colors.white60,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Open app',
                                  style: tt.labelMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 7),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  color: widget.app.accentColor,
                                  size: 18,
                                ),
                              ],
                            ),
                            VisitCountBadge(
                              count: widget.visitCount,
                              loading: widget.visitCountLoading,
                              color: widget.app.accentColor,
                              compact: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AppPreview extends StatelessWidget {
  final MiniAppDefinition app;

  const _AppPreview({required this.app});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF08121D),
        border: Border.all(color: app.accentColor.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: app.accentColor.withValues(alpha: 0.12),
            blurRadius: 22,
          ),
        ],
      ),
      child: switch (app.id) {
        'qibla' => Stack(
            alignment: Alignment.center,
            children: [
              Text(
                'N',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white38,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Transform.rotate(
                angle: -0.8,
                child: Icon(
                  Icons.navigation_rounded,
                  size: 48,
                  color: app.accentColor,
                ),
              ),
              Positioned(
                right: 11,
                bottom: 15,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: const Color(0xFF111111),
                    border: Border.all(color: const Color(0xFFD8B45B)),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        'memory-quest' => Stack(
            alignment: Alignment.center,
            children: [
              for (final item in const [
                (Alignment(-0.45, -0.45), '🐼'),
                (Alignment(0.45, -0.45), '?'),
                (Alignment(-0.45, 0.45), '?'),
                (Alignment(0.45, 0.45), '🐼'),
              ])
                Align(
                  alignment: item.$1,
                  child: Container(
                    width: 29,
                    height: 29,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: item.$2 == '?'
                          ? app.accentColor.withValues(alpha: 0.18)
                          : const Color(0xFF253E58),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: app.accentColor.withValues(alpha: 0.45),
                      ),
                    ),
                    child: Text(
                      item.$2,
                      style: TextStyle(
                        color: app.accentColor,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        _ => Stack(
            alignment: Alignment.center,
            children: [
              Icon(app.icon, size: 45, color: app.accentColor),
              Positioned(
                top: 9,
                right: 11,
                child: Text(
                  '7',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: const Color(0xFF8BE9FD),
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
              Positioned(
                left: 11,
                bottom: 9,
                child: Text(
                  '+',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFFFF7AA2),
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
            ],
          ),
      },
    );
  }
}
