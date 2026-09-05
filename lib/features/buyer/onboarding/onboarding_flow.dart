import 'package:bd_shope_combined/controllers/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'onboarding_page.dart';
import 'package:bd_shope_combined/route/app_pages.dart';
import 'package:bd_shope_combined/common_wigdets/glass_background.dart';
import 'package:bd_shope_combined/common_wigdets/glass_button.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({Key? key}) : super(key: key);

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _pages = const [
    {
      'title': 'Discover Products Instantly',
      'description': 'Search by tags and categories to find exactly what you need in seconds.',
      'icon': Icons.search_outlined,
    },
    {
      'title': 'Connect With Sellers',
      'description': 'Chat, Voice Call & Video Call directly with sellers for faster deal completions.',
      'icon': Icons.connect_without_contact_outlined,
    },
    {
      'title': 'Smart Marketplace Experience',
      'description': 'Fast and Secure Shopping tailored to save you time and maximize value.',
      'icon': Icons.shopping_bag_outlined,
    },
  ];

  void _next() {
    if (_currentIndex < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _skip() => _finish();

  void _finish() {
    Get.offAllNamed(Routes.LOGIN);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlassBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar with Skip Button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.only(right: 16.w, top: 8.h),
                  child: TextButton(
                    onPressed: _skip,
                    child: Text(
                      'Skip',
                      style: GoogleFonts.poppins(
                        color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.7),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),

              // Page Content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) => setState(() => _currentIndex = index),
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return OnboardingPage(
                      title: page['title']!,
                      description: page['description']!,
                      icon: page['icon']!,
                    );
                  },
                ),
              ),

              // Indicator Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(horizontal: 5.w),
                    width: _currentIndex == index ? 24.w : 8.w,
                    height: 8.h,
                    decoration: BoxDecoration(
                      color: _currentIndex == index
                          ? const Color(0xFF53A4CA)
                          : Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32.h),

              // Bottom Action Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 24.h),
                child: GlassButton(
                  text: _currentIndex == _pages.length - 1 ? 'Get Started' : 'Next',
                  onTap: _next,
                  style: GlassButtonStyle.gradient,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
