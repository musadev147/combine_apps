import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:bd_shope_combined/common_widgets/glass_background_scaffold.dart';
import 'package:bd_shope_combined/common_widgets/glass_card.dart';
import 'package:bd_shope_combined/constants/app_colors.dart';
import 'package:bd_shope_combined/networks/api_acess.dart';
import 'package:bd_shope_combined/route/app_routes.dart';
import 'package:bd_shope_combined/controllers/theme_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        "Error",
        "Please fill in all fields",
        colorText: Colors.white,
        backgroundColor: Colors.redAccent.withOpacity(0.8),
      );
      return;
    }

    bool success = await sellerPostLoginRx.loginFunc(
      email: email,
      password: password,
    );

    if (success) {
      Get.offAllNamed(Routes.SELLER_HOME);
    }
  }


  @override
  Widget build(BuildContext context) {
    final tc = Get.find<ThemeController>();
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        Get.offAllNamed(Routes.ROLE_SELECTION);
      },
      child: Obx(() => GlassBackgroundScaffold(
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
                      "Seller Login",
                      style: TextStyle(
                        color: tc.textColor,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      "Access your seller hub dashboard",
                      style: TextStyle(
                        color: tc.textSecondaryColor,
                        fontSize: 12.sp,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    
                    // Email
                    _buildGlassInputField(
                      controller: _emailController,
                      label: "Email / Phone",
                      icon: Icons.email_outlined,
                      hint: "seller@damadami.com",
                    ),
                    SizedBox(height: 14.h),
                    
                    // Password
                    _buildGlassInputField(
                      controller: _passwordController,
                      label: "Password",
                      icon: Icons.lock_outline_rounded,
                      hint: "••••••••",
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: tc.iconColor,
                          size: 18.sp,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 8.h),
                    
                    // Forgot Password link
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Get.toNamed(Routes.SELLER_FORGOT_PASSWORD),
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: AppColors.c053A4CA,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    
                    // Login Button
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                        onPressed: _login,
                        child: Text(
                          "Login Now",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    
                    // Register Footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: TextStyle(color: tc.textSecondaryColor, fontSize: 13.sp),
                        ),
                        TextButton(
                          onPressed: () => Get.toNamed(Routes.SELLER_REGISTER),
                          child: Text(
                            "Register",
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
      )
    ));
  }

  Widget _buildGlassInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    bool obscureText = false,
    Widget? suffixIcon,
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
            obscureText: obscureText,
            style: TextStyle(color: tc.inputTextColor, fontSize: 13.sp),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: tc.iconColor, size: 18.sp),
              suffixIcon: suffixIcon,
              hintText: hint,
              hintStyle: TextStyle(color: tc.inputHintColor, fontSize: 13.sp),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 10.h),
            ),
          ),
        ),
      ],
    );
  }
}
