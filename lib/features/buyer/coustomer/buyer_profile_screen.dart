import 'package:bd_shope_combined/controllers/theme_controller.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:bd_shope_combined/route/app_pages.dart';
import 'package:bd_shope_combined/common_wigdets/glass_card.dart';
import 'package:bd_shope_combined/constants/app_constants.dart';
import 'package:bd_shope_combined/helpers/di.dart';
import 'package:bd_shope_combined/provider/profile_provider.dart';
import 'package:bd_shope_combined/features/buyer/chat/controllers/chat_controller.dart';
import 'package:bd_shope_combined/features/buyer/chat/models/conversation.dart';
import 'package:bd_shope_combined/features/buyer/chat/models/message.dart';
import 'package:bd_shope_combined/common_wigdets/custom_log_out.dart';
import 'package:bd_shope_combined/common_wigdets/glass_background.dart';
import 'buyer_support_screen.dart';
import 'package:bd_shope_combined/networks/api_acess.dart';

class BuyerProfileScreen extends StatelessWidget {
  const BuyerProfileScreen({Key? key}) : super(key: key);

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
              title: Text(
                'My Profile',
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
          padding: EdgeInsets.all(24.r),
          child: Consumer<ProfileProvider>(
            builder: (context, profileProvider, child) {
              return Column(
                children: [
                  // User Avatar & Name
                  Center(
                    child: Column(
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
                            child: profileProvider.avatar.isEmpty
                                ? Icon(Icons.person, size: 50.r, color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textSecondaryColor : Colors.black54)
                                : null,
                            backgroundImage: profileProvider.avatar.isEmpty
                                ? null
                                : (profileProvider.avatar.startsWith('http')
                                    ? NetworkImage(profileProvider.avatar) as ImageProvider
                                    : (profileProvider.avatar.startsWith('file://')
                                        ? FileImage(File.fromUri(Uri.parse(profileProvider.avatar)))
                                        : FileImage(File(profileProvider.avatar)))),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          profileProvider.name,
                          style: GoogleFonts.outfit(
                            color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          profileProvider.email,
                          style: GoogleFonts.poppins(
                            color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.6),
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
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Column(
                      children: [
                        _buildMenuItem(
                          icon: Icons.person_outline,
                          title: 'Edit Profile',
                          onTap: () {
                            Get.toNamed(Routes.EDIT_PROFILE);
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.support_agent_outlined,
                          title: 'Customer Support',
                          onTap: () {
                            Get.to(() => const BuyerSupportScreen());
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.privacy_tip_outlined,
                          title: 'Privacy Policy',
                          onTap: () {
                            Get.toNamed(Routes.PRIVACY_POLICY);
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.info_outline,
                          title: 'About Us',
                          onTap: () {
                            Get.toNamed(Routes.ABOUT);
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Log Out & Delete Account Card
                  GlassCard(
                    borderRadius: 24.r,
                    padding: EdgeInsets.symmetric(vertical: 4.h),
                    child: Column(
                      children: [
                        _buildMenuItem(
                          icon: Icons.logout,
                          title: 'Log Out',
                          onTap: () {
                            showCustomLogoutDialog(context);
                          },
                          textColor: Colors.redAccent,
                        ),
                        _buildDivider(),
                        _buildMenuItem(
                          icon: Icons.delete_forever_outlined,
                          title: 'Delete Account',
                          onTap: () {
                            _showCustomDeleteAccountDialog(context);
                          },
                          textColor: Colors.redAccent,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    ));
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? (Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor.withOpacity(0.8) : Colors.black87)),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          color: textColor ?? (Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black),
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.3), size: 14.r),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12.withOpacity(0.08),
      height: 1,
      indent: 16.w,
      endIndent: 16.w,
    );
  }

  void _showCustomDeleteAccountDialog(BuildContext context) {
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
              backgroundColor: Colors.white,
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
                      const SizedBox(height: 18),
                      Text(
                        otpSent ? "Verify OTP" : "Delete Account",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        otpSent 
                          ? "Enter the 6-digit OTP code sent to your email to confirm account deletion."
                          : "Enter your email address and password to confirm your identity for account deletion.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (!otpSent) ...[
                        TextField(
                          controller: emailController,
                          style: TextStyle(color: Colors.black87),
                          decoration: InputDecoration(
                            labelText: "Gmail / Email Address",
                            labelStyle: TextStyle(color: Colors.black54),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Color(0xFF53A4CA)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(Icons.email_outlined, color: Colors.black54),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          style: TextStyle(color: Colors.black87),
                          decoration: InputDecoration(
                            labelText: "Password",
                            labelStyle: TextStyle(color: Colors.black54),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Color(0xFF53A4CA)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(Icons.lock_outline, color: Colors.black54),
                          ),
                        ),
                      ] else ...[
                        TextField(
                          controller: otpController,
                          style: TextStyle(color: Colors.black87),
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          decoration: InputDecoration(
                            counterText: "",
                            labelText: "OTP Code",
                            labelStyle: TextStyle(color: Colors.black54),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Color(0xFF53A4CA)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(Icons.pin_outlined, color: Colors.black54),
                          ),
                        ),
                      ],
                      const SizedBox(height: 26),
                      if (isLoading)
                        const Center(
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
                                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                                ),
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (!otpSent) {
                                    final email = emailController.text.trim();
                                    final password = passwordController.text;
                                    if (email.isEmpty) {
                                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                                        const SnackBar(content: Text("Email cannot be empty"), backgroundColor: Colors.red),
                                      );
                                      return;
                                    }
                                    if (password.isEmpty) {
                                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                                        const SnackBar(content: Text("Password cannot be empty"), backgroundColor: Colors.red),
                                      );
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
                                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                                        const SnackBar(content: Text("Please enter a valid OTP"), backgroundColor: Colors.red),
                                      );
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
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Account successfully deleted"), backgroundColor: Colors.red),
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
          }
        );
      },
    );
  }
}
