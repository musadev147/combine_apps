import 'package:bd_shope_combined/controllers/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:bd_shope_combined/route/app_pages.dart';
import 'package:bd_shope_combined/common_wigdets/glass_card.dart';
import 'package:bd_shope_combined/common_wigdets/glass_background.dart';
import 'package:bd_shope_combined/common_wigdets/custom_image_view.dart';
import 'package:bd_shope_combined/helpers/mock_data.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  void _callNumber(String phone) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  void _openWhatsApp(String phone, String productTitle) async {
    final url = "https://wa.me/${phone.replaceAll('+', '')}?text=${Uri.encodeComponent('Hi, is this $productTitle available?')}";
    final Uri launchUri = Uri.parse(url);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryName = Get.arguments as String? ?? 'All Listings';
    
    final filteredProducts = MockData.products.where((p) {
      if (categoryName == 'All Listings') return true;
      return p.category.toLowerCase() == categoryName.toLowerCase();
    }).toList();

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
              categoryName,
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
          child: filteredProducts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined, color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().iconColor : Colors.black45, size: 64.r),
                      SizedBox(height: 16.h),
                      Text(
                        'No Products Found',
                        style: GoogleFonts.outfit(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, fontSize: 18.sp, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'No listings available in this category yet.',
                        style: GoogleFonts.poppins(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.6), fontSize: 13.sp),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16.r),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 14.h),
                      child: GestureDetector(
                        onTap: () {
                          Get.toNamed(Routes.PRODUCT_DETAILS, arguments: product);
                        },
                        child: GlassCard(
                          borderRadius: 20.r,
                          padding: EdgeInsets.all(12.r),
                          child: Row(
                            children: [
                              CustomImageView(
                                imagePath: product.imageUrl,
                                height: 90.h,
                                width: 90.w,
                                radius: BorderRadius.circular(16.r),
                                fit: BoxFit.cover,
                              ),
                              SizedBox(width: 14.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.title,
                                      style: GoogleFonts.outfit(
                                        color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      '\$${product.price.toStringAsFixed(0)}',
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xFF53A4CA),
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 6.h),
                                    Row(
                                      children: [
                                        Icon(Icons.location_on, color: const Color(0xFF53A4CA), size: 14.r),
                                        SizedBox(width: 4.w),
                                        Text(
                                          product.distance,
                                          style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.8), fontSize: 11.sp),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  IconButton(
                                    onPressed: () => _callNumber(product.sellerPhone),
                                    icon: Icon(Icons.phone_outlined, color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black),
                                    style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.08)),
                                  ),
                                  IconButton(
                                    onPressed: () => _openWhatsApp(product.sellerWhatsApp, product.title),
                                    icon: Icon(Icons.chat_bubble_outline, color: Color(0xFF25D366)),
                                    style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.08)),
                                  ),
                                ],
                              ),
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
