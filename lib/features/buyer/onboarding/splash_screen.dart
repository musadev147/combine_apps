import 'package:bd_shope_combined/controllers/theme_controller.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bd_shope_combined/route/app_pages.dart';
import 'package:bd_shope_combined/constants/app_colors.dart';
import 'package:bd_shope_combined/constants/app_constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  final _storage = GetStorage();
  late AnimationController _logoController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;

  @override
  void initState() {
    super.initState();
    
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _logoScale = CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    );

    _logoOpacity = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeIn,
    );

    _logoController.forward();
    
    // Auto navigate after loading (1.2 seconds duration)
    Future.delayed(const Duration(milliseconds: 1200), _navigate);
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  void _navigate() {
    // Read from storage to check first run and login status
    final isFirstRun = _storage.read<bool>(kKeyIsFirstTime) ?? true;
    final isLoggedIn = _storage.read<bool>(kKeyIsLoggedIn) ?? false;

    if (isFirstRun) {
      _storage.write(kKeyIsFirstTime, false);
      Get.offAllNamed(Routes.ONBOARDING);
    } else if (isLoggedIn) {
      Get.offAllNamed(Routes.HOME);
    } else {
      Get.offAllNamed(Routes.ROLE_SELECTION);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F0C20), // Dark Luxury Deep Blue/Purple
              Color(0xFF15102A),
              Color(0xFF06040A),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Decorative background glowing circles
            Positioned(
              top: -100.h,
              right: -100.w,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(
                  width: 300.w,
                  height: 300.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.c7953CA.withOpacity(0.15),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -50.h,
              left: -50.w,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                child: Container(
                  width: 250.w,
                  height: 250.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.c053A4CA.withOpacity(0.15),
                  ),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _logoScale,
                    child: FadeTransition(
                      opacity: _logoOpacity,
                      child: Container(
                        padding: EdgeInsets.all(28.r),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7953CA), Color(0xFF53A4CA)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.c053A4CA.withOpacity(0.3),
                              blurRadius: 30,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          size: 75.r,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 36.h),
                  FadeTransition(
                    opacity: _logoOpacity,
                    child: Column(
                      children: [
                        Text(
                          'Damadami',
                          style: GoogleFonts.outfit(
                            fontSize: 38.sp,
                            fontWeight: FontWeight.w900,
                            color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                            letterSpacing: 2.0,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                offset: const Offset(0, 4),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          'Premium Buyer Marketplace',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.65),
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 56.h),
                  SizedBox(
                    width: 28.w,
                    height: 28.h,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.c053A4CA),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
