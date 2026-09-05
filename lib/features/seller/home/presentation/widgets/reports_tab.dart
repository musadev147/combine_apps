import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:bd_shope_combined/constants/app_colors.dart';
import 'package:bd_shope_combined/common_widgets/glass_card.dart';
import 'common_components.dart';
import 'package:bd_shope_combined/controllers/theme_controller.dart';

class ReportsTab extends StatelessWidget {
  final Function(String) onGenerateReport;

  const ReportsTab({
    super.key,
    required this.onGenerateReport,
  });

  @override
  Widget build(BuildContext context) {
    final tc = Get.find<ThemeController>();
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader("Business & Sales Reports"),
        SizedBox(height: 12.h),
        _buildReportOptionCard(tc, icon: Icons.assignment_turned_in, title: "Sales Reports", desc: "Detailed breakdown of top selling units and items.", onTap: () => onGenerateReport("Sales Report")),
        _buildReportOptionCard(tc, icon: Icons.account_balance, title: "Revenue Reports", desc: "Understand your tax settlements and payout schedules.", onTap: () => onGenerateReport("Revenue Report")),
        _buildReportOptionCard(tc, icon: Icons.people_outline, title: "Customer Reports", desc: "Identify top customers and repeating buyers.", onTap: () => onGenerateReport("Customer Report")),
        _buildReportOptionCard(tc, icon: Icons.trending_up, title: "Product Performance", desc: "Analyze dynamic listings performance and impressions.", onTap: () => onGenerateReport("Product Performance Report")),
      ],
    ));
  }

  Widget _buildReportOptionCard(ThemeController tc, {required IconData icon, required String title, required String desc, required VoidCallback onTap}) {
    return GlassCard(
      borderRadius: 16.r,
      margin: EdgeInsets.symmetric(vertical: 4.h),
      backgroundColor: tc.inputBackground,
      child: ListTile(
        leading: Icon(icon, color: AppColors.c7953CA),
        title: Text(title, style: TextStyle(color: tc.textColor, fontWeight: FontWeight.bold)),
        subtitle: Text(desc, style: TextStyle(color: tc.textSecondaryColor)),
        trailing: Icon(Icons.arrow_forward_ios, color: tc.textColor, size: 14),
        onTap: onTap,
      ),
    );
  }
}
