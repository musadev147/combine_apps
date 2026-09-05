import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:bd_shope_combined/constants/app_colors.dart';
import 'package:bd_shope_combined/common_widgets/glass_card.dart';
import 'package:bd_shope_combined/features/seller/call/presentation/data/call_controller.dart';
import 'package:bd_shope_combined/features/seller/home/presentation/model/sub_category_model.dart';
import 'common_components.dart';
import 'package:bd_shope_combined/controllers/theme_controller.dart';
import 'package:bd_shope_combined/networks/api_acess.dart';
import 'package:bd_shope_combined/features/seller/home/presentation/data/category_api.dart';
import 'package:bd_shope_combined/features/seller/home/presentation/data/invoice_api.dart';

class DashboardTab extends StatefulWidget {
  final VoidCallback onViewInvoices;
  final VoidCallback onSupportCenter;
  final int pendingInvoicesCount;
  final int? refreshTrigger;

  const DashboardTab({
    super.key,
    required this.onViewInvoices,
    required this.onSupportCenter,
    required this.pendingInvoicesCount,
    this.refreshTrigger = 0,
  });

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  double _paidBalance = 0.0;
  double _pendingBalance = 0.0;
  double _rejectedBalance = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  @override
  void didUpdateWidget(covariant DashboardTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.refreshTrigger != oldWidget.refreshTrigger) {
      _fetchDashboardData();
    }
  }

  Future<void> _fetchDashboardData() async {
    try {
      final balanceData = await InvoiceApi.instance.fetchDailyBalance();
      if (balanceData != null && mounted) {
        setState(() {
          _paidBalance = double.tryParse(balanceData["paid_balance"]?.toString() ?? '0') ?? 0.0;
          _pendingBalance = double.tryParse(balanceData["pending_balance"]?.toString() ?? '0') ?? 0.0;
          _rejectedBalance = double.tryParse(balanceData["rejected_balance"]?.toString() ?? '0') ?? 0.0;
          _isLoading = false;
        });
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  IconData _getCategoryIcon(String? name) {
    final lowerName = (name ?? "").toLowerCase();
    if (lowerName.contains("electronics") || lowerName.contains("device")) return Icons.devices;
    if (lowerName.contains("fashion") || lowerName.contains("clothing") || lowerName.contains("dress")) return Icons.checkroom;
    if (lowerName.contains("vehicle") || lowerName.contains("bike") || lowerName.contains("car")) return Icons.directions_car;
    if (lowerName.contains("home") || lowerName.contains("living") || lowerName.contains("furniture")) return Icons.weekend;
    if (lowerName.contains("job") || lowerName.contains("work")) return Icons.work_outline;
    if (lowerName.contains("laptop") || lowerName.contains("computer")) return Icons.laptop;
    if (lowerName.contains("phone") || lowerName.contains("mobile")) return Icons.phone_iphone;
    if (lowerName.contains("cosmetic") || lowerName.contains("beauty")) return Icons.face_retouching_natural;
    if (lowerName.contains("food") || lowerName.contains("organic")) return Icons.restaurant;
    return Icons.category_rounded;
  }

  void _onCategoryTap(BuildContext context, String catId, String catName) async {
    try {
      EasyLoading.show(status: 'Loading sub-categories...');
      final subCategories = await CategoryApi.instance.fetchSubCategories(catId);
      EasyLoading.dismiss();
      _showSubCategoryDialog(context, catName, subCategories);
    } catch (e) {
      EasyLoading.dismiss();
      Get.snackbar(
        "Error",
        "Failed to load sub-categories: $e",
        colorText: Colors.white,
        backgroundColor: Colors.redAccent.withOpacity(0.8),
      );
    }
  }

  void _showSubCategoryDialog(BuildContext context, String categoryName, List<AllSubCategoryModel> subcategories) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().cardBackground : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text(
          "$categoryName Sub-categories",
          style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: 320.w,
          child: subcategories.isEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      "No sub-categories found.",
                      style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textSecondaryColor : Colors.black54),
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: subcategories.length,
                  itemBuilder: (context, index) {
                    final sub = subcategories[index];
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12.withOpacity(0.1)),
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.c053A4CA.withOpacity(0.15),
                          ),
                          child: Icon(Icons.tag, color: AppColors.c053A4CA),
                        ),
                        title: Text(
                          sub.tagname ?? "",
                          style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, fontWeight: FontWeight.bold),
                        ),
                        trailing: Icon(Icons.phone_in_talk, color: Colors.greenAccent),
                        onTap: () {
                          Get.back();
                          _handleSubCategoryClick(sub);
                        },
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Close", style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textSecondaryColor : Colors.black54)),
          ),
        ],
      ),
    );
  }

  void _handleSubCategoryClick(AllSubCategoryModel sub) {
    if (sub.id != null) {
      try {
        if (Get.isRegistered<CallController>()) {
          final callController = Get.find<CallController>();
          callController.startCall(sub.id!);
          Get.snackbar(
            "Calling",
            "Initiating call for sub-category: #${sub.tagname}",
            colorText: Colors.white,
            backgroundColor: Colors.green.withOpacity(0.8),
            duration: const Duration(seconds: 4),
          );
        } else {
          Get.snackbar(
            "Call Controller Error",
            "Call service is not active right now.",
            colorText: Colors.white,
            backgroundColor: Colors.redAccent.withOpacity(0.8),
          );
        }
      } catch (e) {
        Get.snackbar(
          "Error",
          "Could not start call: $e",
          colorText: Colors.white,
          backgroundColor: Colors.redAccent.withOpacity(0.8),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tc = Get.find<ThemeController>();
    return Obx(() {
      final categoriesList = getCategoryRx.valueStreamData.valueOrNull ?? [];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _isLoading 
                    ? _buildGlassStatCard(tc, title: "Total Sales", value: "...", change: "Loading", statusColor: Colors.greenAccent, icon: Icons.insights)
                    : _buildGlassStatCard(tc, title: "Total Sales", value: "৳ ${_paidBalance.toStringAsFixed(2)}", change: "Paid", statusColor: Colors.greenAccent, icon: Icons.insights),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _isLoading
                    ? _buildGlassStatCard(tc, title: "Pending Balance", value: "...", change: "Loading", statusColor: Colors.amberAccent, icon: Icons.receipt_long_rounded)
                    : _buildGlassStatCard(tc, title: "Pending Balance", value: "৳ ${_pendingBalance.toStringAsFixed(2)}", change: "Pending", statusColor: Colors.amberAccent, icon: Icons.receipt_long_rounded),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _isLoading
                    ? _buildGlassStatCard(tc, title: "Rejected Balance", value: "...", change: "Loading", statusColor: Colors.redAccent, icon: Icons.cancel_outlined)
                    : _buildGlassStatCard(tc, title: "Rejected Balance", value: "৳ ${_rejectedBalance.toStringAsFixed(2)}", change: "Rejected", statusColor: Colors.redAccent, icon: Icons.cancel_outlined),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          GlassCard(
            borderRadius: 20.r,
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Revenue Analytics", style: TextStyle(color: tc.textColor, fontSize: 15.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16.h),
                  SizedBox(
                    height: 160.h,
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: const [FlSpot(0, 2), FlSpot(1, 4), FlSpot(2, 3), FlSpot(3, 5), FlSpot(4, 4.5), FlSpot(5, 6)],
                            isCurved: true,
                            gradient: LinearGradient(colors: [AppColors.c053A4CA, AppColors.c7953CA]),
                            barWidth: 4,
                            belowBarData: BarAreaData(show: true, color: AppColors.c053A4CA.withOpacity(0.15)),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),
          buildSectionHeader("Quick Actions"),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionBtn(tc, "View Invoices", Icons.receipt_long_rounded, widget.onViewInvoices),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildQuickActionBtn(ThemeController tc, String title, IconData icon, VoidCallback onTap) {
    return GlassCard(
      borderRadius: 14.r,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
          child: Column(
            children: [
              Icon(icon, color: AppColors.c053A4CA, size: 24.sp),
              SizedBox(height: 6.h),
              Text(title, style: TextStyle(color: tc.textColor, fontSize: 10.sp, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassStatCard(
    ThemeController tc, {
    required String title,
    required String value,
    required String change,
    required Color statusColor,
    required IconData icon,
  }) {
    return GlassCard(
      borderRadius: 16.r,
      child: Padding(
        padding: EdgeInsets.all(10.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: AppColors.c053A4CA, size: 18.sp),
                Flexible(
                  child: Text(
                    change,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Text(
              value,
              style: TextStyle(
                color: tc.textColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4.h),
            Text(
              title,
              style: TextStyle(
                color: tc.textSecondaryColor,
                fontSize: 10.sp,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
