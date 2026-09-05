import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:bd_shope_combined/common_widgets/glass_background_scaffold.dart';
import 'package:bd_shope_combined/common_widgets/glass_card.dart';
import 'package:bd_shope_combined/controllers/theme_controller.dart';
import 'package:bd_shope_combined/constants/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tc = Get.find<ThemeController>();
    return Obx(() => GlassBackgroundScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: tc.textColor),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'About Us',
          style: TextStyle(
            color: tc.textColor,
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Column(
          children: [
            GlassCard(
              borderRadius: 20.r,
              child: Padding(
                padding: EdgeInsets.all(24.r),
                child: Column(
                  children: [
                    Container(
                      width: 80.w,
                      height: 80.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [AppColors.c053A4CA, AppColors.c5369CA, AppColors.c7953CA],
                        ),
                      ),
                      child: Icon(
                        Icons.info_outline,
                        color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                        size: 40,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Damadami Seller App',
                      style: TextStyle(
                        color: tc.textColor,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        color: tc.textSecondaryColor,
                        fontSize: 12.sp,
                      ),
                    ),
                    Divider(color: tc.dividerColor, height: 32.h),
                    Text(
                      'Damadami is a premium next-generation marketplace connecting buyers and sellers directly with real-time video and audio calling, custom invoices, and premium digital credentials. Our mission is to facilitate smooth, reliable, and secure commerce.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: tc.textColor.withOpacity(0.8),
                        fontSize: 14.sp,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h),
            GlassCard(
              borderRadius: 20.r,
              child: Padding(
                padding: EdgeInsets.all(20.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Key Features',
                      style: TextStyle(
                        color: tc.textColor,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _buildFeatureRow(Icons.video_call, 'Instant Video & Audio Calls', 'Connect directly to negotiate and inspect products.'),
                    _buildFeatureRow(Icons.receipt_long, 'Direct Invoicing', 'Sellers can create invoices immediately during a conversation.'),
                    _buildFeatureRow(Icons.security, 'Verified Credentials', 'Safety score metrics and badging to build trust in our community.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildFeatureRow(IconData icon, String title, String desc) {
    final tc = Get.find<ThemeController>();
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.c053A4CA, size: 20),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: tc.textColor,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  desc,
                  style: TextStyle(
                    color: tc.textColor.withOpacity(0.7),
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
