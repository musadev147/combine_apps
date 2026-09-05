import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:bd_shope_combined/route/app_pages.dart';
import 'package:bd_shope_combined/common_wigdets/glass_card.dart';
import 'package:bd_shope_combined/common_wigdets/glass_text_field.dart';
import 'package:bd_shope_combined/controllers/connection_controller.dart';
import 'package:bd_shope_combined/common_wigdets/glass_background.dart';
import 'package:bd_shope_combined/networks/api_acess.dart';
import 'package:bd_shope_combined/controllers/theme_controller.dart';
import 'model/search_model.dart';
import 'package:bd_shope_combined/features/buyer/home/home_screen/model/tranding_model.dart';

class TagSuggestionItem {
  final String name;
  final String? id;
  TagSuggestionItem({required this.name, this.id});
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final ConnectionController _connectionController = Get.find<ConnectionController>();

  String _searchQuery = '';
  List<EcommerceProduct> _searchResults = [];
  bool _hasSearched = false;
  StreamSubscription? _callStateSubscription;
  Timer? _debounce;

  final List<String> _trendingTags = [
    't-shirt', 'shoes', 'laptop', 'lipstick', 'apple', 'nike'
  ];

  @override
  void initState() {
    super.initState();
    // Fetch initial tags from searchTag API and trending tags
    getSerachTagRx.searchTag(query: '');
    getTrendingTagsRx.fetchTrendingTags();
    _searchController.addListener(_onSearchChanged);

    // Listen to callState changes to auto-refresh results when the call ends
    _callStateSubscription = _connectionController.callState.listen((state) {
      if (state == 'idle' || state == 'ended') {
        getSerachTagRx.searchTag(query: _searchController.text);
        if (mounted) {
          setState(() {});
        }
      }
    });

    // Check if arguments were passed (e.g., from Categories or Popular Tags)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.arguments != null && Get.arguments is String) {
        final prefilledQuery = Get.arguments as String;
        _searchController.text = prefilledQuery;
        _performProductSearch(prefilledQuery);
      }
    });
  }

  void _onSearchChanged() {
    getSerachTagRx.clean();
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      getSerachTagRx.searchTag(query: _searchController.text);
    });
    setState(() {
      if (_hasSearched) {
        _hasSearched = false;
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _callStateSubscription?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    getSerachTagRx.clean();
    super.dispose();
  }


  String? _getTagId(String query) {
    final list = getSerachTagRx.valueStreamData.valueOrNull;
    if (list != null) {
      for (var t in list) {
        if (t.tagname?.toLowerCase() == query.toLowerCase().trim()) {
          return t.id;
        }
      }
    }
    return null;
  }

  void _performProductSearch(String query, {String? tagId}) {
    if (query.trim().isEmpty) return;
    _connectionController.broadcastCallForTag(
      tag: query.trim(),
      callType: 'video',
      tagId: tagId ?? _getTagId(query),
    );
  }

  void _showCallConfirmationDialog(String query) {
    final lowercaseQuery = query.toLowerCase().trim();
    final onlineCount = _connectionController.sellers.where((s) {
      final matchesCategory = s.categories.any(
        (cat) => cat.toLowerCase().contains(lowercaseQuery),
      );
      return s.status == 'Online' && matchesCategory;
    }).length;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: const Color(0xFF1E1E38).withOpacity(0.95),
            border: Border.all(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12.withOpacity(0.15)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.video_call_outlined, color: const Color(0xFF53A4CA), size: 44.r),
              const SizedBox(height: 16),
              Text(
                'Start Tag Call?',
                style: GoogleFonts.outfit(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Do you want to broadcast a call to $onlineCount online specialists matching the tag "#$query"?',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.7), fontSize: 12.sp, height: 1.4),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12.withOpacity(0.2)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Get.back();
                        setState(() {
                          _searchQuery = query;
                          _searchResults = [];
                          _hasSearched = true;
                        });
                      },
                      child: Text('No, Show List', style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.7))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7953CA),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Get.back();
                        _connectionController.broadcastCallForTag(
                          tag: query.trim(),
                          callType: 'video',
                          tagId: _getTagId(query),
                        );
                        setState(() {
                          _searchQuery = query;
                          _searchResults = [];
                          _hasSearched = true;
                        });
                      },
                      child: Text('Yes, Call Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: Container(
          decoration: BoxDecoration(
            // Gradient removed for transparent appbar
            border: Border(
              bottom: BorderSide(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12.withOpacity(0.1), width: 1.5),
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
              'Search Marketplace',
              style: GoogleFonts.outfit(
                color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: 20.sp,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input Row
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Row(
                children: [
                  Expanded(
                    child: GlassTextField(
                      controller: _searchController,
                      hintText: 'Search tag to call online sellers...',
                      prefixIcon: Icon(Icons.search, color: Color(0xFF53A4CA)),
                      textInputAction: TextInputAction.search,
                      onFieldSubmitted: (value) => _performProductSearch(value),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: () => _performProductSearch(_searchController.text),
                    child: Container(
                      height: 52.h,
                      width: 52.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF7953CA).withOpacity(0.2),
                        border: Border.all(color: const Color(0xFF7953CA).withOpacity(0.4), width: 1.5),
                      ),
                      child: Icon(Icons.arrow_forward, color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black),
                    ),
                  ),
                ],
              ),
            ),

            // Suggestions OR Products list
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: !_hasSearched ? _buildSuggestions() : _buildSearchResults(),
              ),
            ),
          ],
        ),
      ),

    ),
    );
  }

  Widget _buildSuggestions() {
    final tc = Get.isRegistered<ThemeController>() ? Get.find<ThemeController>() : null;
    final textColor = tc?.textColor ?? Colors.white;
    final iconColor = tc?.iconColor ?? Colors.white;

    return StreamBuilder<List<GetSerachModel>>(
      stream: getSerachTagRx.valueStreamData,
      builder: (context, searchSnapshot) {
        return StreamBuilder<List<TrandingModel>>(
          stream: getTrendingTagsRx.valueStreamData,
          builder: (context, trendingSnapshot) {
            final isSearching = _searchController.text.trim().isNotEmpty;
            final hasSearchData = searchSnapshot.hasData && searchSnapshot.data!.isNotEmpty;
            
            final List<TagSuggestionItem> tags;
            if (isSearching) {
              final query = _searchController.text.toLowerCase().trim();
              if (hasSearchData) {
                tags = searchSnapshot.data!
                    .where((m) => m.tagname != null && m.tagname!.isNotEmpty)
                    .map((m) => TagSuggestionItem(name: m.tagname!, id: m.id))
                    .toList();
              } else {
                final List<TagSuggestionItem> allAvailableTags = [];
                if (trendingSnapshot.hasData) {
                  allAvailableTags.addAll(trendingSnapshot.data!
                      .where((m) => m.tagname != null && m.tagname!.isNotEmpty)
                      .map((m) => TagSuggestionItem(name: m.tagname!, id: m.id)));
                }
                allAvailableTags.addAll(_trendingTags.map((t) => TagSuggestionItem(name: t)));
                
                final seenNames = <String>{};
                tags = [];
                for (var item in allAvailableTags) {
                  final lowerName = item.name.toLowerCase();
                  if (lowerName.contains(query) && !seenNames.contains(lowerName)) {
                    seenNames.add(lowerName);
                    tags.add(item);
                  }
                }
              }
            } else {
              final trendingData = trendingSnapshot.data ?? [];
              final List<TagSuggestionItem> allAvailableTags = [];
              allAvailableTags.addAll(trendingData
                  .where((m) => m.tagname != null && m.tagname!.isNotEmpty)
                  .map((m) => TagSuggestionItem(name: m.tagname!, id: m.id)));
              allAvailableTags.addAll(_trendingTags.map((t) => TagSuggestionItem(name: t)));
              
              final seenNames = <String>{};
              tags = [];
              for (var item in allAvailableTags) {
                final lowerName = item.name.toLowerCase();
                if (!seenNames.contains(lowerName)) {
                  seenNames.add(lowerName);
                  tags.add(item);
                }
              }
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.h),
                Text(
                  isSearching ? 'Matching Tags' : 'Trending Tags',
                  style: GoogleFonts.outfit(color: textColor, fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12.h),
                Wrap(
                  spacing: 10.w,
                  runSpacing: 10.h,
                  children: tags.map((tag) {
                    return ActionChip(
                      label: Text('#${tag.name}'),
                      onPressed: () {
                        _searchController.text = tag.name;
                        _performProductSearch(tag.name, tagId: tag.id);
                      },
                      backgroundColor: const Color(0xFF7953CA),
                      labelStyle: GoogleFonts.poppins(color: Colors.white, fontSize: 13.sp),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                        side: BorderSide(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12.withOpacity(0.6)),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    );
                  }).toList(),
                ),
                SizedBox(height: 50.h),
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.video_call_outlined, size: 64.r, color: iconColor.withOpacity(0.4)),
                      SizedBox(height: 16.h),
                      Text(
                        'Live Video Consultation',
                        style: GoogleFonts.outfit(color: textColor.withOpacity(0.8), fontSize: 18.sp, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Type a tag (e.g. shirt, laptop) to broadcast a live call to all matching online specialists immediately!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(color: textColor.withOpacity(0.6), fontSize: 12.sp, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        );
      }
    );
  }

  Widget _buildSearchResults() {
    final tc = Get.isRegistered<ThemeController>() ? Get.find<ThemeController>() : null;
    final textColor = tc?.textColor ?? Colors.white;
    final iconColor = tc?.iconColor ?? Colors.white;

    final lowercaseQuery = _searchQuery.toLowerCase().trim();
    final matchingSellers = _connectionController.sellers.where((s) {
      final matchesCategory = s.categories.any(
        (cat) => cat.toLowerCase().contains(lowercaseQuery),
      );
      final matchesName = s.name.toLowerCase().contains(lowercaseQuery);
      final matchesStore = s.storeName.toLowerCase().contains(lowercaseQuery);
      return matchesCategory || matchesName || matchesStore;
    }).toList();

    if (matchingSellers.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: Column(
            children: [
              Icon(Icons.sentiment_dissatisfied_outlined, size: 64.r, color: iconColor.withOpacity(0.4)),
              SizedBox(height: 16.h),
              Text(
                'No Online Specialists Found',
                style: GoogleFonts.outfit(color: textColor, fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              Text(
                'Try checking spelling or search another category tag.',
                style: GoogleFonts.poppins(color: textColor.withOpacity(0.6), fontSize: 13.sp),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Matching Specialists (#$_searchQuery)',
              style: GoogleFonts.outfit(color: textColor, fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            Obx(() {
              final isBroadcasting = _connectionController.callState.value == 'broadcasting';
              return Text(
                isBroadcasting ? 'Broadcasting...' : 'Ready to Call',
                style: GoogleFonts.poppins(
                  color: isBroadcasting ? Colors.greenAccent : textColor.withOpacity(0.6),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              );
            }),
          ],
        ),
        SizedBox(height: 12.h),
        Obx(() {
          // Re-evaluate list using Obx to update when statuses change
          final updatedSellers = _connectionController.sellers.where((s) {
            final matchesCategory = s.categories.any(
              (cat) => cat.toLowerCase().contains(lowercaseQuery),
            );
            final matchesName = s.name.toLowerCase().contains(lowercaseQuery);
            final matchesStore = s.storeName.toLowerCase().contains(lowercaseQuery);
            return matchesCategory || matchesName || matchesStore;
          }).toList();

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: updatedSellers.length,
            itemBuilder: (context, index) {
              final seller = updatedSellers[index];
              final isSellerOnline = seller.status == 'Online';
              final isSellerInCall = seller.status == 'In Call';

              return Container(
                margin: EdgeInsets.only(bottom: 14.h),
                child: GlassCard(
                  borderRadius: 22.r,
                  padding: EdgeInsets.all(12.r),
                  child: Row(
                    children: [
                      // Seller Photo
                      Container(
                        height: 70.h,
                        width: 70.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.r),
                          image: DecorationImage(
                            image: NetworkImage(seller.photo),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(width: 14.w),
                      
                      // Seller details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              seller.name,
                              style: GoogleFonts.outfit(color: textColor, fontSize: 15.sp, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              seller.storeName.isNotEmpty ? seller.storeName : seller.specialtyTitle,
                              style: GoogleFonts.poppins(color: textColor.withOpacity(0.55), fontSize: 11.sp),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 6.h),
                            Row(
                              children: [
                                // Online status dot
                                Container(
                                  width: 8.r,
                                  height: 8.r,
                                  decoration: BoxDecoration(
                                    color: isSellerOnline
                                        ? Colors.greenAccent
                                        : (isSellerInCall ? Colors.amberAccent : Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  isSellerOnline
                                      ? 'Online'
                                      : (isSellerInCall ? 'In Call' : 'Offline'),
                                  style: TextStyle(
                                    color: isSellerOnline
                                        ? Colors.greenAccent
                                        : (isSellerInCall ? Colors.amberAccent : textColor.withOpacity(0.6)),
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Icon(Icons.star, color: Colors.amber, size: 12),
                                SizedBox(width: 4.w),
                                Text(
                                  seller.averageRating.toString(),
                                  style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 10.sp),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Call Button
                      GestureDetector(
                        onTap: () {
                          if (isSellerOnline) {
                            _connectionController.broadcastCallForTag(
                              tag: _searchQuery,
                              callType: 'video',
                              tagId: _getTagId(_searchQuery),
                            );
                          } else {
                            Get.snackbar(
                              'Seller Unavailable',
                              'This seller is currently not online to receive calls.',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.white.withOpacity(0.15),
                              colorText: Colors.white,
                            );
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                          decoration: BoxDecoration(
                            color: isSellerOnline 
                                ? const Color(0xFF7953CA).withOpacity(0.2)


                                : Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: isSellerOnline 
                                  ? const Color(0xFF7953CA).withOpacity(0.5)
                                  : Colors.white.withOpacity(0.15),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.video_call,
                                color: isSellerOnline ? const Color(0xFF53A4CA) : iconColor.withOpacity(0.4),
                                size: 20.r,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                'Call',
                                style: GoogleFonts.poppins(
                                  color: isSellerOnline ? Colors.white : textColor.withOpacity(0.4),
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  void _showConsultationDialog(EcommerceProduct product) {
    final onlineCount = _connectionController.sellers.where((s) => s.status == 'Online' && s.categories.contains(product.category)).length;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: const Color(0xFF1E1E38).withOpacity(0.95),
            border: Border.all(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12.withOpacity(0.15)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.video_call_outlined, color: const Color(0xFF53A4CA), size: 44.r),
              const SizedBox(height: 16),
              Text(
                'Talk To Seller',
                style: GoogleFonts.outfit(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Launch a live call broadcast to ping all $onlineCount online specialists in the "${product.category}" category. First seller to accept connects to you instantly!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.7), fontSize: 12.sp, height: 1.4),
              ),
              const SizedBox(height: 16),
              
              // Online sellers count
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$onlineCount sellers online',
                      style: TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12.withOpacity(0.2)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => Get.back(),
                      child: Text('Cancel', style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.7))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7953CA),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Get.back();
                        _connectionController.broadcastCallForProduct(
                          name: product.title,
                          category: product.category,
                          callType: 'video',
                        );
                      },
                      child: Text('Start Call', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
