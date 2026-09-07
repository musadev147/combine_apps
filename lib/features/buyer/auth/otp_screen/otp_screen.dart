import 'package:bd_shope_combined/controllers/theme_controller.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:bd_shope_combined/route/app_pages.dart';
import 'package:bd_shope_combined/common_wigdets/glass_background.dart';
import 'package:bd_shope_combined/common_wigdets/glass_button.dart';
import 'package:bd_shope_combined/common_wigdets/app_toast.dart';

import 'package:bd_shope_combined/constants/app_constants.dart';
import 'package:bd_shope_combined/helpers/di.dart';

import 'package:bd_shope_combined/networks/api_acess.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({Key? key}) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  Timer? _timer;
  int _secondsRemaining = 59;
  bool _canResend = false;
  bool _fromRegister = false;
  bool _isFromForgot = false;

  @override
  void initState() {
    super.initState();
    _email = (Get.arguments as Map<String, dynamic>?)?['email'] ?? '';
    _fromRegister = (Get.arguments as Map<String, dynamic>?)?['fromRegister'] == true;
    _isFromForgot = (Get.arguments as Map<String, dynamic>?)?['isFromForgot'] == true;
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _secondsRemaining = 59;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        if (_secondsRemaining > 0) {
          setState(() {
            _secondsRemaining--;
          });
        } else {
          setState(() {
            _canResend = true;
            _timer?.cancel();
          });
        }
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    try {
      _otpController.dispose();
    } catch (e) {
      // Avoid crash if controller is already disposed
    }
    super.dispose();
  }

  void _onVerify() async {
    if (_formKey.currentState!.validate()) {
      if (_otpController.text.length == 6) {
        await postVerifyOtpRx.verifyOtp(
          email: _email,
          otp: _otpController.text.trim(),
          fromRegister: _fromRegister,
          isFromForgot: _isFromForgot,
        );
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
                    'Verification Code',
                    style: GoogleFonts.outfit(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w700,
                      color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'We have sent a 6‑digit verification code to your registered contact.',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.7),
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 48.h),

                  // Pin Code Input Fields
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: PinCodeTextField(
                      appContext: context,
                      length: 6,
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      obscureText: false,
                      animationType: AnimationType.fade,
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(12.r),
                        fieldHeight: 52.h,
                        fieldWidth: 44.w,
                        activeFillColor: Get.isRegistered<ThemeController>() && Get.find<ThemeController>().isDarkMode.value
                            ? Colors.white.withOpacity(0.12)
                            : const Color(0xFFF1F5F9),
                        inactiveFillColor: Get.isRegistered<ThemeController>() && Get.find<ThemeController>().isDarkMode.value
                            ? Colors.white.withOpacity(0.06)
                            : const Color(0xFFF8FAFC),
                        selectedFillColor: Get.isRegistered<ThemeController>() && Get.find<ThemeController>().isDarkMode.value
                            ? Colors.white.withOpacity(0.18)
                            : const Color(0xFFE2E8F0),
                        activeColor: const Color(0xFF53A4CA),
                        inactiveColor: Get.isRegistered<ThemeController>() && Get.find<ThemeController>().isDarkMode.value
                            ? Colors.white.withOpacity(0.2)
                            : Colors.black12,
                        selectedColor: const Color(0xFF7953CA),
                        borderWidth: 1.5,
                      ),
                      cursorColor: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                      animationDuration: const Duration(milliseconds: 300),
                      enableActiveFill: true,
                      textStyle: TextStyle(
                        fontSize: 18.sp,
                        color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      onChanged: (value) {},
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'Enter full 6-digit code';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 36.h),

                  // Verify Button
                  GlassButton(
                    text: 'Verify Code',
                    onTap: _onVerify,
                    style: GlassButtonStyle.gradient,
                  ),
                  SizedBox(height: 40.h),

                  // Resend Code Trigger
                  Center(
                    child: Column(
                      children: [
                        Text(
                          _canResend ? "Didn't receive the code?" : 'Resend code in $_secondsRemaining seconds',
                          style: GoogleFonts.poppins(
                            color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.6),
                            fontSize: 13.sp,
                          ),
                        ),
                        if (_canResend) ...[
                          SizedBox(height: 8.h),
                          GestureDetector(
                            onTap: () async {
                              if (_email.isNotEmpty) {
                                final res = await postVerifyOtpRx.resendOtp(email: _email);
                                if (res) {
                                  _startTimer();
                                }
                              } else {
                                AppToast.error('Email is missing');
                              }
                            },
                            child: Text(
                              'Resend Code',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF53A4CA),
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
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
