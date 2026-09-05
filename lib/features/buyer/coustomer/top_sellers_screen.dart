import 'package:bd_shope_combined/controllers/theme_controller.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:bd_shope_combined/common_wigdets/glass_card.dart';
import 'package:bd_shope_combined/controllers/connection_controller.dart';
import 'package:bd_shope_combined/route/app_pages.dart';

class TopSellersScreen extends StatefulWidget {
  const TopSellersScreen({Key? key}) : super(key: key);

  @override
  State<TopSellersScreen> createState() => _TopSellersScreenState();
}

class _TopSellersScreenState extends State<TopSellersScreen>
    with SingleTickerProviderStateMixin {
  final ConnectionController _ctrl = Get.find<ConnectionController>();
  late TabController _tab;

  final List<String> _filters = [
    'Top Sellers',
    'Top Stores',
    'Top Consultants',
    'Most Active Sellers',
    'Highest Rated Sellers',
  ];

  int _selectedFilter = 0;

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
    _tab = TabController(length: _filters.length, vsync: this);
    _tab.addListener(() {
      if (!_tab.indexIsChanging) setState(() => _selectedFilter = _tab.index);
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Color _levelColor(String level) =>
      _levelColors[level] ?? const Color(0xFF53A4CA);

  IconData _levelIcon(String level) {
    switch (level) {
      case 'Diamond':
        return Icons.diamond_rounded;
      case 'Platinum':
        return Icons.workspace_premium_rounded;
      case 'Gold':
        return Icons.emoji_events_rounded;
      case 'Silver':
        return Icons.military_tech_rounded;
      default:
        return Icons.shield_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.5, -0.8),
                radius: 1.0,
                colors: [
                  const Color(0xFF5369CA).withOpacity(0.2),
                  const Color(0xFF0D0D1A),
                ],
              ),
            ),
          ),
          Column(
            children: [
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: EdgeInsets.all(10.r),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().cardBackground : Colors.white.withOpacity(0.1),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                            size: 18,
                          ),
                        ),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Top Rated Sellers',
                              style: GoogleFonts.outfit(
                                color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'Ranked by performance & reviews',
                              style: GoogleFonts.poppins(
                                color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.45),
                                fontSize: 11.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF7953CA).withOpacity(0.4),
                              const Color(0xFF5369CA).withOpacity(0.3),
                            ],
                          ),
                        ),
                        child: Icon(
                          Icons.emoji_events_rounded,
                          color: const Color(0xFFFFC107),
                          size: 20.r,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 42.h,
                child: TabBar(
                  controller: _tab,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicatorColor: Colors.transparent,
                  dividerColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  labelPadding: EdgeInsets.only(right: 8.w),
                  tabs: List.generate(_filters.length, (i) {
                    final sel = _selectedFilter == i;
                    return Tab(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.r),
                          gradient: sel
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFF7953CA),
                                    Color(0xFF5369CA),
                                  ],
                                )
                              : null,
                          color: sel ? null : Colors.white.withOpacity(0.07),
                          border: Border.all(
                            color: sel
                                ? Colors.transparent
                                : Colors.white.withOpacity(0.15),
                          ),
                        ),
                        child: Text(
                          _filters[i],
                          style: GoogleFonts.poppins(
                            color: sel
                                ? Colors.white
                                : Colors.white.withOpacity(0.55),
                            fontSize: 11.sp,
                            fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              SizedBox(height: 12.h),
              Expanded(
                child: Obx(() {
                  final list = _ctrl.getLeaderboard(_filters[_selectedFilter]);
                  if (list.isEmpty) {
                    return Center(
                      child: Text(
                        'No sellers found',
                        style: GoogleFonts.poppins(
                          color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().iconColor : Colors.black45,
                          fontSize: 14.sp,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    physics: const BouncingScrollPhysics(),
                    itemCount: list.length,
                    itemBuilder: (ctx, i) => _buildSellerTile(list[i], i + 1),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSellerTile(SellerModel seller, int rank) {
    final lc = _levelColor(seller.level);
    final isTop3 = rank <= 3;
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.SELLER_PROFILE, arguments: seller),
      child: Container(
        margin: EdgeInsets.only(bottom: 14.h),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22.r),
                color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12.withOpacity(isTop3 ? 0.07 : 0.04),
                border: Border.all(
                  color: isTop3
                      ? lc.withOpacity(0.35)
                      : Colors.white.withOpacity(0.1),
                  width: isTop3 ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  _rankBadge(rank, lc),
                  SizedBox(width: 14.w),
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 30.r,
                        backgroundImage: NetworkImage(seller.photo),
                        backgroundColor: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 11.r,
                          height: 11.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: seller.status == 'Online'
                                ? Colors.greenAccent
                                : Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12,
                            border: Border.all(
                              color: const Color(0xFF0D0D1A),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 14.w),
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
                              Icon(
                                Icons.verified_rounded,
                                color: const Color(0xFF53A4CA),
                                size: 14.r,
                              ),
                          ],
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          seller.storeName.isNotEmpty
                              ? seller.storeName
                              : seller.specialtyTitle,
                          style: GoogleFonts.poppins(
                            color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.45),
                            fontSize: 10.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 6.h),
                        Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                              size: 12.r,
                            ),
                            SizedBox(width: 3.w),
                            Text(
                              seller.averageRating.toStringAsFixed(1),
                              style: GoogleFonts.poppins(
                                color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Icon(
                              Icons.call_rounded,
                              color: const Color(0xFF53A4CA),
                              size: 11.r,
                            ),
                            SizedBox(width: 3.w),
                            Text(
                              '${seller.successfulCalls} calls',
                              style: GoogleFonts.poppins(
                                color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.55),
                                fontSize: 10.sp,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.r),
                                color: lc.withOpacity(0.15),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _levelIcon(seller.level),
                                    color: lc,
                                    size: 9.r,
                                  ),
                                  SizedBox(width: 3.w),
                                  Text(
                                    seller.level,
                                    style: GoogleFonts.poppins(
                                      color: lc,
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.w600,
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
                  SizedBox(width: 8.w),
                  Column(
                    children: [
                      Text(
                        '${seller.popularityScore.toStringAsFixed(0)}',
                        style: GoogleFonts.outfit(
                          color: lc,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'score',
                        style: GoogleFonts.poppins(
                          color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.35),
                          fontSize: 9.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _rankBadge(int rank, Color color) {
    Widget child;
    if (rank == 1)
      child = Text('🥇', style: TextStyle(fontSize: 20));
    else if (rank == 2)
      child = Text('🥈', style: TextStyle(fontSize: 20));
    else if (rank == 3)
      child = Text('🥉', style: TextStyle(fontSize: 20));
    else
      child = Text(
        '#$rank',
        style: GoogleFonts.outfit(
          color: color,
          fontSize: 13.sp,
          fontWeight: FontWeight.w800,
        ),
      );
    return Container(
      width: 38.w,
      height: 38.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.12),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}
