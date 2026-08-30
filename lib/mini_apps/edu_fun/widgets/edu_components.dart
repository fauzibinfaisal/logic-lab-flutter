import 'package:flutter/material.dart';

abstract final class EduColors {
  static const background = Color(0xFF10092B);
  static const surface = Color(0xFF1B1242);
  static const surfaceBright = Color(0xFF261A55);
  static const yellow = Color(0xFFFFC857);
  static const pink = Color(0xFFFF7AA2);
  static const cyan = Color(0xFF63E6FF);
  static const green = Color(0xFF72F1B8);
  static const purple = Color(0xFF9B8CFF);
}

class EduScreen extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const EduScreen({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 28, 20, 48),
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: padding,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 900,
              minHeight: constraints.maxHeight - 76,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class EduPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;
  final Color? color;

  const EduPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.borderColor,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? EduColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: borderColor ?? Colors.white.withValues(alpha: 0.1),
        ),
        boxShadow: const [
          BoxShadow(
              color: Colors.black26, blurRadius: 30, offset: Offset(0, 16)),
        ],
      ),
      child: child,
    );
  }
}

class EduPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData icon;

  const EduPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.arrow_forward_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onPressed,
        iconAlignment: IconAlignment.end,
        icon: Icon(icon, size: 22),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: EduColors.yellow,
          foregroundColor: const Color(0xFF241A04),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class EduStatTile extends StatelessWidget {
  final String label;
  final String value;
  final String emoji;
  final Color color;

  const EduStatTile({
    super.key,
    required this.label,
    required this.value,
    required this.emoji,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 10),
          Text(
            value,
            style: tt.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: tt.labelSmall?.copyWith(color: Colors.white54)),
        ],
      ),
    );
  }
}

class EduSectionTitle extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;

  const EduSectionTitle({
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
            color: EduColors.yellow,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.3,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          textAlign: TextAlign.center,
          style: tt.displaySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            height: 1.08,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: tt.bodyLarge?.copyWith(color: Colors.white60, height: 1.5),
        ),
      ],
    );
  }
}
