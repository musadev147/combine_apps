import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bd_shope_combined/controllers/theme_controller.dart';

/// A reusable glass‑morphism card.
///
/// The card uses a [BackdropFilter] with a blur effect and a semi‑transparent
/// background color. It can be used anywhere a frosted‑glass appearance is
/// desired – for example, category tiles, product cards, or seller cards.
class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double blurSigma;
  final BoxBorder? border;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 20.0,
    this.padding,
    this.margin,
    this.color,
    this.blurSigma = 12.0,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().isDarkMode.value : false;
    final Color baseColor = color ?? (isDark ? Colors.white.withOpacity(0.15) : Colors.white.withOpacity(0.75));
    final Color borderColor = isDark ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.9);

    return Container(
      margin: margin ?? const EdgeInsets.all(8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
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
                  color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.05),
                  blurRadius: 15,
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
