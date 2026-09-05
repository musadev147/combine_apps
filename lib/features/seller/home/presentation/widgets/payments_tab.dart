import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:bd_shope_combined/constants/app_colors.dart';
import 'package:bd_shope_combined/common_widgets/glass_card.dart';
import 'common_components.dart';
import 'package:bd_shope_combined/controllers/theme_controller.dart';
import 'package:bd_shope_combined/networks/dio/dio.dart';
import 'package:bd_shope_combined/networks/endpoints.dart';
import 'package:bd_shope_combined/features/seller/home/presentation/model/payment_balace_show_model.dart';
import 'package:bd_shope_combined/helpers/di.dart';
import 'package:bd_shope_combined/constants/app_constants.dart';

class PaymentsTab extends StatefulWidget {
  final VoidCallback onPayoutRequested;
  final int? refreshTrigger;

  const PaymentsTab({
    super.key,
    required this.onPayoutRequested,
    this.refreshTrigger = 0,
  });

  @override
  State<PaymentsTab> createState() => _PaymentsTabState();
}

class _PaymentsTabState extends State<PaymentsTab> {
  GetMybleanceModel? _balanceModel;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchBalanceDetails();
  }

  @override
  void didUpdateWidget(covariant PaymentsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.refreshTrigger != oldWidget.refreshTrigger) {
      _fetchBalanceDetails();
    }
  }

  Future<void> _fetchBalanceDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final vendorId = appData.read(kKeyUserID)?.toString() ?? '';
      if (vendorId.isEmpty) {
        setState(() {
          _errorMessage = "Vendor ID not found. Please log in again.";
        });
        return;
      }

      final response = await getHttp(Endpoints.vendorDetails(id: vendorId));
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data != null) {
          setState(() {
            _balanceModel = GetMybleanceModel.fromJson(response.data);
          });
        }
      } else {
        setState(() {
          _errorMessage = "Failed to load balance details.";
        });
      }
    } catch (e) {
      debugPrint("Fetch vendor balance details error: $e");
      setState(() {
        if (e.toString().contains('404')) {
          // If the backend returns 404, it means the vendor profile has no balance record yet.
          // We show a 0 balance instead of an error.
          _errorMessage = null;
        } else {
          _errorMessage = "An error occurred while fetching balance.";
        }
      });
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
    return Obx(() {
      final isDark = tc.isDarkMode.value;
      return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader("Wallet Overview"),
        SizedBox(height: 12.h),
        if (_isLoading)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_errorMessage != null)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Column(
                children: [
                  Text(_errorMessage!, style: TextStyle(color: Colors.redAccent, fontSize: 13.sp)),
                  SizedBox(height: 10.h),
                  IconButton(
                    icon: Icon(Icons.refresh, color: tc.textColor),
                    onPressed: _fetchBalanceDetails,
                  )
                ],
              ),
            ),
          )
        else
          Column(
            children: [
              // Premium Glass Wallet Card
              GlassCard(
                borderRadius: 24.r,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24.r),
                    gradient: LinearGradient(
                      colors: tc.isDarkMode.value
                          ? [
                              const Color(0xFF1E1B4B).withOpacity(0.4),
                              const Color(0xFF311042).withOpacity(0.4),
                            ]
                          : [
                              Colors.white.withOpacity(0.7),
                              Colors.blue.withOpacity(0.1),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "AVAILABLE BALANCE",
                              style: TextStyle(
                                color: tc.textSecondaryColor,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            Icon(
                              Icons.account_balance_wallet_rounded,
                              color: AppColors.c053A4CA,
                              size: 24.sp,
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          "৳ ${(_balanceModel?.currentWalletBalance ?? 0).toStringAsFixed(2)}",
                          style: TextStyle(
                            color: tc.textColor,
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Divider(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12),
                        SizedBox(height: 10.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildSubBalanceItem(
                              tc,
                              "Total Earnings",
                              "৳ ${(_balanceModel?.totalWalletBalance ?? 0).toStringAsFixed(2)}",
                            ),
                            _buildSubBalanceItem(
                              tc,
                              "Paid Out",

                              "৳ ${(_balanceModel?.paidWalletBalance ?? 0).toStringAsFixed(2)}",
                            ),
                            _buildSubBalanceItem(
                              tc,
                              "Call Minutes",
                              "${_balanceModel?.totalMinutes ?? 0} Min",
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
    });
  }

  Widget _buildSubBalanceItem(ThemeController tc, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: tc.textSecondaryColor,
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            color: tc.textColor,
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
