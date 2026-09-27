import 'package:flutter/material.dart';

import '../theme.dart';
import 'muscle_icon.dart';

/// Dark background with the red swoosh image from the design.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: AppColors.bg),
        Opacity(
          opacity: 0.8,
          child: Image.asset('assets/images/background.png', fit: BoxFit.cover),
        ),
        SafeArea(child: child),
      ],
    );
  }
}

/// Standard page: back arrow, centered uppercase title, body, optional bottom button.
class PageScaffold extends StatelessWidget {
  const PageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.subtitle,
    this.bottom,
    this.actions = const [],
    this.showBack = true,
  });

  final String title;
  final String? subtitle;
  final Widget body;
  final Widget? bottom;
  final List<Widget> actions;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: Column(
          children: [
            SizedBox(
              height: 48,
              child: Row(
                children: [
                  if (showBack)
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  else
                    const SizedBox(width: 48),
                  const Spacer(),
                  ...actions,
                ],
              ),
            ),
            Text(
              title.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: 1),
            ),
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(subtitle!, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
              ),
            const SizedBox(height: 16),
            Expanded(child: body),
            if (bottom != null) Padding(padding: const EdgeInsets.all(16), child: bottom),
          ],
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton(this.label, this.onPressed, {super.key});
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.red,
          disabledBackgroundColor: AppColors.redDark,
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white54,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: onPressed,
        child: Text(
          label.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1),
        ),
      ),
    );
  }
}

class DarkCard extends StatelessWidget {
  const DarkCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(14),
    this.margin = EdgeInsets.zero,
    this.highlighted = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(14);
    return Padding(
      padding: margin,
      child: Material(
        color: AppColors.card.withValues(alpha: 0.92),
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: highlighted ? AppColors.red : AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class IconBadge extends StatelessWidget {
  const IconBadge(IconData this.icon, {super.key, this.size = 40, this.color = AppColors.red}) : muscle = null;

  /// Shows the [MuscleIcon] for a muscle group instead of an icon.
  const IconBadge.muscle(String this.muscle, {super.key, this.size = 40, this.color = AppColors.red}) : icon = null;

  final IconData? icon;
  final String? muscle;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(size / 4)),
      child: Center(
        child: muscle != null
            ? MuscleIcon(muscle!, color: Colors.white, size: size * 0.8)
            : Icon(icon, color: Colors.white, size: size * 0.55),
      ),
    );
  }
}

class StatBox extends StatelessWidget {
  const StatBox(this.label, this.value, {super.key, this.unit});
  final String label;
  final String value;
  final String? unit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.cardAlt,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 10)),
          const SizedBox(height: 2),
          Text.rich(
            TextSpan(children: [
              TextSpan(text: value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              if (unit != null)
                TextSpan(text: ' $unit', style: const TextStyle(color: AppColors.muted, fontSize: 10)),
            ]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(color: AppColors.red, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.5),
    );
  }
}

class ImagePlaceholder extends StatelessWidget {
  const ImagePlaceholder(IconData this.icon, {super.key, this.size = 56, this.height}) : muscle = null;

  /// Shows the [MuscleIcon] for a muscle group instead of an icon.
  const ImagePlaceholder.muscle(String this.muscle, {super.key, this.size = 56, this.height}) : icon = null;

  final IconData? icon;
  final String? muscle;
  final double size;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: height == null ? size : double.infinity,
      height: height ?? size,
      decoration: BoxDecoration(color: AppColors.cardAlt, borderRadius: BorderRadius.circular(8)),
      child: Center(
        child: muscle != null
            ? MuscleIcon(muscle!, color: AppColors.red, baseColor: AppColors.muted.withValues(alpha: 0.35),
                size: (height ?? size) * 0.8)
            : Icon(icon, color: AppColors.muted, size: (height ?? size) * 0.45),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState(this.message, {super.key, this.icon = Icons.inbox_outlined});
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.muted, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted)),
          ],
        ),
      ),
    );
  }
}
