import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:bd_shope_combined/constants/app_colors.dart';
import 'package:bd_shope_combined/common_widgets/glass_card.dart';
import 'package:bd_shope_combined/controllers/connection_controller.dart';
import 'package:bd_shope_combined/provider/profile_provider.dart';
import 'common_components.dart';

import 'package:bd_shope_combined/controllers/theme_controller.dart';
import 'package:bd_shope_combined/networks/api_acess.dart';

class ProfileTab extends StatefulWidget {
  final TextEditingController storeNameController;
  final TextEditingController storePhoneController;
  final TextEditingController storeAddressController;
  final TextEditingController storeTinController;
  final String loginEmail;
  final VoidCallback onSave;
  final VoidCallback onAddTag;
  final Function(String tagName, String tagId) onRemoveTag;

  const ProfileTab({
    super.key,
    required this.storeNameController,
    required this.storePhoneController,
    required this.storeAddressController,
    required this.storeTinController,
    required this.loginEmail,
    required this.onSave,
    required this.onAddTag,
    required this.onRemoveTag,
  });

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  Widget _buildPremiumInfoTile({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
    bool showCopy = true,
  }) {
    final tc = Get.find<ThemeController>();
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: tc.inputBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: tc.inputBorderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [iconColor.withOpacity(0.15), iconColor.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: iconColor.withOpacity(0.3)),
            ),
            child: Icon(icon, color: iconColor, size: 20.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: tc.textSecondaryColor,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value.isNotEmpty ? value : "Not Set",
                  style: TextStyle(
                    color: value.isNotEmpty ? tc.textColor : tc.textSecondaryColor.withOpacity(0.6),
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (showCopy && value.isNotEmpty)
            IconButton(
              icon: Icon(Icons.copy_rounded, color: tc.textSecondaryColor.withOpacity(0.6), size: 16.sp),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value));
                Get.snackbar(
                  "Copied",
                  "$label copied to clipboard",
                  colorText: Colors.white,
                  backgroundColor: AppColors.c053A4CA.withOpacity(0.9),
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 1),
                  margin: EdgeInsets.all(16.w),
                );
              },
            ),
        ],
      ),
    );
  }

  void _openEditProfileBottomSheet(BuildContext context) {
    final tc = Get.find<ThemeController>();
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(
          top: 16.h,
          left: 16.w,
          right: 16.w,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
        ),
        decoration: BoxDecoration(
          color: tc.cardBackground,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
          border: Border.all(color: tc.inputBorderColor, width: 1.5),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: tc.textSecondaryColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Edit Store Profile",
                    style: TextStyle(color: tc.textColor, fontSize: 16.sp, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: tc.textColor),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              Divider(color: tc.dividerColor),
              SizedBox(height: 12.h),
              buildGlassInputField(
                controller: widget.storeNameController,
                label: "Store Name",
                icon: Icons.store_outlined,
                hint: "Enter store name",
              ),
              SizedBox(height: 12.h),
              buildGlassInputField(
                controller: widget.storePhoneController,
                label: "Contact Phone",
                icon: Icons.phone_outlined,
                hint: "Enter contact phone",
              ),
              SizedBox(height: 12.h),
              buildGlassInputField(
                controller: widget.storeAddressController,
                label: "Store Address",
                icon: Icons.location_on_outlined,
                hint: "Enter address",
              ),
              SizedBox(height: 12.h),
              buildGlassInputField(
                controller: widget.storeTinController,
                label: "TIN Registration ID",
                icon: Icons.assignment_ind_outlined,
                hint: "TIN number",
              ),
              SizedBox(height: 24.h),
              buildActionBtn("Save Updates", () {
                widget.onSave();
                Get.back();
              }),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tc = Get.find<ThemeController>();
    final profileProvider = Provider.of<ProfileProvider>(context);
    
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader("Seller Profile Details"),
        SizedBox(height: 12.h),
        GlassCard(
          borderRadius: 20.r,
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 68.w,
                      height: 68.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.c053A4CA, width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(34.r),
                        child: profileProvider.avatar.startsWith('http')
                            ? Image.network(
                                profileProvider.avatar,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Icon(Icons.person, color: tc.textColor, size: 36),
                              )
                            : (profileProvider.avatar.startsWith('file://')
                                ? Image.file(
                                    File.fromUri(Uri.parse(profileProvider.avatar)),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Icon(Icons.person, color: tc.textColor, size: 36),
                                  )
                                : Image.file(
                                    File(profileProvider.avatar),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Icon(Icons.person, color: tc.textColor, size: 36),
                                  )),
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profileProvider.name,
                            style: TextStyle(color: tc.textColor, fontSize: 16.sp, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            profileProvider.email,
                            style: TextStyle(color: tc.textSecondaryColor, fontSize: 12.sp),
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Icon(Icons.star_rounded, color: Colors.amberAccent, size: 16),
                              SizedBox(width: 4.w),
                              Text(
                                "4.9 Rating • Active Seller",
                                style: TextStyle(color: tc.textSecondaryColor, fontSize: 12.sp),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Divider(color: tc.dividerColor, height: 28),
                
                // Beautiful Theme Mode Switcher
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: tc.inputBackground,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: tc.inputBorderColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            tc.isDarkMode.value ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                            color: tc.textColor,
                            size: 20.sp,
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            "Dark Mode / Light Mode",
                            style: TextStyle(color: tc.textColor, fontSize: 13.sp, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Switch(
                        value: tc.isDarkMode.value,
                        activeColor: AppColors.c053A4CA,
                        onChanged: (val) {
                          tc.toggleTheme();
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),

                // Premium Info Display Section (Data bound to API / ProfileProvider)
                _buildPremiumInfoTile(
                  label: "FULL NAME",
                  value: profileProvider.name,
                  icon: Icons.person_outlined,
                  iconColor: Colors.purpleAccent,
                  showCopy: false,
                ),
                _buildPremiumInfoTile(
                  label: "LOGGED-IN EMAIL (USERNAME)",
                  value: profileProvider.email,
                  icon: Icons.email_outlined,
                  iconColor: Colors.blueAccent,
                ),
                _buildPremiumInfoTile(
                  label: "CONTACT PHONE",
                  value: profileProvider.phone,
                  icon: Icons.phone_outlined,
                  iconColor: Colors.greenAccent,
                ),
                _buildPremiumInfoTile(
                  label: "PRESENT ADDRESS",
                  value: profileProvider.presentAddress,
                  icon: Icons.location_on_outlined,
                  iconColor: Colors.redAccent,
                ),
                _buildPremiumInfoTile(
                  label: "PERMANENT ADDRESS",
                  value: profileProvider.permanentAddress,
                  icon: Icons.home_outlined,
                  iconColor: Colors.orangeAccent,
                ),
                SizedBox(height: 16.h),
                
                GestureDetector(
                  onTap: () => Get.toNamed('/edit_profile'),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: tc.inputBackground,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: tc.inputBorderColor),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.person_outline, color: tc.textColor.withOpacity(0.8), size: 20.sp),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            "Edit Profile Settings",
                            style: TextStyle(color: tc.textColor, fontSize: 13.sp, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, color: tc.textColor.withOpacity(0.4), size: 14.sp),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                GestureDetector(
                  onTap: () => Get.toNamed('/payout_methods'),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: tc.inputBackground,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: tc.inputBorderColor),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.account_balance_wallet_outlined, color: tc.textColor.withOpacity(0.8), size: 20.sp),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            "Payout Settings (Account Info)",
                            style: TextStyle(color: tc.textColor, fontSize: 13.sp, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, color: tc.textColor.withOpacity(0.4), size: 14.sp),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                GestureDetector(
                  onTap: () => Get.toNamed('/privacy_policy'),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: tc.inputBackground,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: tc.inputBorderColor),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.privacy_tip_outlined, color: tc.textColor.withOpacity(0.8), size: 20.sp),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            "Privacy Policy",
                            style: TextStyle(color: tc.textColor, fontSize: 13.sp, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, color: tc.textColor.withOpacity(0.4), size: 14.sp),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                GestureDetector(
                  onTap: () => Get.toNamed('/about'),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: tc.inputBackground,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: tc.inputBorderColor),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: tc.textColor.withOpacity(0.8), size: 20.sp),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            "About Us",
                            style: TextStyle(color: tc.textColor, fontSize: 13.sp, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, color: tc.textColor.withOpacity(0.4), size: 14.sp),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                GestureDetector(
                  onTap: () async {
                    await postLogoutRX.logOut();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: tc.inputBackground,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: tc.inputBorderColor),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.orangeAccent, size: 20.sp),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            "Logout",
                            style: TextStyle(color: tc.textColor, fontSize: 13.sp, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, color: tc.textColor.withOpacity(0.4), size: 14.sp),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                GestureDetector(
                  onTap: () => _showCustomDeleteAccountDialog(context),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: tc.inputBackground,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: tc.inputBorderColor),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.delete_forever_outlined, color: Colors.redAccent, size: 20.sp),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            "Delete Account",
                            style: TextStyle(color: Colors.redAccent, fontSize: 13.sp, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, color: tc.textColor.withOpacity(0.4), size: 14.sp),
                      ],
                    ),
                  ),
                ),
                Divider(color: tc.dividerColor, height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Store Tags",
                      style: TextStyle(
                        color: tc.textColor.withOpacity(0.8),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: widget.onAddTag,
                      icon: Icon(Icons.add, color: AppColors.c053A4CA, size: 16),
                      label: Text("Add Tag", style: TextStyle(color: AppColors.c053A4CA)),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Obx(() {
                  final connectionController = Get.find<ConnectionController>();
                  return Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: connectionController.sellerTags.map((tag) {
                      final tagId = connectionController.sellerTagIds[tag];
                      return InputChip(
                        label: Text(tag, style: TextStyle(color: tc.textColor)),
                        backgroundColor: tc.cardBackground,
                        deleteIcon: Icon(Icons.close_rounded, size: 16, color: Colors.redAccent),
                        onDeleted: tagId != null ? () => widget.onRemoveTag(tag, tagId) : null,
                        side: BorderSide(color: AppColors.c053A4CA.withOpacity(0.4)),
                      );
                    }).toList(),
                  );
                }),
                SizedBox(height: 20.h),
                buildActionBtn("Edit Store Information", () => _openEditProfileBottomSheet(context)),
              ],
            ),
          ),
        ),
      ],
    ));
  }

  void _showCustomDeleteAccountDialog(BuildContext context) {
    final tc = Get.find<ThemeController>();
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    final emailController = TextEditingController(text: profileProvider.email);
    final passwordController = TextEditingController();
    final otpController = TextEditingController();
    
    bool otpSent = false;
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              elevation: 0,
              backgroundColor: tc.cardBackground,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(22.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          color: otpSent ? const Color(0xFFE0F2FE) : const Color(0xFFFEE2E2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          otpSent ? Icons.security : Icons.delete_forever,
                          color: otpSent ? Colors.blue : Colors.red,
                          size: 30,
                        ),
                      ),
                      SizedBox(height: 18),
                      Text(
                        otpSent ? "Verify OTP" : "Delete Account",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: tc.textColor,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        otpSent 
                          ? "Enter the 6-digit OTP code sent to your email to confirm account deletion."
                          : "Enter your email address and password to confirm your identity for account deletion.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: tc.textSecondaryColor,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 16),
                      if (!otpSent) ...[
                        TextField(
                          controller: emailController,
                          style: TextStyle(color: tc.textColor),
                          decoration: InputDecoration(
                            labelText: "Gmail / Email Address",
                            labelStyle: TextStyle(color: tc.textSecondaryColor),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: tc.inputBorderColor),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: const Color(0xFF53A4CA)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(Icons.email_outlined, color: tc.textSecondaryColor),
                          ),
                        ),
                        SizedBox(height: 12),
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          style: TextStyle(color: tc.textColor),
                          decoration: InputDecoration(
                            labelText: "Password",
                            labelStyle: TextStyle(color: tc.textSecondaryColor),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: tc.inputBorderColor),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: const Color(0xFF53A4CA)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(Icons.lock_outline, color: tc.textSecondaryColor),
                          ),
                        ),
                      ] else ...[
                        TextField(
                          controller: otpController,
                          style: TextStyle(color: tc.textColor),
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          decoration: InputDecoration(
                            counterText: "",
                            labelText: "OTP Code",
                            labelStyle: TextStyle(color: tc.textSecondaryColor),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: tc.inputBorderColor),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: const Color(0xFF53A4CA)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(Icons.pin_outlined, color: tc.textSecondaryColor),
                          ),
                        ),
                      ],
                      SizedBox(height: 26),
                      if (isLoading)
                        Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                          ),
                        )
                      else
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  side: BorderSide(color: tc.inputBorderColor),
                                ),
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(
                                    color: tc.textColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (!otpSent) {
                                    final email = emailController.text.trim();
                                    final password = passwordController.text;
                                    if (email.isEmpty) {
                                      Get.snackbar("Error", "Email cannot be empty",
                                          colorText: Colors.white,
                                          backgroundColor: Colors.redAccent);
                                      return;
                                    }
                                    if (password.isEmpty) {
                                      Get.snackbar("Error", "Password cannot be empty",
                                          colorText: Colors.white,
                                          backgroundColor: Colors.redAccent);
                                      return;
                                    }
                                    setState(() { isLoading = true; });
                                    final success = await deleteAccountRx.requestDelete(
                                      email: email,
                                      password: password,
                                    );
                                    setState(() { isLoading = false; });
                                    if (success) {
                                      setState(() { otpSent = true; });
                                    }
                                  } else {
                                    final otp = otpController.text.trim();
                                    if (otp.isEmpty || otp.length < 4) {
                                      Get.snackbar("Error", "Please enter a valid OTP",
                                          colorText: Colors.white,
                                          backgroundColor: Colors.redAccent);
                                      return;
                                    }
                                    setState(() { isLoading = true; });
                                    final success = await deleteAccountRx.confirmDelete(
                                      email: emailController.text.trim(),
                                      otp: otp,
                                    );
                                    setState(() { isLoading = false; });
                                    if (success) {
                                      Navigator.pop(dialogContext);
                                      Get.snackbar(
                                        "Account Deleted",
                                        "Your account has been successfully deleted.",
                                        colorText: Colors.white,
                                        backgroundColor: Colors.redAccent.withOpacity(0.9),
                                      );
                                      await postLogoutRX.logOut();
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  otpSent ? "Confirm" : "Send OTP",
                                  style: TextStyle(
                                    color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            );
          }
        );
      },
    );
  }
}
