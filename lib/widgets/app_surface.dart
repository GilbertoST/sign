import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// White card: hairline, soft shadow, ripple clipped to the radius.
class AppSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;
  final double? radius;
  final List<BoxShadow>? shadows;

  const AppSurface({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.color,
    this.borderColor,
    this.radius,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    final r = radius ?? AppTheme.radiusCard;
    final radiusValue = BorderRadius.circular(r);
    final bg = color ?? AppTheme.cardColor(context);
    final border = borderColor ?? AppTheme.line(context);

    final material = Material(
      color: bg,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: radiusValue,
        side: BorderSide(color: border),
      ),
      child: onTap == null
          ? Padding(padding: padding ?? EdgeInsets.zero, child: child)
          : InkWell(
              onTap: onTap,
              child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
            ),
    );

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radiusValue,
          boxShadow: shadows ?? AppTheme.shadow(context),
        ),
        child: material,
      ),
    );
  }
}
