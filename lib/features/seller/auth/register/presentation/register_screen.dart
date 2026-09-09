import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:bd_shope_combined/common_widgets/glass_background_scaffold.dart';
import 'package:bd_shope_combined/common_widgets/glass_card.dart';
import 'package:bd_shope_combined/constants/app_colors.dart';
import 'package:bd_shope_combined/networks/api_acess.dart';
import 'package:bd_shope_combined/route/app_routes.dart';
import 'package:bd_shope_combined/controllers/theme_controller.dart';
import 'model/register_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _presentAddressController = TextEditingController();
  final _permanentAddressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  File? _avatarFile;
  String? _selectedRoleId;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    getRolesRx.fetchRoles();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _presentAddressController.dispose();
    _permanentAddressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _avatarFile = File(image.path);
        });
      }
    } catch (e) {
      Get.snackbar(
        "Image Selection Failed",
        "Could not pick image: $e",
        colorText: Colors.white,
        backgroundColor: Colors.redAccent.withOpacity(0.8),
      );
    }
  }

  void _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final presentAddress = _presentAddressController.text.trim();
    final permanentAddress = _permanentAddressController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        presentAddress.isEmpty ||
        permanentAddress.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      Get.snackbar(
        "Error",
        "Please fill in all fields",
        colorText: Colors.white,
        backgroundColor: Colors.redAccent.withOpacity(0.8),
      );
      return;
    }

    String? resolvedRole = _selectedRoleId;
    if (resolvedRole == null) {
      final roles = getRolesRx.valueStreamData.valueOrNull ?? [];
      for (var r in roles) {
        if ((r.value?.toLowerCase() ?? '') == 'vendor' || (r.id?.toLowerCase() ?? '') == 'vendor') {
          resolvedRole = r.id;
          break;
        }
      }
    }
    resolvedRole ??= 'vendor';

    if (password != confirmPassword) {
      Get.snackbar(
        "Error",
        "Passwords do not match",
        colorText: Colors.white,
        backgroundColor: Colors.redAccent.withOpacity(0.8),
      );
      return;
    }

    bool success = await sellerPostRegisterRx.signUpdata(
      name: name,
      email: email,
      password: password,
      password_confirmation: confirmPassword,
      role: resolvedRole,
      phoneNumber: phone,
      permanentAddress: permanentAddress,
      presentAddress: presentAddress,
      avatar: _avatarFile,
    );

    if (success) {
      Get.toNamed(Routes.SELLER_OTP, arguments: {
        'email': email,
        'fromRegister': true,
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
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
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
                      "Seller Registration",
                      style: TextStyle(
                        color: tc.textColor,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      "Create your seller account to get started",
                      style: TextStyle(
                        color: tc.textSecondaryColor,
                        fontSize: 12.sp,
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Avatar Picker
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          children: [
                            Container(
                              width: 80.r,
                              height: 80.r,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: tc.textColor.withOpacity(0.3),
                                  width: 2,
                                ),
                                color: tc.textColor.withOpacity(0.1),
                              ),
                              child: _avatarFile != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(40.r),
                                      child: Image.file(
                                        _avatarFile!,
                                        fit: BoxFit.cover,
                                        width: 80.r,
                                        height: 80.r,
                                      ),
                                    )
                                  : Icon(
                                      Icons.person_add_alt_1_rounded,
                                      color: tc.iconColor,
                                      size: 32.r,
                                    ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.all(4.r),
                                decoration: const BoxDecoration(
                                  color: AppColors.c053A4CA,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                                  size: 14.r,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Name
                    _buildGlassInputField(
                      controller: _nameController,
                      label: "Full Name",
                      icon: Icons.person_outline_rounded,
                      hint: "Enter your full name",
                    ),
                    SizedBox(height: 14.h),

                    // Email
                    _buildGlassInputField(
                      controller: _emailController,
                      label: "Email",
                      icon: Icons.email_outlined,
                      hint: "seller@damadami.com",
                    ),
                    SizedBox(height: 14.h),

                    // Phone Number
                    _buildGlassInputField(
                      controller: _phoneController,
                      label: "Phone Number",
                      icon: Icons.phone_outlined,
                      hint: "e.g. +8801700000000",
                    ),
                    SizedBox(height: 14.h),

                    // Present Address
                    _buildGlassInputField(
                      controller: _presentAddressController,
                      label: "Present Address",
                      icon: Icons.location_on_outlined,
                      hint: "Enter present address",
                    ),
                    SizedBox(height: 14.h),

                    // Permanent Address
                    _buildGlassInputField(
                      controller: _permanentAddressController,
                      label: "Permanent Address",
                      icon: Icons.home_outlined,
                      hint: "Enter permanent address",
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
                    SizedBox(height: 14.h),

                    // Confirm Password
                    _buildGlassInputField(
                      controller: _confirmPasswordController,
                      label: "Confirm Password",
                      icon: Icons.lock_outline_rounded,
                      hint: "••••••••",
                      obscureText: _obscureConfirmPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                          color: tc.iconColor,
                          size: 18.sp,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Register Button
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
                        onPressed: _register,
                        child: Text(
                          "Register Now",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Login Footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account?",
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
              prefixIcon: Icon(
                icon,
                color: tc.iconColor,
                size: 18.sp,
              ),
              suffixIcon: suffixIcon,
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

  Widget _buildGlassDropdownField({
    required String label,
    required IconData icon,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
    String hint = "Select option",
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
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          decoration: BoxDecoration(
            color: tc.inputBackground,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: tc.inputBorderColor),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            items: items,
            onChanged: onChanged,
            dropdownColor: tc.cardBackground,
            style: TextStyle(color: tc.inputTextColor, fontSize: 13.sp),
            icon: Icon(
              Icons.arrow_drop_down,
              color: tc.iconColor,
            ),
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
