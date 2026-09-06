import 'package:flutter/material.dart';

class VisitCountBadge extends StatelessWidget {
  final int? count;
  final bool loading;
  final Color color;
  final bool compact;

  const VisitCountBadge({
    super.key,
    required this.count,
    required this.color,
    this.loading = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final label = loading
        ? 'Loading visits…'
        : count == null
            ? 'Visits unavailable'
            : formatVisitLabel(count!);

    return Semantics(
      label: label,
      excludeSemantics: true,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 10,
          vertical: compact ? 5 : 6,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: color.withValues(alpha: 0.22)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loading)
              SizedBox.square(
                dimension: compact ? 11 : 13,
                child: CircularProgressIndicator(
                  strokeWidth: 1.7,
                  color: color,
                ),
              )
            else
              Icon(
                count == null
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: color,
                size: compact ? 13 : 15,
              ),
            const SizedBox(width: 6),
            Text(
              loading
                  ? '…'
                  : count == null
                      ? 'Visits —'
                      : formatVisitLabel(count!),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: compact ? 10 : null,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

String formatVisitCount(int value) => value.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );

String formatVisitLabel(int value) =>
    '${formatVisitCount(value)} ${value == 1 ? 'visit' : 'visits'}';
