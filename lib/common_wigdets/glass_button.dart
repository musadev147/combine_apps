import 'package:bd_shope_combined/controllers/theme_controller.dart';
import 'package:get/get.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bd_shope_combined/constants/app_colors.dart';

enum GlassButtonStyle { gradient, frosted }

class GlassButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final GlassButtonStyle style;
  final double? width;
  final double? height;
  final Widget? icon;

  const GlassButton({
    super.key,
    required this.text,
    required this.onTap,
    this.style = GlassButtonStyle.gradient,
    this.width,
    this.height,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final defaultHeight = 54.h;
    final buttonWidth = width ?? double.infinity;
    final buttonHeight = height ?? defaultHeight;

    if (style == GlassButtonStyle.gradient) {
      return Container(
        width: buttonWidth,
        height: buttonHeight,
        margin: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF53A4CA), // --color-1
              Color(0xFF5369CA), // --color-2
              Color(0xFF7953CA), // --color-3
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5369CA).withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20.r),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    icon!,
                    SizedBox(width: 8.w),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      // Frosted style
      return Container(
        width: buttonWidth,
        height: buttonHeight,
        margin: EdgeInsets.symmetric(vertical: 8.h),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().cardBackground : Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12.withOpacity(0.25),
                  width: 1.5,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(20.r),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          icon!,
                          SizedBox(width: 8.w),
                        ],
                        Text(
                          text,
                          style: TextStyle(
                            color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
  }
}
