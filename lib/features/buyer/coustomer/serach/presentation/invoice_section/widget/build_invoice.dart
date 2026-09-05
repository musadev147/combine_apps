import 'package:bd_shope_combined/controllers/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:bd_shope_combined/common_widgets/glass_card.dart';
import 'package:bd_shope_combined/route/app_pages.dart';
import 'package:bd_shope_combined/networks/dio/dio.dart';
import 'package:bd_shope_combined/features/buyer/coustomer/serach/presentation/invoice_section/data/invoice_api.dart';
import 'get_owner_model.dart';
import 'model/build_invoice_model.dart';

class BuildInvoicesList extends StatelessWidget {
  final List<GetNotifiInvoiceModel> invoices;
  final VoidCallback? onRefresh;

  // Local state to track which invoices were confirmed in this session
  static final Set<String> locallyConfirmedIds = {};

  const BuildInvoicesList({
    Key? key,
    required this.invoices,
    this.onRefresh,
  }) : super(key: key);

  void _payInvoice(BuildContext context, GetNotifiInvoiceModel invoice) {
    _showOwnerPayoutMethodsBottomSheet(context, invoice.id?.toString() ?? '', invoice);
  }

  void _showConfirmDeliveryDialog(BuildContext context, GetNotifiInvoiceModel inv) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().cardBackground : const Color(0xFF1E1E38),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
          side: BorderSide(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12.withOpacity(0.1), width: 1.5),
        ),
        title: Text(
          "Confirm Delivery",
          style: GoogleFonts.outfit(
            color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
        content: Text(
          "Delivery paise ki na? (Has the buyer received the delivery?)",
          style: GoogleFonts.poppins(
            color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textSecondaryColor : Colors.black54,
            fontSize: 13.sp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              "No",
              style: GoogleFonts.poppins(
                color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textSecondaryColor : Colors.black54,
                fontSize: 12.sp,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            ),
            onPressed: () async {
              Get.back();
              if (inv.id != null) {
                await _confirmDelivery(inv.id!);
              } else {
                Get.snackbar(
                  "Success",
                  "Delivery status updated (Mock)",
                  colorText: Colors.white,
                  backgroundColor: const Color(0xFF10B981),
                );
              }
            },
            child: Text(
              "Yes, Received",
              style: GoogleFonts.poppins(
                color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelivery(String id) async {
    EasyLoading.show(status: 'Updating delivery status...');
    try {
      final success = await InvoiceApi.instance.updateDeliveryStatus(id, true);
      EasyLoading.dismiss();
      if (success) {
        BuildInvoicesList.locallyConfirmedIds.add(id);
        Get.snackbar(
          "Success",
          "Delivery confirmed successfully!",
          colorText: Colors.white,
          backgroundColor: const Color(0xFF10B981),
        );
        onRefresh?.call();
      } else {
        Get.snackbar(
          "Error",
          "Failed to update delivery status.",
          colorText: Colors.white,
          backgroundColor: Colors.redAccent,
        );
      }
    } catch (e) {
      EasyLoading.dismiss();
      Get.snackbar(
        "Error",
        "An error occurred: $e",
        colorText: Colors.white,
        backgroundColor: Colors.redAccent,
      );
    }
  }

  void _showOwnerPayoutMethodsBottomSheet(BuildContext context, String invoiceId, GetNotifiInvoiceModel invoice) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(
          top: 20.h,
          left: 20.w,
          right: 20.w,
          bottom: 24.h,
        ),
        decoration: BoxDecoration(
          color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().cardBackground : const Color(0xFF1E1E38),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
          border: Border.all(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().cardBackground : Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Owner Payout Methods',
              style: GoogleFonts.outfit(
                color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Please send the payment to one of the accounts below, then proceed to submit your payment details.',
              style: GoogleFonts.poppins(
                color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textSecondaryColor : Colors.black54,
                fontSize: 12.sp,
              ),
            ),
            SizedBox(height: 16.h),
            Flexible(
              child: FutureBuilder<List<GetOwnerAccountModel>>(
                future: InvoiceApi.instance.fetchOwnerPayoutMethods(invoice.vendor ?? ''),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        child: CircularProgressIndicator(color: Color(0xFF53A4CA)),
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Failed to load payout methods',
                        style: GoogleFonts.poppins(color: Colors.redAccent, fontSize: 13.sp),
                      ),
                    );
                  }
                  final list = snapshot.data;
                  if (list == null || list.isEmpty) {
                    return Center(
                      child: Text(
                        'No payout methods found for this owner.',
                        style: GoogleFonts.poppins(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textSecondaryColor : Colors.black54, fontSize: 13.sp),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: list.length,
                    itemBuilder: (context, idx) {
                      final method = list[idx];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (method.bkashNumber != null && method.bkashNumber!.isNotEmpty)
                            _buildPayoutMethodCard(
                              title: 'bKash Personal',
                              value: method.bkashNumber!,
                              icon: Icons.phone_android,
                              color: const Color(0xFFE2125B),
                            ),
                          if (method.nagadNumber != null && method.nagadNumber!.isNotEmpty)
                            _buildPayoutMethodCard(
                              title: 'Nagad Personal',
                              value: method.nagadNumber!,
                              icon: Icons.phone_android,
                              color: const Color(0xFFF15A22),
                            ),
                          if (method.bankName != null && method.bankName!.isNotEmpty)
                            Container(
                              margin: EdgeInsets.only(bottom: 12.h),
                              padding: EdgeInsets.all(14.r),
                              decoration: BoxDecoration(
                                color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().cardBackground : Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12.withOpacity(0.1)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.account_balance, color: const Color(0xFF53A4CA), size: 20.r),
                                      SizedBox(width: 8.w),
                                      Text(
                                        'Bank Account Details',
                                        style: GoogleFonts.outfit(
                                          color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10.h),
                                  _buildBankDetailRow('Bank Name', method.bankName ?? ''),
                                  _buildBankDetailRow('Account Name', method.accountName ?? ''),
                                  _buildBankDetailRow(
                                    'Account Number',
                                    method.accountNumber ?? '',
                                    canCopy: true,
                                  ),
                                  if (method.branchName != null && method.branchName!.isNotEmpty)
                                    _buildBankDetailRow('Branch Name', method.branchName ?? ''),
                                ],
                              ),
                            ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7953CA),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                onPressed: () {
                  Get.back();
                  _showPaymentFormBottomSheet(context, invoiceId, invoice);
                },
                child: Text(
                  'Proceed to Payment',
                  style: GoogleFonts.outfit(
                    color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildPayoutMethodCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().cardBackground : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20.r),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textSecondaryColor : Colors.black54, fontSize: 11.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: GoogleFonts.outfit(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, fontSize: 15.sp, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.copy, color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textSecondaryColor : Colors.black54, size: 18.r),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              Get.snackbar(
                'Copied',
                '$title number copied to clipboard',
                backgroundColor: const Color(0xFF7953CA).withOpacity(0.9),
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
                margin: EdgeInsets.all(16.r),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBankDetailRow(String label, String val, {bool canCopy = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              label,
              style: GoogleFonts.poppins(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.5), fontSize: 11.sp),
            ),
          ),
          Expanded(
            child: Text(
              val,
              style: GoogleFonts.poppins(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.8), fontSize: 12.sp, fontWeight: FontWeight.w500),
            ),
          ),
          if (canCopy)
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: val));
                Get.snackbar(
                  'Copied',
                  '$label copied to clipboard',
                  backgroundColor: const Color(0xFF7953CA).withOpacity(0.9),
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                  margin: EdgeInsets.all(16.r),
                );
              },
              child: Padding(
                padding: EdgeInsets.only(left: 8.w),
                child: Icon(Icons.copy, color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textSecondaryColor : Colors.black54, size: 14.r),
              ),
            ),
        ],
      ),
    );
  }

  void _showPaymentFormBottomSheet(BuildContext context, String invoiceId, GetNotifiInvoiceModel invoice) {
    final senderAccountController = TextEditingController();
    final tranIdController = TextEditingController();
    final phoneController = TextEditingController(text: invoice.phoneNumber ?? '');
    final addressController = TextEditingController(text: invoice.address ?? '');
    String selectedMethod = 'bkash';
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              padding: EdgeInsets.only(
                top: 20.h,
                left: 20.w,
                right: 20.w,
                bottom: 24.h + MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().cardBackground : const Color(0xFF1E1E38),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
                border: Border.all(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12.withOpacity(0.1)),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Center(
                    child: Container(
                      width: 50.w,
                      height: 5.h,
                      decoration: BoxDecoration(
                        color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().cardBackground : Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'Complete Payment',
                    style: GoogleFonts.outfit(
                      color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Method Selection
                  Text(
                    'Payment Method',
                    style: GoogleFonts.poppins(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textSecondaryColor : Colors.black54, fontSize: 12.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: ['bkash', 'nagad', 'rocket', 'card'].map((method) {
                      final isSelected = selectedMethod == method;
                      return GestureDetector(
                        onTap: () {
                          setModalState(() {
                            selectedMethod = method;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF7953CA) : Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF7953CA) : Colors.white.withOpacity(0.1),
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Text(
                            method.toUpperCase(),
                            style: GoogleFonts.poppins(
                              color: isSelected ? Colors.white : Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textSecondaryColor : Colors.black54,
                              fontSize: 11.sp,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 16.h),

                  // Amount (Read-only)
                  _buildFormInputField(
                    label: 'Amount (BDT)',
                    controller: TextEditingController(text: invoice.totalPrice?.toString() ?? '0'),
                    hint: '',
                    readOnly: true,
                    icon: Icons.payments_outlined,
                  ),
                  SizedBox(height: 12.h),

                  // Sender Account
                  _buildFormInputField(
                    label: 'Sender Account / Number',
                    controller: senderAccountController,
                    hint: 'e.g. 01700000000',
                    icon: Icons.account_box_outlined,
                  ),
                  SizedBox(height: 12.h),

                  // Transaction ID
                  _buildFormInputField(
                    label: 'Transaction ID',
                    controller: tranIdController,
                    hint: 'Enter Transaction ID',
                    icon: Icons.receipt_outlined,
                  ),
                  SizedBox(height: 12.h),

                  // Contact Phone
                  _buildFormInputField(
                    label: 'Contact Phone',
                    controller: phoneController,
                    hint: 'Enter Phone Number',
                    icon: Icons.phone_outlined,
                  ),
                  SizedBox(height: 12.h),

                  // Shipping/Billing Address
                  _buildFormInputField(
                    label: 'Address',
                    controller: addressController,
                    hint: 'Enter Delivery Address',
                    icon: Icons.location_on_outlined,
                  ),
                  SizedBox(height: 24.h),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7953CA),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              final sender = senderAccountController.text.trim();
                              final tranId = tranIdController.text.trim();
                              final phone = phoneController.text.trim();
                              final addr = addressController.text.trim();

                              if (sender.isEmpty || tranId.isEmpty || phone.isEmpty || addr.isEmpty) {
                                Get.snackbar(
                                  'Error',
                                  'All fields are required.',
                                  backgroundColor: Colors.redAccent.withOpacity(0.9),
                                  colorText: Colors.white,
                                );
                                return;
                              }

                              setModalState(() {
                                isSubmitting = true;
                              });

                              try {
                                final response = await postHttp('/payment/initiate/', {
                                  'invoice_id': invoiceId,
                                  'payment_method': selectedMethod,
                                  'sender_account': sender,
                                  'tran_id': tranId,
                                  'amount': invoice.totalPrice?.toString() ?? '0',
                                  'phone_number': phone,
                                  'address': addr,
                                });

                                if (response.statusCode == 200 || response.statusCode == 201) {
                                  Get.back(); // Close bottom sheet
                                  onRefresh?.call(); // Refresh invoices list
                                  Get.snackbar(
                                    'Success',
                                    'Payment submitted successfully!',
                                    backgroundColor: Colors.greenAccent.withOpacity(0.9),
                                    colorText: Colors.white,
                                  );
                                } else {
                                  Get.snackbar(
                                    'Error',
                                    'Failed to initiate payment. Status: ${response.statusCode}',
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
                                setModalState(() {
                                  isSubmitting = false;
                                });
                              }
                            },
                      child: isSubmitting
                          ? SizedBox(
                              width: 20.r,
                              height: 20.r,
                              child: CircularProgressIndicator(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().cardBackground : Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              'Confirm Payment',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

  Widget _buildFormInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textSecondaryColor : Colors.black54,
            fontSize: 11.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4.h),
        Container(
          decoration: BoxDecoration(
            color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().cardBackground : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12.withOpacity(0.1)),
          ),
          child: TextFormField(
            controller: controller,
            readOnly: readOnly,
            style: GoogleFonts.poppins(
              color: readOnly ? Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textSecondaryColor : Colors.black54 : Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
              fontSize: 13.sp,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textSecondaryColor : Colors.black54, size: 18.sp),
              hintText: hint,
              hintStyle: GoogleFonts.poppins(
                color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.3),
                fontSize: 13.sp,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 10.h),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (invoices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().iconColor : Colors.black45, size: 64.r),
            SizedBox(height: 16.h),
            Text(
              'No invoices found',
              style: GoogleFonts.outfit(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.r),
      itemCount: invoices.length,
      itemBuilder: (context, index) {
        final invoice = invoices[index];
        final statusLower = invoice.status?.toLowerCase() ?? '';
        final isPending = statusLower == 'pending';
        final isPaid = statusLower == 'paid' || statusLower == 'completed' || statusLower == 'success' || statusLower == 'received';
        
        print("INVOICE ${invoice.id} -> buyerConfirmedDelivery: ${invoice.buyerConfirmedDelivery}");

        return GestureDetector(
          onTap: () async {
            final result = await Get.toNamed(
              Routes.INVOICE_DETAILS,
              arguments: invoice.id?.toString() ?? '',
            );
            if (result == true) {
              onRefresh?.call();
            }
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 12.h),
            child: GlassCard(
              borderRadius: 20.r,
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (isPending ? Colors.amber : (isPaid ? Colors.green : Colors.red)).withOpacity(0.15),
                        border: Border.all(color: (isPending ? Colors.amber : (isPaid ? Colors.green : Colors.red)).withOpacity(0.3)),
                      ),
                      child: Icon(
                        Icons.receipt_long,
                        color: isPending ? Colors.amber : (isPaid ? Colors.green : Colors.red),
                        size: 24.r,
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Invoice #${invoice.id ?? ""}',
                            style: GoogleFonts.outfit(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, fontSize: 14.sp, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            invoice.productName ?? "",
                            style: GoogleFonts.poppins(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textSecondaryColor : Colors.black54, fontSize: 12.sp),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '৳${invoice.totalPrice ?? "0"}',
                            style: GoogleFonts.outfit(color: const Color(0xFF53A4CA), fontSize: 14.sp, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    if (isPending)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7953CA),
                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                        onPressed: () => _payInvoice(context, invoice),
                        child: Text(
                          'Pay Now',
                          style: GoogleFonts.outfit(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, fontSize: 12.sp, fontWeight: FontWeight.bold),
                        ),
                      )
                    else if (isPaid)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: Colors.green.withOpacity(0.3)),
                            ),
                            child: Text(
                              invoice.status ?? 'Paid',
                              style: GoogleFonts.poppins(color: Colors.green, fontSize: 11.sp, fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(height: 6.h),
                          if (statusLower == 'received' || BuildInvoicesList.locallyConfirmedIds.contains(invoice.id))
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle_outline, size: 12.sp, color: const Color(0xFF10B981)),
                                  SizedBox(width: 4.w),
                                  Text(
                                    "Received",
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF10B981),
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                _showConfirmDeliveryDialog(context, invoice);
                              },
                              child: AbsorbPointer(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF53A4CA),
                                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: () {},
                                  child: Text(
                                    "Confirm",
                                    style: GoogleFonts.poppins(
                                      color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      )
                    else
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: Text(
                          invoice.status ?? 'Cancelled',
                          style: GoogleFonts.poppins(color: Colors.red, fontSize: 11.sp, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
