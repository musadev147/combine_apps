import 'package:bd_shope_combined/controllers/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bd_shope_combined/route/app_pages.dart';
import 'package:bd_shope_combined/common_wigdets/glass_background.dart';
import 'package:bd_shope_combined/common_wigdets/glass_text_field.dart';
import 'package:bd_shope_combined/common_wigdets/glass_button.dart';
import 'package:bd_shope_combined/networks/api_acess.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      bool success = await postForgotPasswordRx.forgotPasswordFunc(
        email: email,
      );
      if (success) {
        await Get.toNamed(Routes.OTP, arguments: {'email': email, 'isFromForgot': true});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlassBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.arrow_back_ios, color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black),
                  ),
                  SizedBox(height: 32.h),
                  Text(
                    'Reset Password',
                    style: GoogleFonts.outfit(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w700,
                      color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Enter your registered email address and we will help you set up a new password.',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.7),
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 40.h),

                  // Email input
                  GlassTextField(
                    controller: _emailController,
                    labelText: 'Email Address',
                    hintText: 'Enter your email',
                    prefixIcon: Icon(Icons.email_outlined),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email is required';
                      }
                      if (!GetUtils.isEmail(value.trim())) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 32.h),

                  // Submit button
                  GlassButton(
                    text: 'Send Verification Link',
                    onTap: _onSubmit,
                    style: GlassButtonStyle.gradient,
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
