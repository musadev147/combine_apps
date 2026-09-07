import 'package:bd_shope_combined/controllers/theme_controller.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:bd_shope_combined/constants/app_colors.dart';
import 'package:bd_shope_combined/common_widgets/glass_background_scaffold.dart';
import 'package:bd_shope_combined/common_widgets/glass_card.dart';
import 'data/call_controller.dart';

class IncomingCallScreen extends StatefulWidget {
  const IncomingCallScreen({super.key});

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  final CallController _callController = Get.find<CallController>();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassBackgroundScaffold(
      body: Stack(
        children: [
          // Background soft ambient glow
          Positioned(
            top: 150.h,
            left: 50.w,
            right: 50.w,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: Container(
                height: 250.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.c053A4CA.withOpacity(0.15),
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Header Info
                Padding(
                  padding: EdgeInsets.only(top: 60.h, left: 24.w, right: 24.w),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().cardBackground.withOpacity(0.5) : AppColors.cWhite.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : AppColors.cWhite.withOpacity(0.1)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.support_agent_rounded, color: AppColors.c053A4CA, size: 18),
                            SizedBox(width: 8.w),
                            Text(
                              "INCOMING PRODUCT INQUIRY",
                              style: TextStyle(
                                color: AppColors.c053A4CA,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30.h),
                      
                      // Pulse Caller Animation
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              // Pulse ring 1
                              Container(
                                width: 140.w + (40 * _pulseController.value).w,
                                height: 140.h + (40 * _pulseController.value).h,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.c053A4CA.withOpacity(1.0 - _pulseController.value),
                                    width: 3.w,
                                  ),
                                ),
                              ),
                              // Pulse ring 2
                              Container(
                                width: 140.w + (80 * _pulseController.value).w,
                                height: 140.h + (80 * _pulseController.value).h,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.c7953CA.withOpacity(1.0 - _pulseController.value),
                                    width: 1.5.w,
                                  ),
                                ),
                              ),
                              // Caller avatar
                              Container(
                                width: 130.w,
                                height: 130.h,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.c053A4CA.withOpacity(0.8), width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.c053A4CA.withOpacity(0.3),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(65.r),
                                  child: Obx(() {
                                    final imgUrl = _callController.currentCustomerImage.value;
                                    if (imgUrl.isNotEmpty) {
                                      if (imgUrl.startsWith('http')) {
                                        return Image.network(
                                          imgUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => CircleAvatar(
                                            backgroundColor: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().cardBackground : AppColors.c1C1C28,
                                            child: Icon(Icons.person, size: 60.sp, color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : AppColors.cWhite),
                                          ),
                                        );
                                      } else {
                                        // If local path
                                        return Image.asset(
                                          imgUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => CircleAvatar(
                                            backgroundColor: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().cardBackground : AppColors.c1C1C28,
                                            child: Icon(Icons.person, size: 60.sp, color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : AppColors.cWhite),
                                          ),
                                        );
                                      }
                                    }
                                    return CircleAvatar(
                                      backgroundColor: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().cardBackground : AppColors.c1C1C28,
                                      child: Icon(Icons.person, size: 60.sp, color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : AppColors.cWhite),
                                    );
                                  }),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      
                      SizedBox(height: 24.h),
                      // Caller Details
                      Obx(() => Text(
                        _callController.currentCustomerId.value,
                        style: TextStyle(
                          color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : AppColors.cWhite,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                      SizedBox(height: 6.h),
                      Obx(() => Text(
                        "Interested in tag: #${_callController.currentProduct.value}",
                        style: TextStyle(
                          color: AppColors.c053A4CA,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      )),
                    ],
                  ),
                ),

                // Accept/Reject Button controls
                Padding(
                  padding: EdgeInsets.only(bottom: 60.h),
                  child: Column(
                    children: [
                      Text(
                        "Ringing...",
                        style: TextStyle(
                          color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor.withOpacity(0.5) : AppColors.cWhite.withOpacity(0.5),
                          fontSize: 14.sp,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 36.h),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Reject Button (Red)
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () => _callController.rejectCall(),
                                child: Container(
                                  width: 68.w,
                                  height: 68.h,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.redAccent,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.redAccent,
                                        blurRadius: 15,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Icon(Icons.call_end, color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, size: 28),
                                ),
                              ),
                              SizedBox(height: 10.h),
                              Text("Decline", style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textSecondaryColor : Colors.black54, fontSize: 12.sp)),
                            ],
                          ),

                          // Accept Button (Green)
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () => _callController.acceptCall(),
                                child: Container(
                                  width: 68.w,
                                  height: 68.h,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.greenAccent,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.greenAccent,
                                        blurRadius: 15,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Icon(Icons.call, color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, size: 28),
                                ),
                              ),
                              SizedBox(height: 10.h),
                              Text("Accept", style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textSecondaryColor : Colors.black54, fontSize: 12.sp)),
                            ],
                          ),
                        ],
                      ),
                    ],
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
