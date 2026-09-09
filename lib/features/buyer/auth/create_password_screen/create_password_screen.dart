import 'package:bd_shope_combined/controllers/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bd_shope_combined/route/app_pages.dart';
import 'package:bd_shope_combined/common_wigdets/glass_background.dart';
import 'package:bd_shope_combined/common_wigdets/glass_text_field.dart';
import 'package:bd_shope_combined/common_wigdets/glass_button.dart';
import 'package:bd_shope_combined/common_wigdets/app_toast.dart';
import 'package:bd_shope_combined/networks/api_acess.dart';

class CreatePasswordScreen extends StatefulWidget {
  const CreatePasswordScreen({Key? key}) : super(key: key);

  @override
  State<CreatePasswordScreen> createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends State<CreatePasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _otp = '';

  @override
  void initState() {
    super.initState();
    _email = ((Get.arguments as Map<String, dynamic>?)?['email'] ?? '').toString();
    _otp = ((Get.arguments as Map<String, dynamic>?)?['otp'] ?? '').toString();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onReset() async {
    if (_formKey.currentState!.validate()) {
      if (_email.isEmpty || _otp.isEmpty) {
        AppToast.error('Session expired. Please try again.');
        return;
      }

      bool success = await postResetPasswordRx.resetPassword(
        email: _email,
        otp: _otp,
        password: _passwordController.text,
        passwordConfirmation: _confirmPasswordController.text,
      );

      if (success) {
        Get.offAllNamed(Routes.LOGIN);
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
                    'New Password',
                    style: GoogleFonts.outfit(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w700,
                      color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Define a strong password containing at least 6 characters.',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.7),
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 40.h),

                  // Password
                  GlassTextField(
                    controller: _passwordController,
                    labelText: 'New Password',
                    hintText: 'Enter new password',
                    prefixIcon: Icon(Icons.lock_outline),
                    isPassword: true,
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

                  // Confirm Password
                  GlassTextField(
                    controller: _confirmPasswordController,
                    labelText: 'Confirm Password',
                    hintText: 'Confirm new password',
                    prefixIcon: Icon(Icons.lock_reset),
                    isPassword: true,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _onReset(),
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 36.h),

                  // Reset Button
                  GlassButton(
                    text: 'Update Password',
                    onTap: _onReset,
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
