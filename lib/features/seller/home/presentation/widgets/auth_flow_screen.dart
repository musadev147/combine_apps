import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:bd_shope_combined/constants/app_colors.dart';
import 'package:bd_shope_combined/common_widgets/glass_background_scaffold.dart';
import 'package:bd_shope_combined/common_widgets/glass_card.dart';
import 'package:bd_shope_combined/controllers/theme_controller.dart';
import 'common_components.dart';

class AuthFlowScreen extends StatefulWidget {
  final String authScreenState;
  final TextEditingController loginEmailController;
  final TextEditingController loginPasswordController;
  final TextEditingController regStoreNameController;
  final TextEditingController regEmailController;
  final TextEditingController regPhoneController;
  final TextEditingController otpController;
  final Function(String) onStateChanged;
  final VoidCallback onLogin;
  final VoidCallback onRequestOtp;
  final VoidCallback onVerifyOtp;

  const AuthFlowScreen({
    super.key,
    required this.authScreenState,
    required this.loginEmailController,
    required this.loginPasswordController,
    required this.regStoreNameController,
    required this.regEmailController,
    required this.regPhoneController,
    required this.otpController,
    required this.onStateChanged,
    required this.onLogin,
    required this.onRequestOtp,
    required this.onVerifyOtp,
  });

  @override
  State<AuthFlowScreen> createState() => _AuthFlowScreenState();
}

class _AuthFlowScreenState extends State<AuthFlowScreen> {
  @override
  Widget build(BuildContext context) {
    final tc = Get.find<ThemeController>();
    return Obx(() => GlassBackgroundScaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: GlassCard(
              borderRadius: 24.r,
              backgroundColor: tc.isDarkMode.value ? Colors.black.withOpacity(0.35) : Colors.white.withOpacity(0.6),
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: _buildAuthContent(),
              ),
            ),
          ),
        ),
      ),
    ));
  }

  Widget _buildAuthContent() {
    if (widget.authScreenState == "LOGIN") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAuthHeader("Seller Login", "Access your dashboard and start selling"),
          SizedBox(height: 20.h),
          buildGlassInputField(
            controller: widget.loginEmailController,
            label: "Email / Phone",
            icon: Icons.email_outlined,
            hint: "seller@damadami.com",
          ),
          SizedBox(height: 12.h),
          buildGlassInputField(
            controller: widget.loginPasswordController,
            label: "Password",
            icon: Icons.lock_outline,
            hint: "••••••••",
          ),
          SizedBox(height: 10.h),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => widget.onStateChanged("FORGOT"),
              child: Text("Forgot Password?", style: TextStyle(color: AppColors.c053A4CA, fontSize: 12.sp)),
            ),
          ),
          SizedBox(height: 10.h),
          buildActionBtn("Login Now", widget.onLogin),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Don't have an account?", style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textSecondaryColor : Colors.black54, fontSize: 13.sp)),
              TextButton(
                onPressed: () => widget.onStateChanged("REGISTER"),
                child: Text("Register", style: TextStyle(color: AppColors.c7953CA, fontWeight: FontWeight.bold, fontSize: 13.sp)),
              ),
            ],
          )
        ],
      );
    } else if (widget.authScreenState == "REGISTER") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAuthHeader("Seller Registration", "Register your store on Damadami Market"),
          SizedBox(height: 20.h),
          buildGlassInputField(
            controller: widget.regStoreNameController,
            label: "Store Name",
            icon: Icons.storefront_outlined,
            hint: "e.g. Dream Electronics",
          ),
          SizedBox(height: 12.h),
          buildGlassInputField(
            controller: widget.regEmailController,
            label: "Email Address",
            icon: Icons.email_outlined,
            hint: "dream@example.com",
          ),
          SizedBox(height: 12.h),
          buildGlassInputField(
            controller: widget.regPhoneController,
            label: "Phone Number",
            icon: Icons.phone_android_rounded,
            hint: "e.g. 01712345678",
          ),
          SizedBox(height: 20.h),
          buildActionBtn("Request OTP Code", widget.onRequestOtp),
          SizedBox(height: 14.h),
          Center(
            child: TextButton(
              onPressed: () => widget.onStateChanged("LOGIN"),
              child: Text("Back to Login", style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.7))),
            ),
          )
        ],
      );
    } else if (widget.authScreenState == "FORGOT") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAuthHeader("Forgot Password", "Enter your phone to reset password"),
          SizedBox(height: 20.h),
          buildGlassInputField(
            controller: widget.regPhoneController,
            label: "Registered Phone",
            icon: Icons.phone_android_rounded,
            hint: "e.g. 01712345678",
          ),
          SizedBox(height: 20.h),
          buildActionBtn("Send OTP Verification", widget.onRequestOtp),
          SizedBox(height: 14.h),
          Center(
            child: TextButton(
              onPressed: () => widget.onStateChanged("LOGIN"),
              child: Text("Back to Login", style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.7))),
            ),
          )
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAuthHeader("OTP Verification", "Enter verification code sent to your mobile"),
          SizedBox(height: 20.h),
          buildGlassInputField(
            controller: widget.otpController,
            label: "Verification Code (OTP)",
            icon: Icons.lock_clock_outlined,
            hint: "e.g. 482910",
          ),
          SizedBox(height: 20.h),
          buildActionBtn("Verify & Proceed", widget.onVerifyOtp),
          SizedBox(height: 14.h),
          Center(
            child: TextButton(
              onPressed: () => widget.onStateChanged("LOGIN"),
              child: Text("Cancel", style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.7))),
            ),
          )
        ],
      );
    }
  }

  Widget _buildAuthHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, fontSize: 22.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 4.h),
        Text(subtitle, style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.7), fontSize: 12.sp)),
      ],
    );
  }
}
