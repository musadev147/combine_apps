import 'package:bd_shope_combined/controllers/theme_controller.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bd_shope_combined/route/app_routes.dart';
import 'package:bd_shope_combined/helpers/di.dart';
import 'package:bd_shope_combined/constants/app_constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
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

    Future.delayed(const Duration(milliseconds: 1200), _navigate);
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  void _navigate() {
    final isLoggedIn = appData.read<bool>(kKeyIsLoggedIn) ?? false;
    if (isLoggedIn) {
      Get.offAllNamed(Routes.HOME);
      return;
    }

    final hasCompleted = appData.read<bool>('has_completed_onboarding') ?? false;
    if (hasCompleted) {
      Get.offAllNamed(Routes.LOGIN);
    } else {
      Get.offAllNamed(Routes.ONBOARDING);
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
              Color(0xFF0C0B1B), // Dark Luxury Deep Navy
              Color(0xFF131127),
              Color(0xFF05050A),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Glowing circles for background aesthetics
            Positioned(
              top: -80.h,
              right: -80.w,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
                child: Container(
                  width: 280.w,
                  height: 280.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF7953CA).withOpacity(0.15),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -60.h,
              left: -60.w,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                child: Container(
                  width: 240.w,
                  height: 240.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF00F0FF).withOpacity(0.12),
                  ),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Top section: Logo aligned to bottom-center of this area
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 30.h),
                        child: ScaleTransition(
                          scale: _logoScale,
                          child: FadeTransition(
                            opacity: _logoOpacity,
                            child: Container(
                              padding: EdgeInsets.all(28.r),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF7953CA), Color(0xFF00F0FF)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF00F0FF).withOpacity(0.25),
                                    blurRadius: 25,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.storefront_outlined,
                                size: 75.r,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Middle section: Always exactly at the vertical center of the screen
                  FadeTransition(
                    opacity: _logoOpacity,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Damadami Live Hub',
                          textAlign: TextAlign.center,
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
                          'Premium Seller Portal',
                          textAlign: TextAlign.center,
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
                  
                  // Bottom section: Progress indicator aligned to top-center of this area
                  Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: EdgeInsets.only(top: 40.h),
                        child: SizedBox(
                          width: 28.w,
                          height: 28.h,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00F0FF)),
                          ),
                        ),
                      ),
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
