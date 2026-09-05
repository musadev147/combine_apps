import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

import 'package:bd_shope_combined/common_widgets/glass_background_scaffold.dart';
import 'package:bd_shope_combined/common_widgets/glass_card.dart';
import 'package:bd_shope_combined/networks/dio/dio.dart';
import 'package:bd_shope_combined/networks/endpoints.dart';
import 'widgets/common_components.dart';
import 'package:bd_shope_combined/controllers/theme_controller.dart';
import 'package:bd_shope_combined/constants/app_colors.dart';
import 'model/added_my_account_model.dart';
import 'package:bd_shope_combined/helpers/di.dart';
import 'package:bd_shope_combined/constants/app_constants.dart';

class PayoutMethodsScreen extends StatefulWidget {
  const PayoutMethodsScreen({Key? key}) : super(key: key);

  @override
  State<PayoutMethodsScreen> createState() => _PayoutMethodsScreenState();
}

class _PayoutMethodsScreenState extends State<PayoutMethodsScreen> {
  List<AddedMyAccountModel> _accountsList = [];
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchPayoutDetails();
  }

  Future<void> _fetchPayoutDetails() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final response = await getHttp(Endpoints.payoutMethods());
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        List<AddedMyAccountModel> temp = [];
        if (data is List) {
          temp = data.map((json) => AddedMyAccountModel.fromJson(json as Map<String, dynamic>)).toList();
        } else if (data is Map<String, dynamic> && data['results'] is List) {
          temp = (data['results'] as List).map((json) => AddedMyAccountModel.fromJson(json as Map<String, dynamic>)).toList();
        } else if (data is Map<String, dynamic> && data['data'] is List) {
          temp = (data['data'] as List).map((json) => AddedMyAccountModel.fromJson(json as Map<String, dynamic>)).toList();
        } else if (data is Map<String, dynamic>) {
          temp = [AddedMyAccountModel.fromJson(data)];
        }

        setState(() {
          _accountsList = temp;
        });
      }
    } catch (e) {
      debugPrint("Fetch payout list error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _addAccount(Map<String, dynamic> payload) async {
    try {
      setState(() {
        _isSaving = true;
      });
      final response = await postHttp(Endpoints.payoutMethods(), payload);
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          'Success',
          'Account added successfully.',
          backgroundColor: Colors.greenAccent.withOpacity(0.9),
          colorText: Colors.white,
        );
        _fetchPayoutDetails();
      } else {
        Get.snackbar(
          'Error',
          'Failed to add account.',
          backgroundColor: Colors.redAccent.withOpacity(0.9),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        backgroundColor: Colors.redAccent.withOpacity(0.9),
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _deleteAccount(String id) async {
    try {
      setState(() {
        _isSaving = true;
      });
      final response = await deleteHttp(Endpoints.deletePayoutMethod(id: id));
      if (response.statusCode == 200 || response.statusCode == 204) {
        Get.snackbar(
          'Success',
          'Account deleted successfully.',
          backgroundColor: Colors.greenAccent.withOpacity(0.9),
          colorText: Colors.white,
        );
        _fetchPayoutDetails();
      } else {
        Get.snackbar(
          'Error',
          'Failed to delete account.',
          backgroundColor: Colors.redAccent.withOpacity(0.9),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        backgroundColor: Colors.redAccent.withOpacity(0.9),
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showAddAccountDialog() {
    if (_accountsList.isNotEmpty) {
      Get.snackbar(
        "Already Exists",
        "You have already added a payout account.",
        backgroundColor: Colors.orangeAccent.withOpacity(0.9),
        colorText: Colors.white,
      );
      return;
    }
    final bankNameController = TextEditingController();
    final accountNameController = TextEditingController();
    final accountNumberController = TextEditingController();
    final branchNameController = TextEditingController();
    final bkashController = TextEditingController();
    final nagadController = TextEditingController();

    Get.dialog(
      AlertDialog(
        backgroundColor: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().cardBackground : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text(
          "Add Payout Method",
          style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: 320.w,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildGlassInputField(
                  controller: accountNameController,
                  label: "Account Name",
                  icon: Icons.person_outline,
                  hint: "Account holder name",
                ),
                SizedBox(height: 10.h),
                buildGlassInputField(
                  controller: bankNameController,
                  label: "Bank Name",
                  icon: Icons.account_balance_outlined,
                  hint: " Dutch-Bangla Bank, etc.",
                ),
                SizedBox(height: 10.h),
                buildGlassInputField(
                  controller: accountNumberController,
                  label: "Account Number",
                  icon: Icons.numbers_outlined,
                  hint: "Bank account number",
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10.h),
                buildGlassInputField(
                  controller: branchNameController,
                  label: "Branch Name",
                  icon: Icons.location_city_outlined,
                  hint: "Branch name",
                ),
                SizedBox(height: 10.h),
                buildGlassInputField(
                  controller: bkashController,
                  label: "bKash Personal",
                  icon: Icons.phone_android_outlined,
                  hint: "017xxxxxxxx",
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 10.h),
                buildGlassInputField(
                  controller: nagadController,
                  label: "Nagad Personal",
                  icon: Icons.phone_android_outlined,
                  hint: "017xxxxxxxx",
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Cancel", style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textSecondaryColor : Colors.black54)),
          ),
          ElevatedButton(
            onPressed: () {
              final payload = {
                'bank_name': bankNameController.text.trim(),
                'account_name': accountNameController.text.trim(),
                'account_number': accountNumberController.text.trim(),
                'branch_name': branchNameController.text.trim(),
                'bkash_number': bkashController.text.trim(),
                'nagad_number': nagadController.text.trim(),
              };
              Get.back();
              _addAccount(payload);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.c053A4CA,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
            child: Text("Add Account", style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tc = Get.find<ThemeController>();
    return Obx(() => GlassBackgroundScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios, color: tc.textColor),
        ),
        title: Text(
          'Payout Methods',
          style: GoogleFonts.outfit(
            color: tc.textColor,
            fontWeight: FontWeight.w700,
            fontSize: 20.sp,
          ),
        ),
        actions: _accountsList.isEmpty
            ? [
                IconButton(
                  onPressed: _showAddAccountDialog,
                  icon: Icon(Icons.add_card_rounded, color: AppColors.c053A4CA, size: 24.sp),
                  tooltip: "Add Payout Method",
                ),
              ]
            : [],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchPayoutDetails,
              color: AppColors.c053A4CA,
              child: _accountsList.isEmpty
                  ? ListView(
                      children: [
                        SizedBox(height: 150.h),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.account_balance_wallet_outlined, color: tc.textColor.withOpacity(0.3), size: 64.sp),
                              SizedBox(height: 16.h),
                              Text(
                                "No payout methods added yet.",
                                style: TextStyle(color: tc.textColor.withOpacity(0.5), fontSize: 14.sp),
                              ),
                              SizedBox(height: 20.h),
                              ElevatedButton.icon(
                                onPressed: _showAddAccountDialog,
                                icon: Icon(Icons.add, color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black),
                                label: Text("Add Account Now", style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.c053A4CA,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.all(16.r),
                      itemCount: _accountsList.length,
                      itemBuilder: (context, index) {
                        final account = _accountsList[index];
                        final hasBank = account.bankName != null && account.bankName!.isNotEmpty;
                        final hasBkash = account.bkashNumber != null && account.bkashNumber!.isNotEmpty;
                        final hasNagad = account.nagadNumber != null && account.nagadNumber!.isNotEmpty;

                        return Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: GlassCard(
                            borderRadius: 16.r,
                            child: Padding(
                              padding: EdgeInsets.all(16.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        hasBank ? account.bankName! : "Mobile Wallet",
                                        style: TextStyle(color: tc.textColor, fontSize: 15.sp, fontWeight: FontWeight.bold),
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            hasBank ? Icons.account_balance_rounded : Icons.phone_android_rounded,
                                            color: AppColors.c053A4CA,
                                            size: 20.sp,
                                          ),
                                          SizedBox(width: 8.w),
                                          PopupMenuButton<String>(
                                            icon: Icon(Icons.more_vert, color: tc.textColor, size: 20.sp),
                                            padding: EdgeInsets.zero,
                                            onSelected: (value) {
                                              if (value == 'delete') {
                                                _deleteAccount(account.id!);
                                              }
                                            },
                                            itemBuilder: (BuildContext context) => [
                                              const PopupMenuItem<String>(
                                                value: 'delete',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.delete, size: 18, color: Colors.redAccent),
                                                    SizedBox(width: 8),
                                                    Text('Delete', style: TextStyle(color: Colors.redAccent)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Divider(color: tc.dividerColor, height: 20),
                                  if (hasBank) ...[
                                    _buildDetailRow("Account Name", account.accountName ?? ""),
                                    _buildDetailRow("Account Number", account.accountNumber ?? ""),
                                    if (account.branchName != null && account.branchName!.isNotEmpty)
                                      _buildDetailRow("Branch Name", account.branchName!),
                                  ],
                                  if (hasBkash)
                                    _buildDetailRow("bKash Number", account.bkashNumber!),
                                  if (hasNagad)
                                    _buildDetailRow("Nagad Number", account.nagadNumber!),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    ));
  }

  Widget _buildDetailRow(String label, String value) {
    final tc = Get.find<ThemeController>();
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: tc.textSecondaryColor, fontSize: 12.sp)),
          Text(value, style: TextStyle(color: tc.textColor, fontSize: 12.sp, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
