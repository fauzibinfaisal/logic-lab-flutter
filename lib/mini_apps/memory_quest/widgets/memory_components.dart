import 'dart:math';

import 'package:flutter/material.dart';
import 'package:logic_lab/mini_apps/memory_quest/models/memory_models.dart';

abstract final class MemoryColors {
  static const background = Color(0xFF07152C);
  static const surface = Color(0xFF102747);
  static const surfaceBright = Color(0xFF18365D);
  static const cyan = Color(0xFF7EE8FA);
  static const yellow = Color(0xFFFFD166);
  static const pink = Color(0xFFFF7AA8);
  static const green = Color(0xFF70E8B0);
  static const purple = Color(0xFFB59BFF);
}

class MemoryScreen extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool scrollable;

  const MemoryScreen({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(18, 26, 18, 46),
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 940),
        child: child,
      ),
    );
    if (!scrollable) return Padding(padding: padding, child: content);
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: padding,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight - 72),
          child: content,
        ),
      ),
    );
  }
}

class MemoryPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;
  final Color? color;

  const MemoryPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(22),
    this.borderColor,
    this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
          color: color ?? MemoryColors.surface,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: borderColor ?? Colors.white.withValues(alpha: 0.1),
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 28,
              offset: Offset(0, 14),
            ),
          ],
        ),
        child: child,
      );
}

class MemoryPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData icon;
  final Color color;

  const MemoryPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.arrow_forward_rounded,
    this.color = MemoryColors.yellow,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: onPressed,
          iconAlignment: IconAlignment.end,
          icon: Icon(icon),
          label: Text(label),
          style: FilledButton.styleFrom(
            backgroundColor: color,
            foregroundColor: const Color(0xFF142035),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(17),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      );
}

class MemoryTitle extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;

  const MemoryTitle({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      children: [
        Text(
          eyebrow,
          textAlign: TextAlign.center,
          style: tt.labelMedium?.copyWith(
            color: MemoryColors.cyan,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          title,
          textAlign: TextAlign.center,
          style: tt.displaySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            height: 1.08,
          ),
        ),
        const SizedBox(height: 11),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: tt.bodyLarge?.copyWith(color: Colors.white60, height: 1.45),
        ),
      ],
    );
  }
}

class MemoryStat extends StatelessWidget {
  final String label;
  final String value;
  final String emoji;
  final Color color;

  const MemoryStat({
    super.key,
    required this.label,
    required this.value,
    required this.emoji,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: color.withValues(alpha: 0.22)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 7),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: Colors.white54),
            ),
          ],
        ),
      );
}

class MemoryBoard extends StatelessWidget {
  final List<MemoryCardData> cards;
  final int columns;
  final bool locked;
  final ValueChanged<int> onCardTap;

  const MemoryBoard({
    super.key,
    required this.cards,
    required this.columns,
    required this.locked,
    required this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    final rows = (cards.length / columns).ceil();
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxBoardWidth = switch (columns) {
          <= 4 => 520.0,
          5 => 580.0,
          _ => 620.0,
        };
        final boardWidth = min(constraints.maxWidth, maxBoardWidth);
        final gap = boardWidth < 420 ? 6.0 : 9.0;
        final cardWidth = (boardWidth - gap * (columns - 1)) / columns;
        final ratio = columns >= 6 ? 0.92 : 0.88;
        final boardHeight = rows * (cardWidth / ratio) + gap * (rows - 1);
        return Center(
          child: SizedBox(
            width: boardWidth,
            height: boardHeight,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: gap,
                mainAxisSpacing: gap,
                childAspectRatio: ratio,
              ),
              itemCount: cards.length,
              itemBuilder: (context, index) => _MemoryCard(
                card: cards[index],
                enabled: !locked && !cards[index].isMatched,
                onTap: () => onCardTap(index),
                compact: columns >= 6,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MemoryCard extends StatelessWidget {
  final MemoryCardData card;
  final bool enabled;
  final bool compact;
  final VoidCallback onTap;

  const _MemoryCard({
    required this.card,
    required this.enabled,
    required this.compact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final shown = card.isRevealed || card.isMatched;
    return Semantics(
      button: true,
      label: shown ? 'Card ${card.symbol}' : 'Hidden memory card',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled && !shown ? onTap : null,
          borderRadius: BorderRadius.circular(compact ? 10 : 15),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: shown
                    ? [const Color(0xFFF9FBFF), const Color(0xFFDCEFFF)]
                    : [const Color(0xFF27598A), const Color(0xFF193B68)],
              ),
              borderRadius: BorderRadius.circular(compact ? 10 : 15),
              border: Border.all(
                color: card.isMatched
                    ? MemoryColors.green
                    : shown
                        ? MemoryColors.cyan
                        : Colors.white.withValues(alpha: 0.17),
                width: card.isMatched ? 2 : 1,
              ),
              boxShadow: card.isMatched
                  ? [
                      BoxShadow(
                        color: MemoryColors.green.withValues(alpha: 0.25),
                        blurRadius: 14,
                      ),
                    ]
                  : null,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: Tween(begin: 0.6, end: 1.0).animate(animation),
                child: child,
              ),
              child: Center(
                key: ValueKey(shown),
                child: shown
                    ? Text(
                        card.symbol,
                        style: TextStyle(fontSize: compact ? 22 : 32),
                      )
                    : Icon(
                        Icons.question_mark_rounded,
                        color: Colors.white.withValues(alpha: 0.78),
                        size: compact ? 19 : 26,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String compactScore(int value) => value.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
