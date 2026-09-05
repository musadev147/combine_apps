import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:bd_shope_combined/common_wigdets/glass_background.dart';
import 'package:bd_shope_combined/constants/app_colors.dart';
import 'package:bd_shope_combined/route/app_pages.dart';
import 'package:bd_shope_combined/controllers/theme_controller.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlassBackground(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 40.h),
                Text(
                  "Welcome to Damadami",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                    color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  "Please select your role to continue",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textSecondaryColor : Colors.black.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: 60.h),
                _buildRoleCard(
                  title: "I am a Buyer",
                  description: "Explore products and manage your purchases",
                  icon: Icons.shopping_cart_outlined,
                  color: AppColors.c053A4CA,
                  onTap: () {
                    // Navigate to Buyer Login or Auth flow
                    Get.toNamed(Routes.LOGIN);
                  },
                ),
                SizedBox(height: 24.h),
                _buildRoleCard(
                  title: "I am a Seller",
                  description: "Manage your store and track sales",
                  icon: Icons.storefront_outlined,
                  color: AppColors.c7953CA,
                  onTap: () {
                    Get.toNamed(Routes.SELLER_LOGIN); 
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().cardBackground : Colors.white.withOpacity(0.05),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 1,
            ),
          ],
        ),
        padding: EdgeInsets.all(24.r),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32.r,
                color: color,
              ),
            ),
            SizedBox(width: 20.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textSecondaryColor : Colors.black.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor.withOpacity(0.5) : Colors.black.withOpacity(0.5),
              size: 16.r,
            ),
          ],
        ),
      ),
    );
  }
}
