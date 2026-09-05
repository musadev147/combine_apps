import 'package:bd_shope_combined/controllers/theme_controller.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:bd_shope_combined/common_wigdets/glass_card.dart';
import 'package:bd_shope_combined/controllers/connection_controller.dart';
import 'package:bd_shope_combined/route/app_pages.dart';

class SellerProfileScreen extends StatefulWidget {
  const SellerProfileScreen({Key? key}) : super(key: key);

  @override
  State<SellerProfileScreen> createState() => _SellerProfileScreenState();
}

class _SellerProfileScreenState extends State<SellerProfileScreen>
    with SingleTickerProviderStateMixin {
  late final SellerModel seller;
  final ConnectionController _ctrl = Get.find<ConnectionController>();
  late TabController _tabController;

  final Map<String, Color> _levelColors = {
    'Diamond': const Color(0xFF53A4CA),
    'Platinum': const Color(0xFF7953CA),
    'Gold': const Color(0xFFFFC107),
    'Silver': const Color(0xFF9E9E9E),
    'Bronze': const Color(0xFFCD7F32),
  };

  @override
  void initState() {
    super.initState();
    seller = Get.arguments as SellerModel;
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color get _levelColor => _levelColors[seller.level] ?? const Color(0xFF53A4CA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -1),
                radius: 1.2,
                colors: [
                  const Color(0xFF7953CA).withOpacity(0.25),
                  const Color(0xFF0D0D1A),
                ],
              ),
            ),
          ),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(child: _buildProfileHeader()),
              SliverToBoxAdapter(child: _buildStatsRow()),
              SliverToBoxAdapter(child: _buildCallButtons()),
              SliverToBoxAdapter(child: _buildTabBar()),
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildTabContent(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── App Bar ──────────────────────────────────────────────────────────────

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      leading: GestureDetector(
        onTap: () => Get.back(),
        child: Container(
          margin: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().cardBackground : Colors.white.withOpacity(0.1),
          ),
          child: Icon(Icons.arrow_back_ios_new_rounded,
              color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, size: 18),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () {},
          child: Container(
            margin: EdgeInsets.all(10.r),
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().cardBackground : Colors.white.withOpacity(0.1),
            ),
            child: Icon(Icons.share_rounded, color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, size: 18),
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: Container(
            margin: EdgeInsets.only(right: 12.w, top: 10.h, bottom: 10.h),
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().cardBackground : Colors.white.withOpacity(0.1),
            ),
            child: Icon(Icons.bookmark_border_rounded,
                color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, size: 18),
          ),
        ),
      ],
    );
  }

  // ─── Profile Header ───────────────────────────────────────────────────────

  Widget _buildProfileHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Column(
        children: [
          // Avatar
          Stack(
            alignment: Alignment.center,
            children: [
              // Glow ring
              Container(
                width: 100.r,
                height: 100.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [
                      _levelColor,
                      _levelColor.withOpacity(0.3),
                      _levelColor,
                    ],
                  ),
                ),
              ),
              Container(
                width: 94.r,
                height: 94.r,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF0D0D1A),
                ),
              ),
              CircleAvatar(
                radius: 42.r,
                backgroundImage: NetworkImage(seller.photo),
                backgroundColor: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12,
              ),
              // Online dot
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  width: 16.r,
                  height: 16.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: seller.status == 'Online'
                        ? Colors.greenAccent
                        : Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12,
                    border: Border.all(
                        color: const Color(0xFF0D0D1A), width: 2),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          // Name + verified
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                seller.name,
                style: GoogleFonts.outfit(
                  color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(width: 6.w),
              if (seller.badges.contains('Verified Seller'))
                Icon(Icons.verified_rounded,
                    color: const Color(0xFF53A4CA), size: 20.r),
            ],
          ),
          SizedBox(height: 4.h),
          // Store name
          Text(
            seller.storeName.isNotEmpty
                ? seller.storeName
                : seller.specialtyTitle,
            style: GoogleFonts.poppins(
              color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.5),
              fontSize: 13.sp,
            ),
          ),
          SizedBox(height: 8.h),
          // Level badge + location
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _levelBadge(),
              SizedBox(width: 10.w),
              Icon(Icons.location_on_rounded,
                  color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().iconColor : Colors.black45, size: 13.r),
              SizedBox(width: 3.w),
              Text(
                seller.location,
                style: GoogleFonts.poppins(
                  color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().iconColor : Colors.black45,
                  fontSize: 11.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // Rating row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...List.generate(5, (i) {
                return Icon(
                  i < seller.averageRating.floor()
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  color: Colors.amber,
                  size: 16.r,
                );
              }),
              SizedBox(width: 6.w),
              Text(
                seller.averageRating.toStringAsFixed(1),
                style: GoogleFonts.poppins(
                  color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                '(${seller.positiveReviewsCount} reviews)',
                style: GoogleFonts.poppins(
                  color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.45),
                  fontSize: 11.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          // Online status badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              color: (seller.status == 'Online'
                      ? Colors.greenAccent
                      : Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12)
                  .withOpacity(0.1),
              border: Border.all(
                color: seller.status == 'Online'
                    ? Colors.greenAccent.withOpacity(0.4)
                    : Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7.r,
                  height: 7.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: seller.status == 'Online'
                        ? Colors.greenAccent
                        : Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().iconColor : Colors.black45,
                  ),
                ),
                SizedBox(width: 6.w),
                Text(
                  seller.status == 'Online'
                      ? 'Available Now'
                      : seller.status,
                  style: GoogleFonts.poppins(
                    color: seller.status == 'Online'
                        ? Colors.greenAccent
                        : Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().iconColor : Colors.black45,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _levelBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: _levelColor.withOpacity(0.15),
        border: Border.all(color: _levelColor.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.workspace_premium_rounded, color: _levelColor, size: 12.r),
          SizedBox(width: 4.w),
          Text(
            seller.level,
            style: GoogleFonts.poppins(
              color: _levelColor,
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Stats Row ────────────────────────────────────────────────────────────

  Widget _buildStatsRow() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: GlassCard(
        borderRadius: 20.r,
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
        color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12.withOpacity(0.04),
        child: Row(
          children: [
            _statItem(seller.completedOrders.toString(), 'Orders'),
            _statDivider(),
            _statItem(seller.successfulCalls.toString(), 'Calls'),
            _statDivider(),
            _statItem('${seller.responseTime} avg', 'Response'),
            _statDivider(),
            _statItem(
                '${(seller.popularityScore).toStringAsFixed(0)}%', 'Score'),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.outfit(
              color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.45),
              fontSize: 10.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statDivider() {
    return Container(
      height: 36.h,
      width: 1,
      color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12.withOpacity(0.1),
    );
  }

  // ─── Call Buttons ─────────────────────────────────────────────────────────

  Widget _buildCallButtons() {
    final isOnline = seller.status == 'Online';
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          // Chat button
          Expanded(
            child: _actionBtn(
              icon: Icons.chat_bubble_outline_rounded,
              label: 'Message',
              color: const Color(0xFF5369CA),
              onTap: () => Get.toNamed(Routes.CHAT, arguments: seller),
            ),
          ),
          SizedBox(width: 10.w),
          // Audio call
          Expanded(
            child: _actionBtn(
              icon: Icons.call_rounded,
              label: 'Audio Call',
              color: const Color(0xFF53A4CA),
              disabled: !isOnline,
              onTap: isOnline
                  ? () {
                      _ctrl.broadcastCallForProduct(
                        name: seller.categories.isNotEmpty
                            ? seller.categories.first
                            : 'Service',
                        category: seller.categories.isNotEmpty
                            ? seller.categories.first
                            : '',
                        callType: 'audio',
                      );
                    }
                  : null,
            ),
          ),
          SizedBox(width: 10.w),
          // Video call
          Expanded(
            child: _actionBtn(
              icon: Icons.videocam_rounded,
              label: 'Video Call',
              color: const Color(0xFF7953CA),
              disabled: !isOnline,
              onTap: isOnline
                  ? () {
                      _ctrl.broadcastCallForProduct(
                        name: seller.categories.isNotEmpty
                            ? seller.categories.first
                            : 'Service',
                        category: seller.categories.isNotEmpty
                            ? seller.categories.first
                            : '',
                        callType: 'video',
                      );
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
    bool disabled = false,
  }) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: AnimatedOpacity(
        opacity: disabled ? 0.4 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.3), color.withOpacity(0.15)],
            ),
            border: Border.all(color: color.withOpacity(0.5), width: 1.2),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22.r),
              SizedBox(height: 4.h),
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.85),
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Tab Bar ──────────────────────────────────────────────────────────────

  Widget _buildTabBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().cardBackground : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12.withOpacity(0.1)),
            ),
            child: TabBar(
              controller: _tabController,
              onTap: (_) => setState(() {}),
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                gradient: const LinearGradient(
                  colors: [Color(0xFF7953CA), Color(0xFF5369CA)],
                ),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().iconColor : Colors.black45,
              labelStyle:
                  GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: 'About'),
                Tab(text: 'Reviews'),
                Tab(text: 'Tags'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: AnimatedBuilder(
        animation: _tabController,
        builder: (_, __) {
          switch (_tabController.index) {
            case 0:
              return _buildAboutTab();
            case 1:
              return _buildReviewsTab();
            case 2:
              return _buildTagsTab();
            default:
              return _buildAboutTab();
          }
        },
      ),
    );
  }

  // ─── About Tab ────────────────────────────────────────────────────────────

  Widget _buildAboutTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoRow(Icons.business_center_rounded, 'Type', seller.type),
        _infoRow(Icons.auto_awesome_rounded, 'Specialty', seller.specialtyTitle),
        _infoRow(Icons.people_alt_rounded, 'Followers',
            '${seller.followers} followers'),
        _infoRow(Icons.speed_rounded, 'Response Time', seller.responseTime),
        SizedBox(height: 16.h),
        Text(
          'Badges',
          style: GoogleFonts.outfit(
            color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 10.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: seller.badges.map((b) => _badgeChip(b)).toList(),
        ),
        SizedBox(height: 40.h),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF5369CA).withOpacity(0.15),
            ),
            child: Icon(icon, color: const Color(0xFF5369CA), size: 16.r),
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.4),
                  fontSize: 10.sp,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _badgeChip(String badge) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: const Color(0xFF53A4CA).withOpacity(0.12),
        border: Border.all(color: const Color(0xFF53A4CA).withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_outlined,
              color: const Color(0xFF53A4CA), size: 12.r),
          SizedBox(width: 5.w),
          Text(
            badge,
            style: GoogleFonts.poppins(
              color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.85),
              fontSize: 10.sp,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Reviews Tab ──────────────────────────────────────────────────────────

  Widget _buildReviewsTab() {
    if (seller.reviews.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.rate_review_outlined,
                  color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12, size: 48.r),
              SizedBox(height: 12.h),
              Text(
                'No reviews yet',
                style: GoogleFonts.poppins(
                  color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().iconColor : Colors.black45,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Column(
      children: [
        ...seller.reviews.map((r) => _reviewTile(r)).toList(),
        SizedBox(height: 40.h),
      ],
    );
  }

  Widget _reviewTile(Map<String, dynamic> r) {
    final stars = (r['stars'] as num).toDouble();
    return GlassCard(
      margin: EdgeInsets.only(bottom: 12.h),
      borderRadius: 16.r,
      padding: EdgeInsets.all(14.r),
      color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12.withOpacity(0.03),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16.r,
                backgroundColor: const Color(0xFF5369CA).withOpacity(0.2),
                child: Text(
                  (r['buyer'] as String).substring(0, 1).toUpperCase(),
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF53A4CA),
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r['buyer'] as String,
                      style: GoogleFonts.outfit(
                        color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      r['date'] as String,
                      style: GoogleFonts.poppins(
                        color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().iconColor : Colors.black45,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (i) {
                  return Icon(
                    i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: Colors.amber,
                    size: 12.r,
                  );
                }),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            r['comment'] as String,
            style: GoogleFonts.poppins(
              color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.7),
              fontSize: 12.sp,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Tags Tab ─────────────────────────────────────────────────────────────

  Widget _buildTagsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Tags',
          style: GoogleFonts.outfit(
            color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          'Buyers can search these tags to find this seller.',
          style: GoogleFonts.poppins(
            color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.45),
            fontSize: 11.sp,
          ),
        ),
        SizedBox(height: 16.h),
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: seller.categories.map((tag) {
            return GestureDetector(
              onTap: () {
                Get.back();
                Get.toNamed(Routes.SEARCH, arguments: tag);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF7953CA).withOpacity(0.25),
                      const Color(0xFF5369CA).withOpacity(0.15),
                    ],
                  ),
                  border: Border.all(
                    color: const Color(0xFF7953CA).withOpacity(0.45),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.tag_rounded,
                        color: const Color(0xFF7953CA), size: 13.r),
                    SizedBox(width: 5.w),
                    Text(
                      tag,
                      style: GoogleFonts.poppins(
                        color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.9),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 40.h),
      ],
    );
  }
}
