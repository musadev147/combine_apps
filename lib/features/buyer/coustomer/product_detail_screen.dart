import 'package:bd_shope_combined/controllers/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:bd_shope_combined/route/app_pages.dart';
import 'package:bd_shope_combined/common_wigdets/glass_background.dart';
import 'package:bd_shope_combined/common_wigdets/glass_card.dart';
import 'package:bd_shope_combined/controllers/connection_controller.dart';
import 'package:bd_shope_combined/features/buyer/chat/controllers/chat_controller.dart';
import 'package:bd_shope_combined/features/buyer/chat/models/conversation.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({Key? key}) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late EcommerceProduct _product;
  final ConnectionController _connectionController = Get.find<ConnectionController>();
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    // Retrieve product argument or default
    if (Get.arguments != null && Get.arguments is EcommerceProduct) {
      _product = Get.arguments as EcommerceProduct;
    } else {
      _product = _connectionController.products.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Similar products
    final similarProducts = _connectionController.products
        .where((p) => p.category == _product.category && p.id != _product.id)
        .toList();

    // Seller details
    final seller = _connectionController.sellers.firstWhereOrNull((s) => s.id == _product.sellerId);
    final isSellerOnline = seller?.status == 'Online';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlassBackground(
        child: Column(
          children: [
            // Custom translucent App Bar
            SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(Icons.arrow_back_ios, color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black),
                      style: IconButton.styleFrom(backgroundColor: Colors.black26),
                    ),
                    IconButton(
                      onPressed: () {
                        if (seller != null) {
                          final chatController = Get.find<ChatController>();
                          var existing = chatController.conversations.firstWhereOrNull((c) => c.otherUserId == seller.id);
                          if (existing == null) {
                            existing = ConversationModel(
                              id: 'conv_${seller.id}',
                              otherUserId: seller.id,
                              otherUserName: seller.name,
                              otherUserAvatar: seller.photo,
                              otherUserRole: seller.level,
                              storeName: seller.storeName,
                              isOnline: seller.status == 'Online',
                              messages: [],
                            );
                            chatController.conversations.add(existing);
                          }
                          chatController.selectConversation(existing);
                          Get.toNamed(Routes.CHAT);
                        }
                      },
                      icon: Icon(Icons.chat_bubble_outline, color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black),
                      style: IconButton.styleFrom(backgroundColor: Colors.black26),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product image
                    Container(
                      height: 240.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24.r),
                        image: DecorationImage(
                          image: NetworkImage(_product.imageUrl),
                          fit: BoxFit.cover,
                        ),
                        border: Border.all(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12.withOpacity(0.15)),
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Primary info card
                    GlassCard(
                      borderRadius: 24.r,
                      padding: EdgeInsets.all(16.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF7953CA).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(color: const Color(0xFF7953CA).withOpacity(0.3)),
                                ),
                                child: Text(
                                  _product.category,
                                  style: GoogleFonts.poppins(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, fontSize: 11.sp, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(Icons.star, color: Colors.amber, size: 16.r),
                                  SizedBox(width: 4.w),
                                  Text(
                                    _product.rating.toString(),
                                    style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, fontSize: 13.sp, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            _product.title,
                            style: GoogleFonts.outfit(
                              color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '\$${_product.price.toStringAsFixed(2)}',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF53A4CA),
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: isSellerOnline ? Colors.greenAccent.withOpacity(0.15) : Colors.white.withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 6.r,
                                      height: 6.r,
                                      decoration: BoxDecoration(
                                        color: isSellerOnline ? Colors.greenAccent : Colors.white30,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    SizedBox(width: 6.w),
                                    Text(
                                      isSellerOnline ? 'CONSULT NOW' : 'OFFLINE',
                                      style: GoogleFonts.poppins(
                                        color: isSellerOnline ? Colors.greenAccent : Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().iconColor : Colors.black45,
                                        fontSize: 9.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Description card
                    GlassCard(
                      borderRadius: 24.r,
                      padding: EdgeInsets.all(16.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Product Details',
                            style: GoogleFonts.outfit(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, fontSize: 16.sp, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            _product.description,
                            style: GoogleFonts.poppins(
                              color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.7),
                              fontSize: 13.sp,
                              height: 1.6,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Product Tags',
                            style: GoogleFonts.outfit(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, fontSize: 13.sp, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8.h),
                          Wrap(
                            spacing: 8.w,
                            runSpacing: 8.h,
                            children: _product.tags.map((tag) {
                              return GestureDetector(
                                onTap: () => Get.toNamed(Routes.SEARCH, arguments: tag),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                  decoration: BoxDecoration(
                                    color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().cardBackground : Colors.white.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12.withOpacity(0.1)),
                                  ),
                                  child: Text(
                                    '#$tag',
                                    style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.9), fontSize: 11.sp),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Delivery Information Card
                    GlassCard(
                      borderRadius: 24.r,
                      padding: EdgeInsets.all(16.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.local_shipping_outlined, color: const Color(0xFF53A4CA), size: 22.r),
                              SizedBox(width: 10.w),
                              Text(
                                'Delivery Information',
                                style: GoogleFonts.outfit(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, fontSize: 16.sp, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            _product.deliveryInfo,
                            style: GoogleFonts.poppins(
                              color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.7),
                              fontSize: 12.sp,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Live Consultation Trigger Panel
                    GlassCard(
                      borderRadius: 24.r,
                      padding: EdgeInsets.all(16.r),
                      color: isSellerOnline 
                          ? const Color(0xFF5369CA).withOpacity(0.15)
                          : Colors.white.withOpacity(0.05),
                      border: Border.all(
                        color: isSellerOnline 
                            ? const Color(0xFF5369CA).withOpacity(0.4)
                            : Colors.white.withOpacity(0.15),
                        width: 1.5,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 24.r,
                                backgroundImage: NetworkImage(seller?.photo ?? 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=200'),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _product.sellerName,
                                      style: GoogleFonts.outfit(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, fontSize: 16.sp, fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      seller?.location ?? 'Dhaka, Bangladesh',
                                      style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.6), fontSize: 11.sp),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSellerOnline)
                                Icon(Icons.verified, color: Colors.blueAccent, size: 20),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            isSellerOnline 
                                ? 'Seller is active online! Click below to launch a live video call/audio broadcast for product consultation.' 
                                : 'Seller is currently offline. You can still order, but live video consultation is unavailable.',
                            style: GoogleFonts.poppins(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.7), fontSize: 11.sp, height: 1.4),
                          ),
                          SizedBox(height: 20.h),
                          
                          // Call consultation buttons
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    _startCallBroadcast('audio');
                                  },
                                  icon: Icon(Icons.phone),
                                  label: Text('Audio Call'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isSellerOnline ? const Color(0xFF53A4CA) : Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                                    padding: EdgeInsets.symmetric(vertical: 12.h),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    _startCallBroadcast('video');
                                  },
                                  icon: Icon(Icons.videocam),
                                  label: Text('Video Call'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isSellerOnline ? const Color(0xFF7953CA) : Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                                    padding: EdgeInsets.symmetric(vertical: 12.h),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Add to Cart Button (Marketplace)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _connectionController.addToCart(_product);
                        },
                        icon: Icon(Icons.shopping_bag_outlined),
                        label: Text(
                          'Add to Shopping Cart',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5369CA),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                        ),
                      ),
                    ),
                    SizedBox(height: 28.h),

                    // Similar Products
                    if (similarProducts.isNotEmpty) ...[
                      Text(
                        'Similar Listings',
                        style: GoogleFonts.outfit(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, fontSize: 18.sp, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 12.h),
                      SizedBox(
                        height: 160.h,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: similarProducts.length,
                          itemBuilder: (context, index) {
                            final sp = similarProducts[index];
                            return GestureDetector(
                              onTap: () {
                                Get.offAndToNamed(Routes.PRODUCT_DETAILS, arguments: sp);
                              },
                              child: Container(
                                margin: EdgeInsets.only(right: 12.w),
                                width: 140.w,
                                child: GlassCard(
                                  borderRadius: 16.r,
                                  padding: EdgeInsets.all(8.r),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10.r),
                                            image: DecorationImage(
                                              image: NetworkImage(sp.imageUrl),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 6.h),
                                      Text(
                                        sp.title,
                                        style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, fontSize: 12.sp, fontWeight: FontWeight.w600),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        '\$${sp.price.toStringAsFixed(0)}',
                                        style: TextStyle(color: const Color(0xFF53A4CA), fontSize: 12.sp, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startCallBroadcast(String callType) {
    final onlineCount = _connectionController.sellers.where((s) => s.status == 'Online' && s.categories.contains(_product.category)).length;
    
    if (onlineCount == 0) {
      Get.snackbar(
        'Seller Offline',
        'No matching sellers are online to consult this product category right now.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent.withOpacity(0.85),
        colorText: Colors.white,
      );
      return;
    }

    _connectionController.broadcastCallForProduct(
      name: _product.title,
      category: _product.category,
      callType: callType,
    );
  }
}
