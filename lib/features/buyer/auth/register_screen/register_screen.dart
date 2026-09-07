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
import 'model/register_model.dart';
import 'model/register_role.dart';
import 'dart:ui';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _permanentAddressController = TextEditingController();
  final _presentAddressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  File? _avatarFile;
  String? _selectedRoleId;

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
    _permanentAddressController.dispose();
    _presentAddressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _avatarFile = File(pickedFile.path);
      });
    }
  }

  void _onRegister() async {
    if (_formKey.currentState!.validate()) {
      String? resolvedRole = _selectedRoleId;
      if (resolvedRole == null) {
        final rolesList = getRolesRx.valueStreamData.valueOrNull ?? [];
        if (rolesList.isNotEmpty) {
          final defaultRole = rolesList.firstWhere(
            (role) => role.value?.toLowerCase() == 'buyer',
            orElse: () => rolesList.first,
          );
          resolvedRole = defaultRole.id;
        }
      }
      resolvedRole ??= 'buyer';

      final email = _emailController.text.trim();
      final phone = _phoneController.text.trim();

      bool success = await postRegisterRx.signUpdata(
        name: _nameController.text.trim(),
        email: email,
        password: _passwordController.text,
        password_confirmation: _confirmPasswordController.text,
        role: resolvedRole,
        phoneNumber: phone,
        permanentAddress: _permanentAddressController.text.trim(),
        presentAddress: _presentAddressController.text.trim(),
        avatar: _avatarFile,
      );

      if (success) {
        Get.toNamed(Routes.OTP, arguments: {'email': email, 'fromRegister': true});
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
                  SizedBox(height: 10.h),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.arrow_back_ios, color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Create Account',
                    style: GoogleFonts.outfit(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w700,
                      color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Join the premium marketplace directly',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(height: 28.h),

                  // Profile Image Picker
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF53A4CA).withOpacity(0.6),
                                width: 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF53A4CA).withOpacity(0.2),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 50.r,
                              backgroundColor: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().cardBackground : Colors.white.withOpacity(0.08),
                              backgroundImage: _avatarFile != null ? FileImage(_avatarFile!) : null,
                              child: _avatarFile == null
                                  ? Icon(
                                      Icons.person,
                                      size: 50.r,
                                      color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textSecondaryColor : Colors.black54,
                                    )
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(8.r),
                              decoration: const BoxDecoration(
                                color: Color(0xFF53A4CA),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.camera_alt_outlined,
                                size: 16.r,
                                color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Full Name
                  GlassTextField(
                    controller: _nameController,
                    labelText: 'Full Name',
                    hintText: 'Enter your full name',
                    prefixIcon: Icon(Icons.person_outline),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Name is required';
                      }
                      return null;
                    },
                  ),

                  // Email Address
                  GlassTextField(
                    controller: _emailController,
                    labelText: 'Email Address',
                    hintText: 'Enter your email for OTP verification',
                    prefixIcon: Icon(Icons.email_outlined),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email is required for OTP verification';
                      }
                      if (!GetUtils.isEmail(value.trim())) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ),

                  // Phone Number
                  GlassTextField(
                    controller: _phoneController,
                    labelText: 'Phone Number',
                    hintText: 'Enter your phone number',
                    prefixIcon: Icon(Icons.phone_outlined),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Phone number is required';
                      }
                      return null;
                    },
                  ),

                  // Present Address
                  GlassTextField(
                    controller: _presentAddressController,
                    labelText: 'Present Address',
                    hintText: 'Enter your present address',
                    prefixIcon: Icon(Icons.location_on_outlined),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Present address is required';
                      }
                      return null;
                    },
                  ),

                  // Permanent Address
                  GlassTextField(
                    controller: _permanentAddressController,
                    labelText: 'Permanent Address',
                    hintText: 'Enter your permanent address',
                    prefixIcon: Icon(Icons.home_outlined),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Permanent address is required';
                      }
                      return null;
                    },
                  ),


                  // Password
                  GlassTextField(
                    controller: _passwordController,
                    labelText: 'Password',
                    hintText: 'Enter a strong password',
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
                    hintText: 'Confirm your password',
                    prefixIcon: Icon(Icons.lock_reset),
                    isPassword: true,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _onRegister(),
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24.h),

                  // Register Button
                  GlassButton(
                    text: 'Sign Up',
                    onTap: _onRegister,
                    style: GlassButtonStyle.gradient,
                  ),
                  SizedBox(height: 24.h),

                  // Bottom Navigation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: GoogleFonts.poppins(
                          color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.6),
                          fontSize: 13.sp,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Get.offNamed(Routes.LOGIN),
                        child: Text(
                          'Log In',
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
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GlassDropdownField extends StatelessWidget {
  final String labelText;
  final String hintText;
  final Widget prefixIcon;
  final String? value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;
  final FormFieldValidator<String>? validator;

  const GlassDropdownField({
    Key? key,
    required this.labelText,
    required this.hintText,
    required this.prefixIcon,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().cardBackground : Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: DropdownButtonFormField<String>(
              value: value,
              items: items,
              onChanged: onChanged,
              validator: validator,
              dropdownColor: const Color(0xFF1E1E38),
              icon: Icon(Icons.arrow_drop_down, color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.7)),
              style: TextStyle(
                color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                fontSize: 15.sp,
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                labelText: labelText,
                labelStyle: TextStyle(
                  color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.7),
                  fontSize: 13.sp,
                ),
                hintText: hintText,
                hintStyle: TextStyle(
                  color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.4),
                  fontSize: 13.sp,
                ),
                prefixIcon: IconTheme(
                  data: IconThemeData(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.7)),
                  child: prefixIcon,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: 14.h,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
