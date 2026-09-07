import 'package:bd_shope_combined/controllers/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bd_shope_combined/route/app_pages.dart';
import 'package:bd_shope_combined/common_wigdets/glass_background.dart';
import 'package:bd_shope_combined/common_wigdets/glass_text_field.dart';
import 'package:bd_shope_combined/common_wigdets/glass_button.dart';
import 'package:bd_shope_combined/constants/app_constants.dart';
import 'package:bd_shope_combined/helpers/di.dart';
import 'package:bd_shope_combined/networks/api_acess.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() async {
    if (_formKey.currentState!.validate()) {
      bool success = await postLoginRx.loginFunc(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (success) {
        Get.offAllNamed(Routes.HOME);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        Get.offAllNamed(Routes.ROLE_SELECTION);
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: GlassBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand Logo / Header
                    Center(
                      child: Container(
                        padding: EdgeInsets.all(18.r),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().cardBackground : Colors.white.withOpacity(0.06),
                          border: Border.all(
                            color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12.withOpacity(0.15),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          size: 56.r,
                          color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Center(
                      child: Text(
                        'Damadami Live',
                        style: GoogleFonts.outfit(
                          fontSize: 32.sp,
                          fontWeight: FontWeight.w900,
                          color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Center(
                      child: Text(
                        'Premium Buyer-Only Marketplace',
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.6),
                        ),
                      ),
                    ),
                    SizedBox(height: 36.h),

                    // Email / Phone Number Input
                    GlassTextField(
                      controller: _emailController,
                      labelText: 'Email / Phone Number',
                      hintText: 'Enter email or phone number',
                      prefixIcon: Icon(Icons.person_outline),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email or Phone Number is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),

                    // Password Input
                    GlassTextField(
                      controller: _passwordController,
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      prefixIcon: Icon(Icons.lock_outline),
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _onLogin(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12.h),

                    // Forgot Password option
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => Get.toNamed(Routes.FORGOT_PASSWORD),
                        child: Text(
                          'Forgot Password?',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF53A4CA),
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Login Button
                    GlassButton(
                      text: 'Log In',
                      onTap: _onLogin,
                      style: GlassButtonStyle.gradient,
                    ),
                    SizedBox(height: 24.h),

                    // Sign Up Option
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: GoogleFonts.poppins(
                            color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.6),
                            fontSize: 13.sp,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Get.toNamed(Routes.REGISTER),
                          child: Text(
                            'Sign Up',
                            style: GoogleFonts.poppins(
                              color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
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
      ),
      )
    );
  }
}
