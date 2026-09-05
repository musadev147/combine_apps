import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'custom_theme.dart';
import 'package:bd_shope_combined/constants/app_colors.dart';

/// A premium, beautiful glassmorphism background container.
/// It uses deep gradient overlays and blurred background shapes (blobs)
/// to create a professional frosted glass aesthetic.
class GlassBackground extends StatelessWidget {
  final Widget child;

  const GlassBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<CustomThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Stack(
      children: [
        // Base gradient background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? const [
                      Color(0xFF0F172A), // Very dark slate
                      Color(0xFF1E1E38), // Dark indigo
                      Color(0xFF110E24), // Dark deep violet
                    ]
                  : const [
                      Colors.white,
                      Color(0xFFF8FAFC),
                      Colors.white,
                    ],
            ),
          ),
        ),

        // Glowing Blur Blob 1: Top-Right (Purple)
        Positioned(
          top: -100.h,
          right: -80.w,
          child: Container(
            width: 320.w,
            height: 320.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF7953CA).withOpacity(isDark ? 0.35 : 0.08),
            ),
          ),
        ),

        // Glowing Blur Blob 2: Middle-Left (Light Blue)
        Positioned(
          top: 300.h,
          left: -100.w,
          child: Container(
            width: 360.w,
            height: 360.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF53A4CA).withOpacity(isDark ? 0.3 : 0.08),
            ),
          ),
        ),

        // Glowing Blur Blob 3: Bottom-Right (Indigo)
        Positioned(
          bottom: -80.h,
          right: -50.w,
          child: Container(
            width: 300.w,
            height: 300.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF5369CA).withOpacity(isDark ? 0.35 : 0.08),
            ),
          ),
        ),

        // Blur Filter covering the background shapes
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
            child: Container(
              color: isDark
                  ? Colors.black.withOpacity(0.35)
                  : Colors.white.withOpacity(0.6),
            ),
          ),
        ),

        // Content
        Positioned.fill(
          child: child,
        ),
      ],
    );
  }
}
