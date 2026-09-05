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
    final Color baseColor = color ?? (isDark ? const Color(0xFF1E1E38).withOpacity(0.65) : Colors.white);
    final Color borderColor = isDark ? Colors.white.withOpacity(0.18) : const Color(0xFFE2E8F0);

    return Container(
      margin: margin ?? const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.35) : const Color(0xFF0F172A).withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : const Color(0xFF5369CA).withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding ?? const EdgeInsets.all(0),
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(borderRadius),
              border: border ?? Border.all(
                color: borderColor,
                width: 1.2,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
