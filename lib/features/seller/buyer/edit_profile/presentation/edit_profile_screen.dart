import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:bd_shope_combined/common_widgets/glass_background_scaffold.dart';
import 'package:bd_shope_combined/common_widgets/glass_card.dart';
import 'package:bd_shope_combined/constants/app_colors.dart';
import 'package:bd_shope_combined/networks/api_acess.dart';
import 'package:bd_shope_combined/provider/profile_provider.dart';
import 'package:bd_shope_combined/controllers/theme_controller.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _ProfileTabState {} // Placeholder to avoid conflict

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _presentAddressController;
  late TextEditingController _permanentAddressController;
  
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<ProfileProvider>(context, listen: false);
    _nameController = TextEditingController(text: profile.name);
    _emailController = TextEditingController(text: profile.email);
    _phoneController = TextEditingController(text: profile.phone);
    _presentAddressController = TextEditingController(text: profile.presentAddress);
    _permanentAddressController = TextEditingController(text: profile.permanentAddress);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _presentAddressController.dispose();
    _permanentAddressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
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

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final profile = Provider.of<ProfileProvider>(context, listen: false);
      if (_selectedImage != null) {
        profile.file(_selectedImage);
      }

      editProfileRx.editProfileFunc(
        context: context,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        presentAddress: _presentAddressController.text.trim(),
        permanentAddress: _permanentAddressController.text.trim(),
        image: _selectedImage,
      ).then((success) {
        if (success) {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            Get.back();
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileProvider>(context);
    final tc = Get.find<ThemeController>();

    return Obx(() => GlassBackgroundScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: tc.textColor),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: tc.textColor,
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Form(
            key: _formKey,
            child: GlassCard(
              borderRadius: 24.r,
              backgroundColor: tc.isDarkMode.value ? Colors.black.withOpacity(0.25) : Colors.white.withOpacity(0.6),
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Avatar Picker
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          children: [
                            Container(
                              width: 90.r,
                              height: 90.r,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: tc.textColor.withOpacity(0.3),
                                  width: 2.w,
                                ),
                                color: tc.textColor.withOpacity(0.1),
                              ),
                              child: _selectedImage != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(45.r),
                                      child: Image.file(
                                        _selectedImage!,
                                        fit: BoxFit.cover,
                                        width: 90.r,
                                        height: 90.r,
                                      ),
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(45.r),
                                      child: profile.avatar.startsWith('http')
                                          ? Image.network(
                                              profile.avatar,
                                              fit: BoxFit.cover,
                                              width: 90.r,
                                              height: 90.r,
                                            )
                                          : (profile.avatar.startsWith('file://')
                                              ? Image.file(
                                                  File.fromUri(Uri.parse(profile.avatar)),
                                                  fit: BoxFit.cover,
                                                  width: 90.r,
                                                  height: 90.r,
                                                )
                                              : Image.file(
                                                  File(profile.avatar),
                                                  fit: BoxFit.cover,
                                                  width: 90.r,
                                                  height: 90.r,
                                                )),
                                    ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                               child: Container(
                                padding: EdgeInsets.all(6.r),
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
                    SizedBox(height: 24.h),

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
                      hint: "Enter email address",
                    ),
                    SizedBox(height: 14.h),

                    // Phone Number
                    _buildGlassInputField(
                      controller: _phoneController,
                      label: "Phone Number",
                      icon: Icons.phone_outlined,
                      hint: "Enter phone number",
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
                    SizedBox(height: 24.h),

                    // Save Button
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
                        onPressed: _saveProfile,
                        child: Text(
                          "Save Changes",
                          style: TextStyle(
                            color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
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
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '$label is required';
              }
              return null;
            },
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
