import 'package:bd_shope_combined/controllers/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:bd_shope_combined/common_wigdets/glass_background.dart';
import 'package:bd_shope_combined/common_wigdets/glass_card.dart';
import 'payment_controller.dart';

class PaymentInvoiceScreen extends StatefulWidget {
  const PaymentInvoiceScreen({Key? key}) : super(key: key);

  @override
  State<PaymentInvoiceScreen> createState() => _PaymentInvoiceScreenState();
}

class _PaymentInvoiceScreenState extends State<PaymentInvoiceScreen> {
  final PaymentController controller = Get.put(PaymentController());
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.h),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF7953CA).withOpacity(0.25),
                  const Color(0xFF5369CA).withOpacity(0.15),
                  const Color(0xFF53A4CA).withOpacity(0.05),
                ],
              ),
              border: Border(
                bottom: BorderSide(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12.withOpacity(0.1), width: 1.5),
              ),
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                onPressed: () => Get.back(),
                icon: Icon(Icons.arrow_back_ios, color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black),
              ),
              title: Text(
                'Invoice & Payment',
                style: GoogleFonts.outfit(
                  color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 20.sp,
                ),
              ),
            ),
          ),
        ),
        body: Obx(() {
          if (controller.paymentStatus.value == 'Completed' || controller.paymentStatus.value == 'Refunded') {
            return _buildSuccessOrRefundView();
          }
          return _buildPaymentView();
        }),
      ),
    );
  }

  Widget _buildPaymentView() {
    return SafeArea(
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInvoiceDetails(),
                SizedBox(height: 24.h),
                _buildNoteInputField(),
                SizedBox(height: 24.h),
                _buildGatewaySelection(),
                SizedBox(height: 24.h),
                _buildEscrowToggle(),
                SizedBox(height: 100.h), // Padding for bottom button
              ],
            ),
          ),
          
          // Bottom CTA
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E38),
                border: Border(top: BorderSide(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12.withOpacity(0.1))),
              ),
              child: Obx(() => ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7953CA),
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                ),
                onPressed: controller.isProcessing.value
                    ? null
                    : () async {
                        controller.note.value = _noteController.text.trim();
                        controller.initiatePayment();
                        _showOtpDialog();
                      },
                child: controller.isProcessing.value
                    ? SizedBox(height: 20.r, width: 20.r, child: CircularProgressIndicator(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().cardBackground : Colors.white, strokeWidth: 2))
                    : Text(
                        'Pay ৳${controller.totalAmount.toStringAsFixed(2)}',
                        style: GoogleFonts.outfit(fontSize: 16.sp, fontWeight: FontWeight.bold),
                      ),
              )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceDetails() {
    return GlassCard(
      padding: EdgeInsets.all(20.r),
      borderRadius: 20.r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Invoice #INV-98234',
                style: GoogleFonts.outfit(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'Pending',
                  style: GoogleFonts.poppins(color: Colors.amber, fontSize: 12.sp, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildReceiptRow('Apple MacBook Pro M3', '৳${controller.subtotal.toStringAsFixed(2)}'),
          SizedBox(height: 8.h),
          _buildReceiptRow('Delivery Fee', '৳${controller.deliveryFee.toStringAsFixed(2)}'),
          SizedBox(height: 8.h),
          _buildReceiptRow('Platform Fee', '৳${controller.platformFee.toStringAsFixed(2)}'),
          SizedBox(height: 16.h),
          Divider(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12.withOpacity(0.2)),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: GoogleFonts.outfit(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              Text(
                '৳${controller.totalAmount.toStringAsFixed(2)}',
                style: GoogleFonts.outfit(color: const Color(0xFF53A4CA), fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoteInputField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Short Note / Instruction',
          style: GoogleFonts.outfit(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12.h),
        GlassCard(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          borderRadius: 16.r,
          child: TextField(
            controller: _noteController,
            style: GoogleFonts.poppins(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, fontSize: 14.sp),
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'e.g., Gift wrapping needed please.',
              hintStyle: GoogleFonts.poppins(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.35), fontSize: 13.sp),
              border: InputBorder.none,
              icon: Icon(Icons.note_alt_outlined, color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textSecondaryColor : Colors.black54, size: 24.r),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptRow(String title, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: GoogleFonts.poppins(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.7), fontSize: 14.sp)),
        Text(amount, style: GoogleFonts.poppins(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, fontSize: 14.sp, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildGatewaySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Gateway',
          style: GoogleFonts.outfit(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12.h),
        _buildGatewayOption('SSL Commerz', Icons.credit_card),
        SizedBox(height: 12.h),
        _buildGatewayOption('EPS (Electronic Payment System)', Icons.account_balance),
      ],
    );
  }

  Widget _buildGatewayOption(String name, IconData icon) {
    return Obx(() {
      final isSelected = controller.selectedGateway.value == name;
      return GestureDetector(
        onTap: () => controller.selectGateway(name),
        child: GlassCard(
          padding: EdgeInsets.all(16.r),
          borderRadius: 16.r,
          color: isSelected ? const Color(0xFF7953CA).withOpacity(0.2) : Colors.white.withOpacity(0.05),
          border: Border.all(
            color: isSelected ? const Color(0xFF7953CA) : Colors.white.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
          child: Row(
            children: [
              Icon(icon, color: isSelected ? const Color(0xFF53A4CA) : Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textSecondaryColor : Colors.black54, size: 28.r),
              SizedBox(width: 16.w),
              Expanded(
                child: Text(
                  name,
                  style: GoogleFonts.poppins(
                    color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                    fontSize: 15.sp,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: Color(0xFF53A4CA)),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildEscrowToggle() {
    return GlassCard(
      padding: EdgeInsets.all(16.r),
      borderRadius: 16.r,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: Colors.greenAccent.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.security, color: Colors.greenAccent),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Secure via Escrow',
                  style: GoogleFonts.outfit(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Funds will be held until you confirm receipt of the product.',
                  style: GoogleFonts.poppins(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.6), fontSize: 11.sp),
                ),
              ],
            ),
          ),
          Obx(() => Switch(
            value: controller.isEscrowEnabled.value,
            onChanged: (val) => controller.toggleEscrow(val),
            activeColor: Colors.greenAccent,
            activeTrackColor: Colors.greenAccent.withOpacity(0.4),
          )),
        ],
      ),
    );
  }

  void _showOtpDialog() {
    _otpController.clear();
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E38),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
          border: Border.all(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().cardBackground : Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            SizedBox(height: 24.h),
            Icon(Icons.lock_outline, color: const Color(0xFF53A4CA), size: 48.r),
            SizedBox(height: 16.h),
            Text(
              'OTP Verification',
              style: GoogleFonts.outfit(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, fontSize: 22.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(
              'Enter the OTP sent to your phone to confirm the payment.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.7), fontSize: 13.sp),
            ),
            SizedBox(height: 24.h),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, fontSize: 24.sp, letterSpacing: 8),
              decoration: InputDecoration(
                hintText: '----',
                hintStyle: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.2)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12.withOpacity(0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12.withOpacity(0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: const BorderSide(color: Color(0xFF7953CA)),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Text('Hint: Use "1234" for success mockup', style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().iconColor : Colors.black45, fontSize: 11.sp)),
            SizedBox(height: 24.h),
            Obx(() => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7953CA),
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                ),
                onPressed: controller.isProcessing.value
                    ? null
                    : () async {
                        final success = await controller.submitOtp(_otpController.text);
                        if (success) {
                          Get.back(); // close bottom sheet
                        } else {
                          Get.snackbar(
                            'Verification Failed',
                            'Invalid OTP. Please try again.',
                            backgroundColor: Colors.redAccent.withOpacity(0.9),
                            colorText: Colors.white,
                          );
                        }
                      },
                child: controller.isProcessing.value
                    ? SizedBox(height: 20.r, width: 20.r, child: CircularProgressIndicator(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().cardBackground : Colors.white, strokeWidth: 2))
                    : Text(
                        'Verify & Pay',
                        style: GoogleFonts.outfit(fontSize: 16.sp, fontWeight: FontWeight.bold),
                      ),
              ),
            )),
            SizedBox(height: 16.h),
          ],
        ),
      ),
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
    );
  }

  Widget _buildSuccessOrRefundView() {
    final isRefunded = controller.paymentStatus.value == 'Refunded';
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(
                color: isRefunded ? Colors.amber.withOpacity(0.1) : Colors.greenAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isRefunded ? Icons.assignment_return : Icons.check_circle,
                color: isRefunded ? Colors.amber : Colors.greenAccent,
                size: 80.r,
              ),
            ),
            SizedBox(height: 32.h),
            Text(
              isRefunded ? 'Refund Processed' : 'Payment Successful!',
              style: GoogleFonts.outfit(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, fontSize: 28.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            Text(
              isRefunded 
                  ? 'Your funds of ৳${controller.totalAmount.toStringAsFixed(2)} have been returned.'
                  : 'Your payment of ৳${controller.totalAmount.toStringAsFixed(2)} via ${controller.selectedGateway.value} was successful.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.7), fontSize: 14.sp, height: 1.5),
            ),
            if (!isRefunded && controller.isEscrowEnabled.value) ...[
              SizedBox(height: 24.h),
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().cardBackground : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.security, color: Colors.greenAccent),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'Escrow is Active. Funds are securely held until you confirm delivery.',
                        style: GoogleFonts.poppins(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, fontSize: 12.sp),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 48.h),
            
            // Action Buttons
            if (!isRefunded)
              Obx(() => SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.amber),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                  ),
                  onPressed: controller.isProcessing.value
                      ? null
                      : () => controller.requestRefund(),
                  child: controller.isProcessing.value
                      ? SizedBox(height: 20.r, width: 20.r, child: const CircularProgressIndicator(color: Colors.amber, strokeWidth: 2))
                      : Text(
                          'Request Refund',
                          style: GoogleFonts.outfit(color: Colors.amber, fontSize: 16.sp, fontWeight: FontWeight.bold),
                        ),
                ),
              )),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7953CA),
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                ),
                onPressed: () {
                  Get.back();
                },
                child: Text(
                  'Back to Home',
                  style: GoogleFonts.outfit(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
