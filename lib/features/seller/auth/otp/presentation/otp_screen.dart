import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import 'package:bd_shope_combined/common_widgets/glass_background_scaffold.dart';
import 'package:bd_shope_combined/common_widgets/glass_card.dart';
import 'package:bd_shope_combined/constants/app_colors.dart';
import 'package:bd_shope_combined/networks/api_acess.dart';
import 'package:bd_shope_combined/controllers/theme_controller.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
  final StreamController<ErrorAnimationType>? _errorController =
      StreamController<ErrorAnimationType>();

  late String email;
  late bool fromRegister;
  late bool isFromForgot;

  Timer? _timer;
  int _secondsRemaining = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    final arguments = Get.arguments as Map<String, dynamic>?;
    email = arguments?['email'] ?? '';
    fromRegister = arguments?['fromRegister'] ?? false;
    isFromForgot = arguments?['isFromForgot'] ?? false;
    _startTimer();
  }

  void _startTimer() {
    _canResend = false;
    _secondsRemaining = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_secondsRemaining > 0) {
            _secondsRemaining--;
          } else {
            _canResend = true;
            _timer?.cancel();
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _errorController?.close();
    try {
      _otpController.dispose();
    } catch (e) {
      // Avoid crash if controller is already disposed by the PinCodeTextField
    }
    super.dispose();
  }

  void _verifyOtp() async {
    final otp = _otpController.text;
    if (otp.length < 4) {
      _errorController?.add(ErrorAnimationType.shake);
      Get.snackbar(
        "Invalid OTP",
        "Please enter a valid OTP",
        colorText: Colors.white,
        backgroundColor: Colors.redAccent.withOpacity(0.8),
      );
      return;
    }

    await postVerifyOtpRx.verifyOtp(
      email: email,
      otp: otp,
      fromRegister: fromRegister,
      isFromForgot: isFromForgot,
    );
  }

  void _resendOtp() async {
    if (!_canResend) return;
    bool success = await postVerifyOtpRx.resendOtp(email: email);
    if (success) {
      _startTimer();
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
                      "Verify OTP",
                      style: TextStyle(
                        color: tc.textColor,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      "We've sent a code to\n$email",
                      style: TextStyle(
                        color: tc.textSecondaryColor,
                        fontSize: 12.sp,
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Pin Code Input
                    PinCodeTextField(
                      appContext: context,
                      length: 6,
                      obscureText: false,
                      animationType: AnimationType.fade,
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(10.r),
                        fieldHeight: 48.h,
                        fieldWidth: 38.w,
                        activeFillColor: tc.inputBackground,
                        inactiveFillColor: tc.inputBackground,
                        selectedFillColor: tc.textColor.withOpacity(0.1),
                        activeColor: AppColors.c053A4CA,
                        inactiveColor: tc.inputBorderColor,
                        selectedColor: AppColors.c7953CA,
                      ),
                      cursorColor: tc.textColor,
                      animationDuration: const Duration(milliseconds: 300),
                      enableActiveFill: true,
                      errorAnimationController: _errorController,
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      textStyle: TextStyle(color: tc.textColor),
                      onChanged: (value) {},
                      beforeTextPaste: (text) => true,
                    ),
                    SizedBox(height: 12.h),

                    // Resend Timer Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _canResend
                              ? "Didn't receive code?"
                              : "Resend in ${_secondsRemaining}s",
                          style: TextStyle(
                            color: tc.textSecondaryColor,
                            fontSize: 12.sp,
                          ),
                        ),
                        if (_canResend)
                          TextButton(
                            onPressed: _resendOtp,
                            child: Text(
                              "Resend Code",
                              style: TextStyle(
                                color: AppColors.c053A4CA,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 20.h),

                    // Verify Button
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
                        onPressed: _verifyOtp,
                        child: Text(
                          "Verify Code",
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
              ),
            ),
          ),
        ),
      ),
    ));
  }
}
