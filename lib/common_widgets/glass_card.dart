import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bd_shope_combined/controllers/theme_controller.dart';

/// A reusable glass‑morphism card.
///
/// Usage:
/// ```dart
/// GlassCard(
///   child: Padding(
///     padding: const EdgeInsets.all(16),
///     child: Text('Content'),
///   ),
/// )
/// ```
class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const GlassCard({
    Key? key,
    required this.child,
    this.borderRadius = 20.0,
    this.blur = 12.0,
    this.backgroundColor,
    this.margin,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().isDarkMode.value : false;
    final Color baseColor = backgroundColor ?? (isDark ? Colors.white.withOpacity(0.15) : Colors.white);
    final Color borderColor = isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.05);

    return Container(
      margin: margin ?? const EdgeInsets.all(8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? const EdgeInsets.all(0),
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
