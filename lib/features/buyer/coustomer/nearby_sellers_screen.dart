import 'package:bd_shope_combined/controllers/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:bd_shope_combined/common_wigdets/glass_card.dart';
import 'package:bd_shope_combined/common_wigdets/glass_background.dart';
import 'package:bd_shope_combined/helpers/mock_data.dart';

class NearbySellersScreen extends StatelessWidget {
  const NearbySellersScreen({Key? key}) : super(key: key);

  void _callNumber(String phone) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              'Nearby Sellers Map',
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
        child: Column(
          children: [
            // Map Mockup Container
            Expanded(
              flex: 4,
              child: Container(
                margin: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12.withOpacity(0.2)),
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://images.unsplash.com/photo-1524661135-423995f22d0b?q=80&w=600',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: GlassCard(
                  borderRadius: 24.r,
                  color: Colors.black.withOpacity(0.2),
                  padding: EdgeInsets.all(16.r),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 20.h,
                        left: 20.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E38).withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.my_location, color: Color(0xFF53A4CA), size: 16),
                              SizedBox(width: 6.w),
                              Text(
                                'Dhaka, Bangladesh',
                                style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, fontSize: 11.sp),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Fake Pins on the map image
                      Positioned(
                        top: 100.h,
                        left: 140.w,
                        child: Icon(Icons.location_on, color: Colors.red, size: 36.r),
                      ),
                      Positioned(
                        bottom: 80.h,
                        right: 80.w,
                        child: Icon(Icons.location_on, color: const Color(0xFF7953CA), size: 36.r),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Sellers list panel
            Expanded(
              flex: 3,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: MockData.products.length,
                itemBuilder: (context, index) {
                  final product = MockData.products[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 12.h),
                    child: GlassCard(
                      borderRadius: 20.r,
                      padding: EdgeInsets.all(12.r),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20.r,
                            backgroundColor: Colors.white.withOpacity(0.1),
                            child: Icon(Icons.store, color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black),
                          ),
                          SizedBox(width: 14.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.sellerName,
                                  style: GoogleFonts.outfit(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, fontSize: 14.sp, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  'Product: ${product.title}',
                                  style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.6), fontSize: 11.sp),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                product.distance,
                                style: TextStyle(color: Color(0xFF53A4CA), fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 6.h),
                              GestureDetector(
                                onTap: () => _callNumber(product.sellerPhone),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().cardBackground : Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Icon(Icons.phone, size: 14, color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
