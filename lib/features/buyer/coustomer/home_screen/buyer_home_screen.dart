import 'package:bd_shope_combined/controllers/theme_controller.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:bd_shope_combined/route/app_pages.dart';
import 'package:bd_shope_combined/common_wigdets/glass_card.dart';
import 'package:bd_shope_combined/controllers/connection_controller.dart';
import 'package:bd_shope_combined/provider/profile_provider.dart';
import 'package:bd_shope_combined/networks/api_acess.dart';
import 'package:bd_shope_combined/features/buyer/home/home_screen/model/tranding_model.dart';
import 'package:bd_shope_combined/features/buyer/coustomer/data/category_api.dart';
import 'package:bd_shope_combined/features/buyer/coustomer/model/all_catagory_model.dart' as cat_model;
import 'package:bd_shope_combined/features/buyer/coustomer/model/sub_category_model.dart';
import 'package:bd_shope_combined/services/web_socket_service.dart';
import 'package:bd_shope_combined/features/buyer/coustomer/serach/presentation/invoice_section/data/ads_rx.dart';
import 'package:bd_shope_combined/features/buyer/coustomer/serach/presentation/invoice_section/widget/model/get_adds_model.dart';

class BuyerHomeScreen extends StatefulWidget {
  const BuyerHomeScreen({Key? key}) : super(key: key);

  @override
  State<BuyerHomeScreen> createState() => _BuyerHomeScreenState();
}

class _BuyerHomeScreenState extends State<BuyerHomeScreen>
    with SingleTickerProviderStateMixin {
  final ConnectionController _controller = Get.find<ConnectionController>();
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  // Auto Slider for Bikes
  late PageController _pageController;
  int _activePage = 0;
  Timer? _sliderTimer;

  final List<Map<String, dynamic>> _popularTags = [
    {'tag': 'T-Shirt', 'icon': Icons.checkroom, 'count': '127 sellers'},
    {'tag': 'iPhone', 'icon': Icons.phone_iphone, 'count': '89 sellers'},
    {'tag': 'Laptop', 'icon': Icons.laptop, 'count': '64 sellers'},
    {'tag': 'Shoes', 'icon': Icons.storefront, 'count': '102 sellers'},
    {'tag': 'Watch', 'icon': Icons.watch_later_outlined, 'count': '45 sellers'},
    {'tag': 'Cosmetics', 'icon': Icons.face_retouching_natural, 'count': '78 sellers'},
    {'tag': 'Samsung', 'icon': Icons.phone_android, 'count': '55 sellers'},
    {'tag': 'Furniture', 'icon': Icons.chair, 'count': '33 sellers'},
  ];

  final List<String> _trendingTags = [
    'fashion', 'electronics', 'wholesale', 'clothing', 'mobile', 'gaming',
    'apple', 'nike', 'luxury', 'organic',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
    _startAutoSlider();
    getCategoryRx.fetchCategories();
    getTrendingTagsRx.fetchTrendingTags();
    getAdsRx.fetchAds();
  }

  void _startAutoSlider() {
    _sliderTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        int nextPage = _activePage + 1;
        final ads = getAdsRx.valueStreamData.valueOrNull ?? [];
        if (ads.isEmpty) return;
        if (nextPage >= ads.length) {
          nextPage = 0;
        }
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _sliderTimer?.cancel();
    _pageController.dispose();
    _animController.dispose();
    super.dispose();
  }

  IconData _getCategoryIcon(String? name) {
    final lowerName = (name ?? "").toLowerCase();
    if (lowerName.contains("electronics") || lowerName.contains("device")) return Icons.devices;
    if (lowerName.contains("fashion") || lowerName.contains("clothing") || lowerName.contains("dress")) return Icons.checkroom;
    if (lowerName.contains("vehicle") || lowerName.contains("bike") || lowerName.contains("car")) return Icons.directions_car;
    if (lowerName.contains("home") || lowerName.contains("living") || lowerName.contains("furniture")) return Icons.weekend;
    if (lowerName.contains("job") || lowerName.contains("work")) return Icons.work_outline;
    if (lowerName.contains("laptop") || lowerName.contains("computer")) return Icons.laptop;
    if (lowerName.contains("phone") || lowerName.contains("mobile")) return Icons.phone_iphone;
    if (lowerName.contains("cosmetic") || lowerName.contains("beauty")) return Icons.face_retouching_natural;
    if (lowerName.contains("food") || lowerName.contains("organic")) return Icons.restaurant;
    return Icons.category_rounded;
  }

  void _onCategoryTap(BuildContext context, String catId, String catName) async {
    try {
      EasyLoading.show(status: 'Loading sub-categories...');
      final subCategories = await CategoryApi.instance.fetchSubCategories(catId);
      EasyLoading.dismiss();
      _showSubCategoryDialog(context, catName, subCategories);
    } catch (e) {
      EasyLoading.dismiss();
      Get.snackbar(
        "Error",
        "Failed to load sub-categories: $e",
        colorText: Colors.white,
        backgroundColor: Colors.redAccent.withOpacity(0.8),
      );
    }
  }

  void _showSubCategoryDialog(BuildContext context, String categoryName, List<AllSubCategoryModel> subcategories) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().cardBackground : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text(
          "$categoryName Sub-categories",
          style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: 320.w,
          child: subcategories.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      "No sub-categories found.",
                      style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textSecondaryColor : Colors.black54),
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: subcategories.length,
                  itemBuilder: (context, index) {
                    final sub = subcategories[index];
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().cardBackground : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12.withOpacity(0.1)),
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF53A4CA).withOpacity(0.15),
                          ),
                          child: Icon(Icons.tag, color: Color(0xFF53A4CA)),
                        ),
                        title: Text(
                          sub.tagname ?? "",
                          style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, fontWeight: FontWeight.bold),
                        ),
                        trailing: Icon(Icons.phone_in_talk, color: Colors.greenAccent),
                        onTap: () {
                          Get.back();
                          if (sub.region != null && sub.region!.trim().isNotEmpty) {
                            _showRegionSelectionDialog(context, sub);
                          } else {
                            _handleSubCategoryClick(sub);
                          }
                        },
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Close", style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textSecondaryColor : Colors.black54)),
          ),
        ],
      ),
    );
  }

  void _showRegionSelectionDialog(BuildContext context, AllSubCategoryModel sub) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().cardBackground : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text(
          "Select Region for #${sub.tagname}",
          style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "This tag is associated with the following region. Click on it to initiate the call:",
              style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textSecondaryColor : Colors.black54, fontSize: 13),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () {
                Get.back();
                _handleSubCategoryClick(sub);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF53A4CA).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: const Color(0xFF53A4CA)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      sub.region ?? "All Regions",
                      style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, fontWeight: FontWeight.bold),
                    ),
                    Icon(Icons.phone_in_talk, color: Colors.greenAccent),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Cancel", style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textSecondaryColor : Colors.black54)),
          ),
        ],
      ),
    );
  }

  void _handleSubCategoryClick(AllSubCategoryModel sub) {
    if (sub.id != null) {
      try {
        final wsService = Get.find<WebSocketService>();
        wsService.initiateCall(tagId: sub.id!, callType: 'video');
        Get.snackbar(
          "Calling",
          "Initiating call for sub-category: #${sub.tagname}",
          colorText: Colors.white,
          backgroundColor: Colors.green.withOpacity(0.8),
          duration: const Duration(seconds: 4),
        );
      } catch (e) {
        Get.snackbar(
          "Error",
          "Could not start call: $e",
          colorText: Colors.white,
          backgroundColor: Colors.redAccent.withOpacity(0.8),
        );
      }
    }
  }

  Widget _buildCategoriesList() {
    return StreamBuilder<List<cat_model.Results>>(
      stream: getCategoryRx.valueStreamData,
      builder: (context, snapshot) {
        final categoriesList = snapshot.data ?? [];
        final displayList = categoriesList.take(6).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Categories', 'Select a category to view items', Routes.SEARCH),
            SizedBox(height: 14.h),
            displayList.isEmpty
                ? Container(
                    height: 100.h,
                    alignment: Alignment.center,
                    child: Text(
                      "No categories available",
                      style: GoogleFonts.poppins(color: Colors.black54, fontSize: 12.sp),
                    ),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 12.h,
                      crossAxisSpacing: 12.w,
                      childAspectRatio: 0.95,
                    ),
                    itemCount: displayList.length,
                    itemBuilder: (context, index) {
                      final cat = displayList[index];
                      return GlassCard(
                        margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
                        borderRadius: 16.r,
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
                        child: InkWell(
                          onTap: () => _onCategoryTap(context, cat.id ?? "", cat.name ?? ""),
                          borderRadius: BorderRadius.circular(16.r),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(10.r),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF53A4CA).withOpacity(0.15),
                                  border: Border.all(
                                    color: const Color(0xFF53A4CA).withOpacity(0.25),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(_getCategoryIcon(cat.name), color: const Color(0xFF53A4CA), size: 22.r),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                cat.name ?? "",
                                style: GoogleFonts.poppins(
                                  color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black87,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Column(
          children: [
            _buildFixedHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),
                    _buildSearchTrigger(),
                    SizedBox(height: 24.h),
                    _buildAutoSlider(),
                    SizedBox(height: 28.h),
                    _buildCategoriesList(),
                    SizedBox(height: 28.h),
                    _buildSectionHeader('Trending Tags', 'What\'s hot right now', Routes.SEARCH),
                    SizedBox(height: 12.h),
                    _buildTrendingTagsChips(),
                    SizedBox(height: 100.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

    // ─── Auto Slider Widget ───────────────
  Widget _buildAutoSlider() {
    return StreamBuilder<List<GetAdsModel>>(
      stream: getAdsRx.valueStreamData,
      builder: (context, snapshot) {
        final ads = snapshot.data ?? [];
        if (ads.isEmpty) {
          return Container(
            height: 180.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF53A4CA)),
              ),
            ),
          );
        }

        return Container(
          height: 180.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7953CA).withOpacity(0.15),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24.r),
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  onPageChanged: (page) {
                    setState(() {
                      _activePage = page;
                    });
                  },
                  itemCount: ads.length,
                  itemBuilder: (context, index) {
                    final slide = ads[index];
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        slide.image != null && (slide.image!.startsWith('http') || slide.image!.startsWith('https'))
                            ? Image.network(
                                slide.image!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12,
                                  child: Icon(Icons.image_not_supported_outlined, color: Colors.white30, size: 50),
                                ),
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    color: Colors.black12,
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF53A4CA)),
                                      ),
                                    ),
                                  );
                                },
                              )
                            : (slide.image != null && slide.image!.startsWith('file://')
                                ? Image.file(
                                    File.fromUri(Uri.parse(slide.image!)),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12,
                                      child: Icon(Icons.image_not_supported_outlined, color: Colors.white30, size: 50),
                                    ),
                                  )
                                : Container(
                                    color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12,
                                    child: Icon(Icons.image_not_supported_outlined, color: Colors.white30, size: 50),
                                  )),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.85),
                                Colors.black.withOpacity(0.4),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(20.r),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (slide.subtitle != null && slide.subtitle!.isNotEmpty) ...[
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF7953CA), Color(0xFF5369CA)],
                                    ),
                                    borderRadius: BorderRadius.circular(8.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF7953CA).withOpacity(0.4),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    slide.subtitle!.toUpperCase(),
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8.h),
                              ],
                              Text(
                                slide.title ?? '',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (slide.descriptions != null && slide.descriptions!.isNotEmpty) ...[
                                SizedBox(height: 2.h),
                                Text(
                                  slide.descriptions!,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white.withOpacity(0.85),
                                    fontSize: 11.sp,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
                Positioned(
                  bottom: 16.h,
                  right: 20.w,
                  child: Row(
                    children: List.generate(
                      ads.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: EdgeInsets.only(right: 6.w),
                        height: 6.r,
                        width: _activePage == index ? 18.r : 6.r,
                        decoration: BoxDecoration(
                          color: _activePage == index
                              ? const Color(0xFF53A4CA)
                              : Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(3.r),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  // ─── Fixed App Bar Header ────────────────────────────────────────────────
  
  Widget _buildFixedHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().cardBackground : Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.black.withOpacity(0.05), width: 1),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFF7953CA), Color(0xFF53A4CA)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: Text(
                          'Damadami',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 28.sp,
                            letterSpacing: -0.6,
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF4B4B), Color(0xFFFF8533)],
                          ),
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF4B4B).withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6.r,
                              height: 6.r,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'LIVE',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 11.sp,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Search a tag → Talk to sellers instantly',
                    style: GoogleFonts.poppins(
                      color: Get.isRegistered<ThemeController>()
                          ? Get.find<ThemeController>().textSecondaryColor
                          : Colors.black54,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => Get.toNamed(Routes.BUYER_PROFILE),
                child: Consumer<ProfileProvider>(
                  builder: (context, profileProvider, child) {
                    final avatar = profileProvider.avatar;
                    return Container(
                      padding: EdgeInsets.all(2.r),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF53A4CA), width: 1.5),
                      ),
                      child: CircleAvatar(
                        radius: 20.r,
                        backgroundColor: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12,
                        backgroundImage: avatar.startsWith('http')
                            ? NetworkImage(avatar) as ImageProvider
                            : (avatar.startsWith('file://')
                                ? FileImage(File.fromUri(Uri.parse(avatar)))
                                : FileImage(File(avatar))),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOnlinePill(int count) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: Colors.green.withOpacity(0.12),
        border: Border.all(color: Colors.greenAccent.withOpacity(0.35), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _pulseDot(),
          SizedBox(width: 6.w),
          Text(
            '$count Live',
            style: GoogleFonts.poppins(
              color: Colors.greenAccent,
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _pulseDot() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.5, end: 1.0),
      duration: const Duration(milliseconds: 900),
      builder: (_, value, child) => Opacity(opacity: value, child: child),
      child: Container(
        width: 7.r,
        height: 7.r,
        decoration: const BoxDecoration(
          color: Colors.greenAccent,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  // ─── Search Trigger ───────────────────────────────────────────────────────

  Widget _buildSearchTrigger() {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.SEARCH),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.03),
              Colors.black.withOpacity(0.01),
            ],
          ),
          border: Border.all(
            color: const Color(0xFF53A4CA).withOpacity(0.35),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF53A4CA).withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF53A4CA).withOpacity(0.15),
              ),
              child: Icon(Icons.search_rounded,
                  color: const Color(0xFF53A4CA), size: 18.r),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Search by tag...',
                    style: GoogleFonts.poppins(
                      color: Colors.black54,
                      fontSize: 13.sp,
                    ),
                  ),
                  Text(
                    'e.g. T-Shirt, iPhone, Laptop...',
                    style: GoogleFonts.poppins(
                      color: Colors.black38,
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                gradient: const LinearGradient(
                  colors: [Color(0xFF7953CA), Color(0xFF5369CA)],
                ),
              ),
              child: Text(
                'Search',
                style: GoogleFonts.poppins(
                  color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Section Header ───────────────────────────────────────────────────────

  Widget _buildSectionHeader(String title, String subtitle, String route) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.outfit(
                color: Colors.black87,
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                color: Colors.black54,
                fontSize: 11.sp,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => Get.toNamed(route),
          child: Text(
            'See All',
            style: GoogleFonts.poppins(
              color: const Color(0xFF53A4CA),
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ─── Top Sellers Header ───────────────────────────────────────────────
  Widget _buildTopSellersHeader() => _buildSectionHeader('Top Sellers', 'Highest rated performers', Routes.TOP_SELLERS);

  // ─── Online Now Header ───────────────────────────────────────────────
  Widget _buildOnlineNowHeader() => _buildSectionHeader('Online Now', 'Available for instant call', Routes.CHAT);

  // ─── Popular Tags Grid ────────────────────────────────────────────────────

  Widget _buildPopularTagsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12.h,
        crossAxisSpacing: 12.w,
        childAspectRatio: 0.85,
      ),
      itemCount: _popularTags.length,
      itemBuilder: (context, index) {
        final item = _popularTags[index];
        return GestureDetector(
          onTap: () => Get.toNamed(Routes.SEARCH, arguments: item['tag']),
          child: _buildTagTile(item),
        );
      },
    );
  }

  Widget _buildTagTile(Map<String, dynamic> item) {
    final colors = [
      [const Color(0xFF53A4CA), const Color(0xFF5369CA)],
      [const Color(0xFF5369CA), const Color(0xFF7953CA)],
      [const Color(0xFF7953CA), const Color(0xFF53A4CA)],
      [const Color(0xFF53A4CA), const Color(0xFF7953CA)],
    ];
    final colorPair = colors[_popularTags.indexOf(item) % colors.length];

    return GlassCard(
      borderRadius: 16.r,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  colorPair[0].withOpacity(0.25),
                  colorPair[1].withOpacity(0.15),
                ],
              ),
            ),
            child: Icon(item['icon'] as IconData,
                color: colorPair[0], size: 16.r),
          ),
          SizedBox(height: 4.h),
          Text(
            item['tag'] as String,
            style: GoogleFonts.poppins(
              color: Colors.black87,
              fontSize: 9.5.sp,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),
          Text(
            item['count'] as String,
            style: GoogleFonts.poppins(
              color: Colors.black54,
              fontSize: 8.sp,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─── Trending Tags Chips ──────────────────────────────────────────────────

  Widget _buildTrendingTagsChips() {
    return StreamBuilder<List<TrandingModel>>(
      stream: getTrendingTagsRx.valueStreamData,
      builder: (context, snapshot) {
        final trendingList = snapshot.data ?? [];
        if (trendingList.isEmpty) {
          return SizedBox(
            height: 36.h,
            child: Center(
              child: Text(
                "No trending tags available",
                style: GoogleFonts.poppins(color: Colors.black54, fontSize: 11.sp),
              ),
            ),
          );
        }
        return SizedBox(
          height: 36.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: trendingList.length,
            separatorBuilder: (_, __) => SizedBox(width: 8.w),
            itemBuilder: (context, index) {
              final tag = trendingList[index];
              return GestureDetector(
                onTap: () => Get.toNamed(Routes.SEARCH, arguments: tag.tagname),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.r),
                    color: Colors.black.withOpacity(0.04),
                    border: Border.all(
                      color: const Color(0xFF5369CA).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.trending_up_rounded,
                          color: const Color(0xFF5369CA), size: 13.r),
                      SizedBox(width: 5.w),
                      Text(
                        '#${tag.tagname ?? ""}',
                        style: GoogleFonts.poppins(
                          color: Colors.black87,
                          fontSize: 11.5.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ─── Top Sellers List ─────────────────────────────────────────────────────

  Widget _buildTopSellersList() {
    return Obx(() {
      final top = _controller.getLeaderboard('Top Sellers').take(5).toList();
      return SizedBox(
        height: 190.h,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: top.length,
          separatorBuilder: (_, __) => SizedBox(width: 14.w),
          itemBuilder: (context, index) {
            final seller = top[index];
            return GestureDetector(
              onTap: () =>
                  Get.toNamed(Routes.SELLER_PROFILE, arguments: seller),
              child: _buildSellerCard(seller, rank: index + 1),
            );
          },
        ),
      );
    });
  }

  Widget _buildSellerCard(SellerModel seller, {int rank = 0}) {
    final levelColors = {
      'Diamond': const Color(0xFF53A4CA),
      'Platinum': const Color(0xFF7953CA),
      'Gold': const Color(0xFFFFC107),
      'Silver': const Color(0xFF9E9E9E),
      'Bronze': const Color(0xFFCD7F32),
    };
    final levelColor = levelColors[seller.level] ?? const Color(0xFF53A4CA);

    return GlassCard(
      borderRadius: 20.r,
      padding: EdgeInsets.all(14.r),
      child: SizedBox(
        width: 140.w,
        child: Column(
          children: [
            // Avatar + Rank Badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 32.r,
                  backgroundImage: NetworkImage(seller.photo),
                  onBackgroundImageError: (_, __) {},
                  backgroundColor: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12,
                ),
                if (rank > 0)
                  Positioned(
                    top: -6,
                    right: -6,
                    child: Container(
                      width: 22.r,
                      height: 22.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7953CA), Color(0xFF5369CA)],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '#$rank',
                          style: TextStyle(
                            color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                            fontSize: 8.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8.h),
            // Name
            Text(
              seller.name,
              style: GoogleFonts.outfit(
                color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            // Level badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                color: levelColor.withOpacity(0.18),
                border: Border.all(color: levelColor.withOpacity(0.4)),
              ),
              child: Text(
                seller.level,
                style: GoogleFonts.poppins(
                  color: levelColor,
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 8.h),
            // Rating row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star_rounded, color: Colors.amber, size: 13.r),
                SizedBox(width: 3.w),
                Text(
                  seller.averageRating.toStringAsFixed(1),
                  style: GoogleFonts.poppins(
                    color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 4.w),
                Text(
                  '(${seller.positiveReviewsCount})',
                  style: GoogleFonts.poppins(
                    color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.45),
                    fontSize: 9.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            // Online indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 6.r,
                  height: 6.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: seller.status == 'Online'
                        ? Colors.greenAccent
                        : Colors.white30,
                  ),
                ),
                SizedBox(width: 4.w),
                Text(
                  seller.status,
                  style: GoogleFonts.poppins(
                    color: seller.status == 'Online'
                        ? Colors.greenAccent
                        : Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().iconColor : Colors.black45,
                    fontSize: 9.sp,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Online Sellers List ──────────────────────────────────────────────────

  Widget _buildOnlineSellersList() {
    return Obx(() {
      final online =
          _controller.sellers.where((s) => s.status == 'Online').toList();
      if (online.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: Text(
              'No sellers online right now',
              style: GoogleFonts.poppins(
                color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.4),
                fontSize: 13.sp,
              ),
            ),
          ),
        );
      }
      return Column(
        children: online
            .map((seller) => _buildOnlineSellerTile(seller))
            .toList(),
      );
    });
  }

  Widget _buildOnlineSellerTile(SellerModel seller) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.SELLER_PROFILE, arguments: seller),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        child: GlassCard(
          borderRadius: 18.r,
          padding: EdgeInsets.all(14.r),
          child: Row(
            children: [
              // Avatar + online dot
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28.r,
                    backgroundImage: NetworkImage(seller.photo),
                    backgroundColor: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12.r,
                      height: 12.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.greenAccent,
                        border: Border.all(color: Colors.black26, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 14.w),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            seller.name,
                            style: GoogleFonts.outfit(
                              color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (seller.badges.contains('Verified Seller'))
                          Icon(Icons.verified_rounded,
                              color: const Color(0xFF53A4CA), size: 14.r),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      seller.storeName.isNotEmpty
                          ? seller.storeName
                          : seller.specialtyTitle,
                      style: GoogleFonts.poppins(
                        color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.5),
                        fontSize: 10.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    // Tags preview
                    Wrap(
                      spacing: 4.w,
                      children: seller.categories.take(3).map((c) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6.r),
                            color: const Color(0xFF5369CA).withOpacity(0.15),
                          ),
                          child: Text(
                            '#$c',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF53A4CA),
                              fontSize: 8.sp,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              // Call Buttons
              Column(
                children: [
                  _miniCallBtn(Icons.call_rounded, const Color(0xFF53A4CA),
                      () => _startDirectCall(seller, 'audio')),
                  SizedBox(height: 8.h),
                  _miniCallBtn(Icons.videocam_rounded, const Color(0xFF7953CA),
                      () => _startDirectCall(seller, 'video')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniCallBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.15),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Icon(icon, color: color, size: 16.r),
      ),
    );
  }

  void _startDirectCall(SellerModel seller, String type) {
    _controller.broadcastCallForProduct(
      name: seller.categories.isNotEmpty ? seller.categories.first : 'Service',
      category: seller.categories.isNotEmpty ? seller.categories.first : '',
      callType: type,
    );
  }
}
