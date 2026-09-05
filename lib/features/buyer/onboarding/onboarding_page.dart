import 'package:bd_shope_combined/controllers/theme_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final List<Color>? gradientColors;

  const OnboardingPage({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final colors = gradientColors ?? const [
      Color(0xFF53A4CA),
      Color(0xFF5369CA),
      Color(0xFF7953CA),
    ];
    final isDark = Get.isRegistered<ThemeController>() && Get.find<ThemeController>().isDarkMode.value;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Outer halo ring container
          Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.first.withOpacity(isDark ? 0.2 : 0.12),
              border: Border.all(
                color: colors.first.withOpacity(isDark ? 0.35 : 0.2),
                width: 1.5,
              ),
            ),
            child: Container(
              padding: EdgeInsets.all(28.r),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: colors,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.first.withOpacity(0.4),
                    blurRadius: 28,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 68.r,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 48.h),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 26.sp,
              fontWeight: FontWeight.w700,
              color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black87,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          Text(
            description,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textSecondaryColor : Colors.black54,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
