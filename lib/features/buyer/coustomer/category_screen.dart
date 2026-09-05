import 'package:bd_shope_combined/controllers/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:bd_shope_combined/route/app_pages.dart';
import 'package:bd_shope_combined/common_wigdets/glass_card.dart';
import 'package:bd_shope_combined/common_wigdets/glass_background.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categories = [
      {'name': 'Electronics', 'icon': Icons.devices, 'count': '124 listings'},
      {'name': 'Vehicles', 'icon': Icons.directions_car, 'count': '87 listings'},
      {'name': 'Fashion', 'icon': Icons.checkroom, 'count': '256 listings'},
      {'name': 'Home & Living', 'icon': Icons.weekend, 'count': '92 listings'},
      {'name': 'Property', 'icon': Icons.apartment, 'count': '43 listings'},
      {'name': 'Jobs', 'icon': Icons.work_outline, 'count': '112 listings'},
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12.withOpacity(0.1), width: 1),
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              onPressed: () => Get.back(),
              icon: Icon(Icons.arrow_back_ios, color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black),
            ),
            title: Text(
              'All Categories',
              style: GoogleFonts.outfit(
                color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: 20.sp,
              ),
            ),
          ),
        ),
      ),
      body: GlassBackground(
        child: SafeArea(
          child: ListView.builder(
            padding: EdgeInsets.all(16.r),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return Container(
                margin: EdgeInsets.only(bottom: 12.h),
                child: GestureDetector(
                  onTap: () {
                    Get.toNamed(Routes.PRODUCT_LIST, arguments: cat['name']);
                  },
                  child: GlassCard(
                    borderRadius: 20.r,
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().cardBackground : Colors.white.withOpacity(0.08),
                          ),
                          child: Icon(cat['icon'], color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, size: 24.r),
                        ),
                        SizedBox(width: 20.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cat['name'],
                                style: GoogleFonts.outfit(
                                  color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                cat['count'],
                                style: GoogleFonts.poppins(
                                  color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.5),
                                  fontSize: 12.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.4), size: 16.r),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
