import 'package:bd_shope_combined/controllers/theme_controller.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:bd_shope_combined/common_wigdets/glass_background.dart';
import 'package:bd_shope_combined/common_wigdets/glass_text_field.dart';
import 'package:bd_shope_combined/common_wigdets/glass_button.dart';
import 'package:bd_shope_combined/networks/api_acess.dart';
import 'package:bd_shope_combined/provider/profile_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source, imageQuality: 80);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error selecting image: $e");
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E38),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black),
                title: Text('Take Photo', style: GoogleFonts.poppins(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black),
                title: Text('Choose from Gallery', style: GoogleFonts.poppins(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }



  void _saveProfile() {
    if (_formKey.currentState!.validate()) {

      final profile = Provider.of<ProfileProvider>(context, listen: false);
      
      // Update local file if selected
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
    
    return GlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.h),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12.withOpacity(0.1), width: 1),
              ),
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black),
                onPressed: () => Get.back(),
              ),
              title: Text(
                'Edit Profile',
                style: GoogleFonts.outfit(
                  color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 20.sp,
                ),
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Avatar Edit Area
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          padding: EdgeInsets.all(4.r),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF53A4CA), width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 50.r,
                            backgroundColor: Colors.grey[800],
                             backgroundImage: _selectedImage != null
                                 ? FileImage(_selectedImage!) as ImageProvider
                                 : (profile.avatar.startsWith('http')
                                     ? NetworkImage(profile.avatar) as ImageProvider
                                     : (profile.avatar.startsWith('file://')
                                         ? FileImage(File.fromUri(Uri.parse(profile.avatar)))
                                         : FileImage(File(profile.avatar)))),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _showImagePickerOptions,
                            child: Container(
                              padding: EdgeInsets.all(6.r),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF53A4CA),
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),

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

                  // Email
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

                  // Phone
                  GlassTextField(
                    controller: _phoneController,
                    labelText: 'Phone Number',
                    hintText: 'Enter phone number',
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
                    hintText: 'Enter present address',
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
                    hintText: 'Enter permanent address',
                    prefixIcon: Icon(Icons.home_outlined),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Permanent address is required';
                      }
                      return null;
                    },
                  ),

                  // Save Button
                  GlassButton(
                    text: 'Save Changes',
                    onTap: _saveProfile,
                    style: GlassButtonStyle.gradient,
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
