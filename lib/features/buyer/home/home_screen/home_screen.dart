import 'package:bd_shope_combined/controllers/theme_controller.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:bd_shope_combined/common_wigdets/glass_background.dart';
import 'package:bd_shope_combined/constants/app_colors.dart';

import 'package:get/get.dart';

// Import all sub-screens for navigation
import 'package:bd_shope_combined/features/buyer/coustomer/buyer_profile_screen.dart';
import 'package:bd_shope_combined/features/buyer/coustomer/home_screen/buyer_home_screen.dart';
import 'package:bd_shope_combined/features/buyer/coustomer/serach/presentation/invoice_section/notifications_screen.dart';
import 'package:bd_shope_combined/features/buyer/coustomer/serach/presentation/search_screen.dart';
import 'package:bd_shope_combined/features/buyer/home/call_overlay.dart';
import 'package:bd_shope_combined/networks/api_acess.dart';
import 'package:bd_shope_combined/services/web_socket_service.dart';
import 'package:bd_shope_combined/services/agora_service.dart';
import 'package:bd_shope_combined/controllers/connection_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _initBuyerServices();
  }

  void _initBuyerServices() {
    if (!Get.isRegistered<WebSocketService>()) {
      Get.put(WebSocketService(), permanent: true);
    }
    if (!Get.isRegistered<AgoraService>()) {
      Get.put(AgoraService(), permanent: true);
    }
    if (!Get.isRegistered<ConnectionController>()) {
      Get.put(ConnectionController(), permanent: true);
    }
    Get.find<WebSocketService>().connect();
  }

  final List<Widget> _pages = const [
    BuyerHomeScreen(),
    SearchScreen(),
    NotificationsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldExit = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  color: const Color(0xFF1E1E38).withOpacity(0.95),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.exit_to_app, color: Colors.redAccent, size: 30),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Exit Application?",
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Do you want to exit the application?",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.white38),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              "Cancel",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              "Exit",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
        if (shouldExit == true) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: GlassBackground(
          child: Stack(
            children: [
              IndexedStack(
                index: _currentIndex,
                children: _pages,
              ),
              const CallOverlayWidget(),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().cardBackground : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                  try {
                    if (index == 0) {
                      getCategoryRx.fetchCategories();
                      getTrendingTagsRx.fetchTrendingTags();
                    } else if (index == 1) {
                      getTrendingTagsRx.fetchTrendingTags();
                    } else if (index == 2) {
                      getInvoiceRx.fetchInvoices();
                    }
                  } catch (e) {
                    // ignore
                  }
                },
                backgroundColor: Colors.transparent,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: AppColors.c053A4CA,
                unselectedItemColor: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textSecondaryColor : Colors.black45,
                selectedLabelStyle: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.w600),
                unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11.sp),
                elevation: 0,
                items: [
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.search_outlined),
                    activeIcon: Icon(Icons.search),
                    label: 'Search',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.notifications_outlined),
                    activeIcon: Icon(Icons.notifications),
                    label: 'Invoices',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
