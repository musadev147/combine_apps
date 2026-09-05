import 'package:bd_shope_combined/controllers/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:bd_shope_combined/common_widgets/glass_background_scaffold.dart';
import 'package:bd_shope_combined/common_widgets/glass_card.dart';
import 'package:bd_shope_combined/route/app_routes.dart';
import 'package:bd_shope_combined/helpers/di.dart';
import 'package:bd_shope_combined/constants/app_colors.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      "icon": Icons.local_shipping_outlined,
      "title": "Streamlined Deliveries",
      "desc": "Track, process, and update shipping pipelines of all seller hub packages in real-time."
    },
    {
      "icon": Icons.post_add_rounded,
      "title": "Instant Digital Invoicing",
      "desc": "Draft billing sheets and issue digital invoices instantly during active seller-buyer call sessions."
    },
    {
      "icon": Icons.support_agent_rounded,
      "title": "Direct Buyer Support",
      "desc": "Simulate incoming calls, answer query tickers, and live-chat to resolve administrative issues."
    }
  ];

  void _finishOnboarding() {
    appData.write('has_completed_onboarding', true);
    Get.offAllNamed(Routes.LOGIN);
  }

  @override
  Widget build(BuildContext context) {
    return GlassBackgroundScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _finishOnboarding,
            child: Text(
              "Skip",
              style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.6), fontSize: 14.sp, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  final item = _onboardingData[index];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Large Glass Card containing slide detail
                      GlassCard(
                        borderRadius: 24.r,
                        backgroundColor: Colors.white.withOpacity(0.05),
                        child: Container(
                          padding: EdgeInsets.all(32.w),
                          width: double.infinity,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 80.w,
                                height: 80.h,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.c053A4CA.withOpacity(0.15),
                                  border: Border.all(color: AppColors.c053A4CA.withOpacity(0.3), width: 1.5),
                                ),
                                child: Icon(
                                  item["icon"] as IconData,
                                  color: AppColors.c053A4CA,
                                  size: 40.sp,
                                ),
                              ),
                              SizedBox(height: 24.h),
                              Text(
                                item["title"] as String,
                                style: TextStyle(
                                  color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                item["desc"] as String,
                                style: TextStyle(
                                  color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.7),
                                  fontSize: 13.sp,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            
            // Dot Indicators & Action Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Indicators
                Row(
                  children: List.generate(
                    _onboardingData.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: EdgeInsets.only(right: 6.w),
                      height: 8.h,
                      width: _currentPage == index ? 24.w : 8.w,
                      decoration: BoxDecoration(
                        color: _currentPage == index ? AppColors.c053A4CA : Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ),
                ),
                
                // Action Button
                Container(
                  height: 48.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    gradient: const LinearGradient(
                      colors: [AppColors.c053A4CA, AppColors.c7953CA],
                    ),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    onPressed: () {
                      if (_currentPage < _onboardingData.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _finishOnboarding();
                      }
                    },
                    child: Text(
                      _currentPage == _onboardingData.length - 1 ? "Get Started" : "Next",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}
