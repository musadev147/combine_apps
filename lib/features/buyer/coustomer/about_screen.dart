import 'package:bd_shope_combined/controllers/theme_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bd_shope_combined/common_wigdets/glass_background.dart';
import 'package:bd_shope_combined/common_wigdets/glass_card.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'About Us',
            style: GoogleFonts.outfit(
              color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
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
                padding: EdgeInsets.all(24.r),
                child: Column(
                  children: [
                    Container(
                      width: 80.w,
                      height: 80.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF53A4CA), Color(0xFF5369CA), Color(0xFF7953CA)],
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
                      'Damadami App',
                      style: GoogleFonts.outfit(
                        color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Version 1.0.0',
                      style: GoogleFonts.poppins(
                        color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.5),
                        fontSize: 12.sp,
                      ),
                    ),
                    Divider(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12.withOpacity(0.1), height: 32.h),
                    Text(
                      'Damadami is a premium next-generation marketplace connecting buyers and sellers directly with real-time video and audio calling, custom invoices, and premium digital credentials. Our mission is to facilitate smooth, reliable, and secure commerce.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.8),
                        fontSize: 14.sp,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              GlassCard(
                borderRadius: 20.r,
                padding: EdgeInsets.all(20.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Key Features',
                      style: GoogleFonts.outfit(
                        color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String title, String desc) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF53A4CA), size: 20),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  desc,
                  style: GoogleFonts.poppins(
                    color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.7),
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
