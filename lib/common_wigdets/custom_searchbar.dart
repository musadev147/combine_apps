import 'package:bd_shope_combined/controllers/theme_controller.dart';
import 'package:bd_shope_combined/helpers/screen_stubs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:bd_shope_combined/constants/app_assets/assets_icons.dart';
import 'package:bd_shope_combined/constants/app_colors.dart';
import 'package:bd_shope_combined/helpers/ui_helpers.dart';

class CustomSearchBar extends StatelessWidget {
  final VoidCallback? onFilterTap;
  final String hint;

  const CustomSearchBar({super.key, this.onFilterTap, this.hint = "Search..."});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          height: 30.h,
          width: 30.h,
          child: Image.asset(
            AssetsIcons.logoIcons,
            height: 28.h,
            width: 28.h,
            fit: BoxFit.contain,
            color: AppColors.appThemeColor,
          ),
        ),

        UIHelper.horizontalSpace(4.w),

        /// Search Field
        Expanded(
          child: GestureDetector(
            onTap: () {
              Get.to(() => const PropertySearchScreen());
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
              decoration: BoxDecoration(
                color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().cardBackground : Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: IgnorePointer(
                child: TextField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.search, color: Colors.grey),
                    hintText: hint,
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),
        ),

        SizedBox(width: 12),

        /// Filter Button
        GestureDetector(
          onTap: onFilterTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().cardBackground : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Image.asset(AssetsIcons.fsIcons, height: 22, width: 22),
          ),
        ),
      ],
    );
  }
}
