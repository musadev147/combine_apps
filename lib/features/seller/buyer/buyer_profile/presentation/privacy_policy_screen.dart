import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:bd_shope_combined/common_widgets/glass_background_scaffold.dart';
import 'package:bd_shope_combined/common_widgets/glass_card.dart';
import 'package:bd_shope_combined/controllers/theme_controller.dart';
import 'package:bd_shope_combined/networks/api_acess.dart';
import 'package:bd_shope_combined/features/seller/buyer/company_policy/model/get_company_model.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

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
    final tc = Get.find<ThemeController>();
    return Obx(() => GlassBackgroundScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: tc.textColor),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Privacy Policy',
          style: TextStyle(
            color: tc.textColor,
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF53A4CA)))
          : StreamBuilder<GetCompanyModel>(
              stream: getCompanyPolicyRx.valueStreamData,
              builder: (context, snapshot) {
                final model = snapshot.data;
                final user = model?.user;

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  child: GlassCard(
                    borderRadius: 20.r,
                    child: Padding(
                      padding: EdgeInsets.all(20.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Company Policy & Privacy',
                            style: TextStyle(
                              color: tc.textColor,
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            'Last Updated: July 2026',
                            style: TextStyle(
                              color: tc.textSecondaryColor,
                              fontSize: 12.sp,
                            ),
                          ),
                          Divider(color: tc.dividerColor, height: 30.h),
                          
                          if (user != null) ...[
                            _buildSection(
                              tc,
                              title: 'Company Identity',
                              body: 'Name: ${user.name ?? "Damadami"}\nRole: ${user.role ?? "Provider"}',
                            ),
                            if (user.email != null && user.email!.isNotEmpty)
                              _buildSection(
                                tc,
                                title: 'Contact Information',
                                body: 'For policy inquiries, email: ${user.email}\nPhone: ${user.phoneNumber ?? "N/A"}',
                              ),
                            if (user.presentAddress != null && user.presentAddress!.isNotEmpty)
                              _buildSection(
                                tc,
                                title: 'Present Office Location',
                                body: user.presentAddress!,
                              ),
                            if (user.permanentAddress != null && user.permanentAddress!.isNotEmpty)
                              _buildSection(
                                tc,
                                title: 'Registered Headquarters',
                                body: user.permanentAddress!,
                              ),
                          ],

                          _buildSection(
                            tc,
                            title: '1. Information We Collect',
                            body: 'We collect personal information that you provide to us, including your name, email address, phone number, and store/profile details when you create an account, communicate with other users, or make transactions.',
                          ),
                          _buildSection(
                            tc,
                            title: '2. How We Use Your Information',
                            body: 'We use your information to facilitate transactions, improve our services, manage user profiles, send important notifications, and ensure the safety and security of our platform.',
                          ),
                          _buildSection(
                            tc,
                            title: '3. Data Security',
                            body: 'We implement top-tier physical and electronic security protocols to protect your personal information from unauthorized access, alteration, disclosure, or destruction.',
                          ),
                          _buildSection(
                            tc,
                            title: '4. Third-Party Services',
                            body: 'We do not sell, trade, or transfer your personal data to outside parties, except for trusted third parties assisting us in operating our app and processing transactions under strict confidentiality agreements.',
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    ));
  }

  Widget _buildSection(ThemeController tc, {required String title, required String body}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: tc.textColor,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            body,
            style: TextStyle(
              color: tc.textColor.withOpacity(0.8),
              fontSize: 13.sp,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
