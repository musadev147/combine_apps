import 'package:bd_shope_combined/controllers/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:bd_shope_combined/common_wigdets/glass_background.dart';
import 'package:bd_shope_combined/common_wigdets/glass_card.dart';
import 'package:bd_shope_combined/networks/api_acess.dart';
import 'model/get_company_model.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      await getCompanyPolicyRx.fetchCompanyPolicies();
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Privacy Policy',
            style: GoogleFonts.outfit(
              color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20.sp,
            ),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF53A4CA)))
            : StreamBuilder<GetCompanyModel>(
                stream: getCompanyPolicyRx.valueStreamData,
                builder: (context, snapshot) {
                  final model = snapshot.data;
                  final user = model?.user;

                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    child: GlassCard(
                      borderRadius: 20.r,
                      padding: EdgeInsets.all(20.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Company Policy & Privacy',
                            style: GoogleFonts.outfit(
                              color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            'Last Updated: July 2026',
                            style: GoogleFonts.poppins(
                              color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.5),
                              fontSize: 12.sp,
                            ),
                          ),
                          Divider(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12.withOpacity(0.1), height: 30.h),

                          if (user != null) ...[
                            _buildSection(
                              title: 'Company Identity',
                              body: 'Name: ${user.name ?? "Damadami"}\nRole: ${user.role ?? "Provider"}',
                            ),
                            if (user.email != null && user.email!.isNotEmpty)
                              _buildSection(
                                title: 'Contact Information',
                                body: 'For policy inquiries, email: ${user.email}\nPhone: ${user.phoneNumber ?? "N/A"}',
                              ),
                            if (user.presentAddress != null && user.presentAddress!.isNotEmpty)
                              _buildSection(
                                title: 'Present Office Location',
                                body: user.presentAddress!,
                              ),
                            if (user.permanentAddress != null && user.permanentAddress!.isNotEmpty)
                              _buildSection(
                                title: 'Registered Headquarters',
                                body: user.permanentAddress!,
                              ),
                          ],

                          _buildSection(
                            title: '1. Information We Collect',
                            body: 'We collect personal information that you provide to us, including your name, email address, phone number, and store/profile details when you create an account, communicate with other users, or make transactions.',
                          ),
                          _buildSection(
                            title: '2. How We Use Your Information',
                            body: 'We use your information to facilitate transactions, improve our services, manage user profiles, send important notifications, and ensure the safety and security of our platform.',
                          ),
                          _buildSection(
                            title: '3. Data Security',
                            body: 'We implement top-tier physical and electronic security protocols to protect your personal information from unauthorized access, alteration, disclosure, or destruction.',
                          ),
                          _buildSection(
                            title: '4. Third-Party Services',
                            body: 'We do not sell, trade, or transfer your personal data to outside parties, except for trusted third parties assisting us in operating our app and processing transactions under strict confidentiality agreements.',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildSection({required String title, required String body}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            body,
            style: GoogleFonts.poppins(
              color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.8),
              fontSize: 13.sp,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
