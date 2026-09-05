import 'package:bd_shope_combined/controllers/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:bd_shope_combined/common_wigdets/glass_card.dart';
import 'package:bd_shope_combined/common_wigdets/glass_background.dart';
import 'data/support_api.dart';
import 'model/post_support_model.dart';

class BuyerSupportScreen extends StatefulWidget {
  const BuyerSupportScreen({super.key});

  @override
  State<BuyerSupportScreen> createState() => _BuyerSupportScreenState();
}

class _BuyerSupportScreenState extends State<BuyerSupportScreen> {
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
        "Please fill in all fields.",
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
                icon: Icon(Icons.arrow_back, color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black),
                onPressed: () => Get.back(),
              ),
              title: Text(
                'Customer Support',
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
          child: Stack(
            children: [
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 100.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "How can we help you?",
                        style: GoogleFonts.outfit(
                          color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        "Please fill up the details below to raise a support ticket.",
                        style: GoogleFonts.poppins(
                          color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.5),
                          fontSize: 12.sp,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      GlassCard(
                        borderRadius: 24.r,
                        padding: EdgeInsets.all(20.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInputLabel("Your Name"),
                            _buildTextInput(
                              controller: _nameController,
                              hint: "Enter your full name",
                              icon: Icons.person_outline,
                            ),
                            SizedBox(height: 16.h),
                            _buildInputLabel("Phone Number"),
                            _buildTextInput(
                              controller: _phoneController,
                              hint: "Enter your phone number",
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                            ),
                            SizedBox(height: 16.h),
                            _buildInputLabel("Describe your issue"),
                            _buildTextInput(
                              controller: _descController,
                              hint: "Enter issue details here...",
                              icon: Icons.description_outlined,
                              maxLines: 4,
                            ),
                            SizedBox(height: 24.h),
                            Container(
                              width: double.infinity,
                              height: 48.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.r),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF0461D3), Color(0xFF53A4CA)],
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
                                onPressed: _submitSupport,
                                child: Text(
                                  "Submit Ticket",
                                  style: GoogleFonts.poppins(
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
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 24.h,
                right: 24.w,
                child: GestureDetector(
                  onTap: () async {
                    final Uri whatsappUrl = Uri.parse("https://wa.me/8801410189000");
                    try {
                      if (await canLaunchUrl(whatsappUrl)) {
                        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
                      } else {
                        await launchUrl(whatsappUrl, mode: LaunchMode.platformDefault);
                      }
                    } catch (e) {
                      Get.snackbar(
                        "Error",
                        "Could not open WhatsApp. Please save number manually.",
                        colorText: Colors.white,
                        backgroundColor: Colors.redAccent.withOpacity(0.8),
                      );
                    }
                  },
                  child: Container(
                    width: 54.w,
                    height: 54.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFF25D366),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF25D366).withOpacity(0.4),
                          blurRadius: 12.r,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.chat_bubble_rounded,
                        color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                        size: 26,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.7),
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTextInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().cardBackground : Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12.withOpacity(0.1)),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: GoogleFonts.poppins(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, fontSize: 13.sp),
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.only(bottom: maxLines > 1 ? 40.h : 0),
            child: Icon(icon, color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textSecondaryColor : Colors.black54, size: 18.sp),
          ),
          hintText: hint,
          hintStyle: GoogleFonts.poppins(color: Colors.white30, fontSize: 13.sp),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
        ),
      ),
    );
  }
}
