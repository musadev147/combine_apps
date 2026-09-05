import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:bd_shope_combined/constants/app_colors.dart';
import 'package:bd_shope_combined/common_widgets/glass_card.dart';
import 'common_components.dart';
import 'package:bd_shope_combined/controllers/theme_controller.dart';
import 'package:bd_shope_combined/features/seller/home/presentation/data/support_api.dart';
import 'package:bd_shope_combined/features/seller/home/presentation/model/post_support_model.dart';

class SupportTab extends StatefulWidget {
  const SupportTab({super.key});

  @override
  State<SupportTab> createState() => _SupportTabState();
}

class _SupportTabState extends State<SupportTab> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submitSupport() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final desc = _descController.text.trim();

    if (name.isEmpty || phone.isEmpty || desc.isEmpty) {
      Get.snackbar(
        "Validation Error",
        "Please fill in all the fields.",
        colorText: Colors.white,
        backgroundColor: Colors.redAccent.withOpacity(0.8),
      );
      return;
    }

    try {
      EasyLoading.show(status: "Submitting ticket...");
      final ticket = PostSupportModel(
        name: name,
        phoneNumber: phone,
        description: desc,
        status: 'PENDING',
      );

      final success = await SupportApi.instance.submitSupportTicket(ticket);
      EasyLoading.dismiss();

      if (success) {
        Get.snackbar(
          "Success",
          "Your support request has been submitted successfully!",
          colorText: Colors.white,
          backgroundColor: Colors.greenAccent.withOpacity(0.8),
        );
        _nameController.clear();
        _phoneController.clear();
        _descController.clear();
      } else {
        Get.snackbar(
          "Error",
          "Failed to submit support ticket. Please try again.",
          colorText: Colors.white,
          backgroundColor: Colors.redAccent.withOpacity(0.8),
        );
      }
    } catch (e) {
      EasyLoading.dismiss();
      Get.snackbar(
        "Error",
        "An unexpected error occurred: $e",
        colorText: Colors.white,
        backgroundColor: Colors.redAccent.withOpacity(0.8),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tc = Get.find<ThemeController>();
    return Obx(() => SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.only(bottom: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildSectionHeader("Contact Support Center"),
            SizedBox(height: 12.h),
            GlassCard(
              borderRadius: 20.r,
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildGlassInputField(
                      controller: _nameController,
                      label: "Your Name",
                      icon: Icons.person_outline,
                      hint: "Enter your full name",
                    ),
                    SizedBox(height: 12.h),
                    buildGlassInputField(
                      controller: _phoneController,
                      label: "Phone Number",
                      icon: Icons.phone_outlined,
                      hint: "Enter your contact phone",
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      "Description",
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
                        controller: _descController,
                        maxLines: 4,
                        style: TextStyle(color: tc.inputTextColor, fontSize: 13.sp),
                        decoration: InputDecoration(
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(bottom: 40.h),
                            child: Icon(Icons.description_outlined, color: tc.iconColor, size: 18.sp),
                          ),
                          hintText: "Describe your issue here...",
                          hintStyle: TextStyle(color: tc.inputHintColor, fontSize: 13.sp),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    buildActionBtn("Submit Ticket", _submitSupport),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
