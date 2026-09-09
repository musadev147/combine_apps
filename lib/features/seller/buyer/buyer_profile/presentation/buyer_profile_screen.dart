import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:bd_shope_combined/route/app_pages.dart';
import 'package:bd_shope_combined/common_widgets/glass_card.dart';
import 'package:bd_shope_combined/provider/profile_provider.dart';
import 'package:bd_shope_combined/common_widgets/glass_background_scaffold.dart';
import 'package:bd_shope_combined/controllers/theme_controller.dart';
import 'package:bd_shope_combined/networks/api_acess.dart';

class BuyerProfileScreen extends StatelessWidget {
  const BuyerProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tc = Get.find<ThemeController>();
    final profileProvider = Provider.of<ProfileProvider>(context);

    return Obx(
      () => GlassBackgroundScaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: tc.textColor),
            onPressed: () => Get.back(),
          ),
          title: Text(
            'Buyer Profile',
            style: GoogleFonts.outfit(
              color: tc.textColor,
              fontWeight: FontWeight.w700,
              fontSize: 20.sp,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.r),
            child: Column(
              children: [
                // User Avatar & Name
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(4.r),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF53A4CA),
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 50.r,
                          backgroundColor: Colors.grey[800],
                          backgroundImage:
                              profileProvider.avatar.startsWith('http')
                              ? NetworkImage(profileProvider.avatar)
                                    as ImageProvider
                              : (profileProvider.avatar.startsWith('file://')
                                    ? FileImage(
                                        File.fromUri(
                                          Uri.parse(profileProvider.avatar),
                                        ),
                                      )
                                    : FileImage(File(profileProvider.avatar))),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        profileProvider.name,
                        style: GoogleFonts.outfit(
                          color: tc.textColor,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        profileProvider.email,
                        style: GoogleFonts.poppins(
                          color: tc.textSecondaryColor,
                          fontSize: 13.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 36.h),

                // Menu Card
                GlassCard(
                  borderRadius: 24.r,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Column(
                      children: [
                        _buildMenuItem(
                          tc,
                          icon: Icons.person_outline,
                          title: 'Edit Profile',
                          onTap: () {
                            Get.toNamed(Routes.EDIT_PROFILE);
                          },
                        ),
                        _buildMenuItem(
                          tc,
                          icon: Icons.privacy_tip_outlined,
                          title: 'Privacy Policy',
                          onTap: () {
                            Get.toNamed(Routes.PRIVACY_POLICY);
                          },
                        ),
                        _buildMenuItem(
                          tc,
                          icon: Icons.info_outline,
                          title: 'About Us',
                          onTap: () {
                            Get.toNamed(Routes.ABOUT);
                          },
                        ),
                        _buildMenuItem(
                          tc,
                          icon: Icons.delete_forever_outlined,
                          title: 'Delete Account',
                          textColor: Colors.redAccent,
                          onTap: () {
                            _showCustomDeleteAccountDialog(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    ThemeController tc, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? tc.textColor.withOpacity(0.8)),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          color: textColor ?? tc.textColor,
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: tc.textColor.withOpacity(0.3),
        size: 14.r,
      ),
      onTap: onTap,
    );
  }

  void _showCustomDeleteAccountDialog(BuildContext context) {
    final tc = Get.find<ThemeController>();
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
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
                          color: otpSent
                              ? const Color(0xFFE0F2FE)
                              : const Color(0xFFFEE2E2),
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
                              borderSide: BorderSide(
                                color: tc.inputBorderColor,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: const Color(0xFF53A4CA),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: tc.textSecondaryColor,
                            ),
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
                              borderSide: BorderSide(
                                color: tc.inputBorderColor,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: const Color(0xFF53A4CA),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: tc.textSecondaryColor,
                            ),
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
                              borderSide: BorderSide(
                                color: tc.inputBorderColor,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: const Color(0xFF53A4CA),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(
                              Icons.pin_outlined,
                              color: tc.textSecondaryColor,
                            ),
                          ),
                        ),
                      ],
                      SizedBox(height: 26),
                      if (isLoading)
                        Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.red,
                            ),
                          ),
                        )
                      else
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
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
                                      Get.snackbar(
                                        "Error",
                                        "Email cannot be empty",
                                        colorText: Colors.white,
                                        backgroundColor: Colors.redAccent,
                                      );
                                      return;
                                    }
                                    if (password.isEmpty) {
                                      Get.snackbar(
                                        "Error",
                                        "Password cannot be empty",
                                        colorText: Colors.white,
                                        backgroundColor: Colors.redAccent,
                                      );
                                      return;
                                    }
                                    setState(() {
                                      isLoading = true;
                                    });
                                    final success = await deleteAccountRx
                                        .requestDelete(
                                          email: email,
                                          password: password,
                                        );
                                    setState(() {
                                      isLoading = false;
                                    });
                                    if (success) {
                                      setState(() {
                                        otpSent = true;
                                      });
                                    }
                                  } else {
                                    final otp = otpController.text.trim();
                                    if (otp.isEmpty || otp.length < 4) {
                                      Get.snackbar(
                                        "Error",
                                        "Please enter a valid OTP",
                                        colorText: Colors.white,
                                        backgroundColor: Colors.redAccent,
                                      );
                                      return;
                                    }
                                    setState(() {
                                      isLoading = true;
                                    });
                                    final success = await deleteAccountRx
                                        .confirmDelete(
                                          email: emailController.text.trim(),
                                          otp: otp,
                                        );
                                    setState(() {
                                      isLoading = false;
                                    });
                                    if (success) {
                                      Navigator.pop(dialogContext);
                                      Get.snackbar(
                                        "Account Deleted",
                                        "Your account has been successfully deleted.",
                                        colorText: Colors.white,
                                        backgroundColor: Colors.redAccent
                                            .withOpacity(0.9),
                                      );
                                      await postLogoutRX.logOut(isSeller: true);
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  otpSent ? "Confirm" : "Send OTP",
                                  style: TextStyle(
                                    color: Colors.white,
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
          },
        );
      },
    );
  }
}
