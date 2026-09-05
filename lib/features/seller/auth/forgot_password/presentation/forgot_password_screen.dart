import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:bd_shope_combined/common_widgets/glass_background_scaffold.dart';
import 'package:bd_shope_combined/common_widgets/glass_card.dart';
import 'package:bd_shope_combined/constants/app_colors.dart';
import 'package:bd_shope_combined/networks/api_acess.dart';
import 'package:bd_shope_combined/route/app_routes.dart';
import 'package:bd_shope_combined/controllers/theme_controller.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendVerificationCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter your email",
        colorText: Colors.white,
        backgroundColor: Colors.redAccent.withOpacity(0.8),
      );
      return;
    }

    bool success = await postForgotPasswordRx.forgotPasswordFunc(email: email);
    if (success) {
      Get.toNamed(Routes.OTP, arguments: {
        'email': email,
        'isFromForgot': true,
      });
    }
  }

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
              backgroundColor: tc.isDarkMode.value ? Colors.black.withOpacity(0.25) : Colors.white.withOpacity(0.6),
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ForgotPassword",
                      style: TextStyle(
                        color: tc.textColor,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      "Enter your email to receive a password reset OTP",
                      style: TextStyle(
                        color: tc.textSecondaryColor,
                        fontSize: 12.sp,
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Email Input
                    _buildGlassInputField(
                      controller: _emailController,
                      label: "Email Address",
                      icon: Icons.email_outlined,
                      hint: "seller@damadami.com",
                    ),
                    SizedBox(height: 24.h),

                    // Send Button
                    Container(
                      width: double.infinity,
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        onPressed: _sendVerificationCode,
                        child: Text(
                          "Send OTP",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Back to Login Footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Remember your password?",
                          style: TextStyle(
                            color: tc.textSecondaryColor,
                            fontSize: 13.sp,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Get.back(),
                          child: Text(
                            "Login",
                            style: TextStyle(
                              color: AppColors.c053A4CA,
                              fontWeight: FontWeight.bold,
                              fontSize: 13.sp,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ));
  }

  Widget _buildGlassInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
  }) {
    final tc = Get.find<ThemeController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: tc.textSecondaryColor,
            fontSize: 11.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4.h),
        Container(
          decoration: BoxDecoration(
            color: tc.inputBackground,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: tc.inputBorderColor),
          ),
          child: TextFormField(
            controller: controller,
            style: TextStyle(color: tc.inputTextColor, fontSize: 13.sp),
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: tc.iconColor,
                size: 18.sp,
              ),
              hintText: hint,
              hintStyle: TextStyle(
                color: tc.inputHintColor,
                fontSize: 13.sp,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 10.h),
            ),
          ),
        ),
      ],
    );
  }
}
