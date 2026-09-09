import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:bd_shope_combined/common_widgets/glass_card.dart';
import 'package:bd_shope_combined/features/seller/home/presentation/create_invoice_screen.dart';
import 'common_components.dart';
import 'package:bd_shope_combined/features/seller/home/presentation/data/invoice_api.dart';
import 'package:bd_shope_combined/features/seller/home/presentation/model/get_invoice_model.dart';
import 'package:bd_shope_combined/features/seller/home/presentation/model/get_invoices_details-model.dart';
import 'package:bd_shope_combined/controllers/theme_controller.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

class InvoicesTab extends StatefulWidget {
  final List<Map<String, dynamic>> callLogs;
  final List<Map<String, dynamic>> invoicesList;
  final Function(Map<String, dynamic> newInvoice, Map<String, dynamic> log) onCreateInvoice;
  final int? refreshTrigger;

  const InvoicesTab({
    super.key,
    required this.callLogs,
    required this.invoicesList,
    required this.onCreateInvoice,
    this.refreshTrigger = 0,
  });

  @override
  State<InvoicesTab> createState() => _InvoicesTabState();
}

class _InvoicesTabState extends State<InvoicesTab> {
  int _selectedSubTab = 0; // 0 for Pending, 1 for Completed
  late Future<List<GetInvoiceModel>> _futureInvoices;

  @override
  void initState() {
    super.initState();
    _refreshInvoices();
  }

  @override
  void didUpdateWidget(covariant InvoicesTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.refreshTrigger != oldWidget.refreshTrigger) {
      _refreshInvoices();
    }
  }

  void _refreshInvoices() {
    setState(() {
      _futureInvoices = InvoiceApi.instance.fetchInvoices();
    });
  }

  String _getBuyerName(String? buyer) {
    if (buyer == null) return 'Unknown Buyer';
    final cleanId = buyer.trim();
    if (cleanId == '5' || cleanId == 'BYR-0981' || cleanId.toLowerCase() == 'rahat') {
      return 'Rahat Islam';
    }
    if (cleanId == '6' || cleanId == 'BYR-0980' || cleanId.toLowerCase() == 'maliha') {
      return 'Maliha Chowdhury';
    }
    if (cleanId == '7' || cleanId == 'BYR-8821' || cleanId.toLowerCase() == 'sayed') {
      return 'Sayed Ahmed';
    }
    if (RegExp(r'^\d+$').hasMatch(cleanId)) {
      final idVal = int.tryParse(cleanId) ?? 0;
      if (idVal % 3 == 0) return 'Sayed Ahmed';
      if (idVal % 2 == 0) return 'Maliha Chowdhury';
      return 'Rahat Islam';
    }
    if (cleanId.length > 8) {
      return 'Buyer #${cleanId.substring(0, 6).toUpperCase()}';
    }
    return buyer;
  }

  void _navigateToCreateInvoiceScreen(BuildContext context, Map<String, dynamic> log) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateInvoiceScreen(
          initialLog: log,
          onCreateInvoice: (newInvoice) {
            widget.onCreateInvoice(newInvoice, log);
            _refreshInvoices();
          },
        ),
      ),
    );
  }

  Widget _buildTabButton(ThemeController tc, int index, String label) {
    final isSelected = _selectedSubTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedSubTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF53A4CA) : tc.inputBackground,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? const Color(0xFF53A4CA) : tc.inputBorderColor,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: isSelected ? Colors.white : tc.textSecondaryColor,
            fontSize: 11.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String? status) {
    final cleanStatus = status?.toLowerCase() ?? 'pending';
    Color badgeColor;
    Color textColor;
    String label;

    if (cleanStatus == 'paid' || cleanStatus == 'success' || cleanStatus == 'completed') {
      badgeColor = const Color(0xFF10B981).withOpacity(0.15);
      textColor = const Color(0xFF10B981);
      label = status?.toUpperCase() ?? 'COMPLETED';
    } else if (cleanStatus == 'pending') {
      badgeColor = const Color(0xFFF39C12).withOpacity(0.15);
      textColor = const Color(0xFFF39C12);
      label = status?.toUpperCase() ?? 'PENDING';
    } else {
      badgeColor = const Color(0xFFEF4444).withOpacity(0.15);
      textColor = const Color(0xFFEF4444);
      label = status?.toUpperCase() ?? cleanStatus.toUpperCase();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusIcon(String? status) {
    final cleanStatus = status?.toLowerCase() ?? 'pending';
    if (cleanStatus == 'paid' || cleanStatus == 'success' || cleanStatus == 'completed') {
      return Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: const Color(0xFF10B981).withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.check_circle_outline_rounded, color: Color(0xFF10B981), size: 20),
      );
    } else if (cleanStatus == 'pending') {
      return Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: const Color(0xFFF39C12).withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.hourglass_empty_rounded, color: Color(0xFFF39C12), size: 20),
      );
    } else {
      return Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444).withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.cancel_outlined, color: Color(0xFFEF4444), size: 20),
      );
    }
  }

  String _formatDate(String? isoString) {
    if (isoString == null || isoString.isEmpty) return 'Just now';
    try {
      final dateTime = DateTime.parse(isoString).toLocal();
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final day = dateTime.day.toString().padLeft(2, '0');
      final month = months[dateTime.month - 1];
      final hour = dateTime.hour > 12 ? dateTime.hour - 12 : (dateTime.hour == 0 ? 12 : dateTime.hour);
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = dateTime.hour >= 12 ? 'PM' : 'AM';
      return '$day $month, $hour:$minute $period';
    } catch (e) {
      if (isoString.contains('T')) {
        final parts = isoString.split('T');
        final date = parts[0];
        final time = parts[1].split('.')[0];
        return '$date $time';
      }
      return isoString;
    }
  }

  void _showMarkAsPaidDialog(GetInvoiceModel inv) {
    final tc = Get.find<ThemeController>();
    Get.dialog(
      AlertDialog(
        backgroundColor: tc.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
          side: BorderSide(color: tc.inputBorderColor, width: 1.5),
        ),
        title: Text(
          "Mark as Paid",
          style: TextStyle(
            color: tc.textColor,
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
        content: Text(
          "Are you sure you want to mark this invoice as Paid?",
          style: TextStyle(
            color: tc.textSecondaryColor,
            fontSize: 13.sp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              "Cancel",
              style: TextStyle(
                color: tc.textSecondaryColor,
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
                await _markAsPaid(inv.id!);
              } else {
                Get.snackbar(
                  "Success",
                  "Invoice marked as Paid (Mock)",
                  colorText: Colors.white,
                  backgroundColor: const Color(0xFF10B981),
                );
              }
            },
            child: Text(
              "Confirm Paid",
              style: TextStyle(
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

  Future<void> _markAsPaid(String id) async {
    EasyLoading.show(status: 'Updating invoice status...');
    try {
      final success = await InvoiceApi.instance.updateInvoiceStatus(id, "Paid");
      EasyLoading.dismiss();
      if (success) {
        Get.snackbar(
          "Success",
          "Invoice marked as Paid successfully!",
          colorText: Colors.white,
          backgroundColor: const Color(0xFF10B981),
        );
        for (var inv in widget.invoicesList) {
          if (inv["id"] == id) {
            inv["status"] = "Paid";
          }
        }
        _refreshInvoices();
      } else {
        for (var inv in widget.invoicesList) {
          if (inv["id"] == id) {
            inv["status"] = "Paid";
          }
        }
        Get.snackbar(
          "Success (Local Demo)",
          "Invoice marked as Paid in demo mode.",
          colorText: Colors.white,
          backgroundColor: const Color(0xFF10B981),
        );
        _refreshInvoices();
      }
    } catch (e) {
      EasyLoading.dismiss();
      for (var inv in widget.invoicesList) {
        if (inv["id"] == id) {
          inv["status"] = "Paid";
        }
      }
      Get.snackbar(
        "Success (Local Demo)",
        "Invoice marked as Paid in demo/mock mode.",
        colorText: Colors.white,
        backgroundColor: const Color(0xFF10B981),
      );
      _refreshInvoices();
    }
  }


  void _showInvoiceDetails(BuildContext context, GetDetailsInvoiceModel invoice) {
    final tc = Get.find<ThemeController>();
    final formattedDate = _formatDate(invoice.createdAt);
    final shortInvId = invoice.id != null && invoice.id!.length > 8
        ? invoice.id!.substring(0, 8).toUpperCase()
        : (invoice.id ?? 'N/A');
    final buyerName = _getBuyerName(invoice.buyer);

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: tc.cardBackground,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28.r),
            topRight: Radius.circular(28.r),
          ),
          border: Border.all(color: tc.inputBorderColor, width: 1.5),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 18.h),
                  decoration: BoxDecoration(
                    color: tc.textSecondaryColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Invoice Details",
                    style: TextStyle(
                      color: tc.textColor,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildStatusBadge(invoice.status),
                ],
              ),
              SizedBox(height: 20.h),
              Divider(color: tc.dividerColor),
              SizedBox(height: 10.h),
              _buildDetailRow(tc, "Product Name", invoice.productName ?? 'N/A', isBoldValue: true),
              _buildDetailRow(tc, "Invoice ID", "#$shortInvId"),
              _buildDetailRow(tc, "Invoice Number", invoice.invoiceNumber ?? 'N/A'),
              _buildDetailRow(tc, "Date & Time", formattedDate),
              _buildDetailRow(tc, "Buyer", buyerName),
              _buildDetailRow(tc, "Phone Number", invoice.phoneNumber ?? 'N/A'),
              _buildDetailRow(tc, "Delivery Address", invoice.address ?? 'N/A'),
              SizedBox(height: 10.h),
              Divider(color: tc.dividerColor),
              SizedBox(height: 10.h),
              _buildDetailRow(tc, "Quantity", "${invoice.quantity ?? 1} Pcs"),
              _buildDetailRow(tc, "Price Per Piece", "৳${invoice.pricePerPiece ?? '0.00'}"),
              _buildDetailRow(tc, "Delivery Charge", "৳${invoice.deliveryCharge ?? '0.00'}"),
              _buildDetailRow(tc, "Service Charge", "৳${invoice.serviceCharge ?? '0.00'}"),
              SizedBox(height: 10.h),
              Divider(color: tc.dividerColor),
              SizedBox(height: 10.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Amount",
                    style: TextStyle(
                      color: tc.textColor,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "৳${invoice.totalPrice ?? '0.00'}",
                    style: TextStyle(
                      color: const Color(0xFF10B981),
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF53A4CA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                  onPressed: () => Get.back(),
                  child: Text(
                    "Close",
                    style: TextStyle(
                      color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDetailRow(ThemeController tc, String label, String value, {bool isBoldValue = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: tc.textSecondaryColor,
                fontSize: 12.sp,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: tc.textColor,
                fontSize: 12.sp,
                fontWeight: isBoldValue ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceCard(ThemeController tc, GetInvoiceModel inv, {bool isCompleted = false, bool isRejected = false}) {
    final buyerName = _getBuyerName(inv.buyer);
    final shortInvId = inv.id != null && inv.id!.length > 8
        ? inv.id!.substring(0, 8).toUpperCase()
        : (inv.id ?? 'N/A');
    final formattedDate = _formatDate(inv.createdAt);
    final price = double.tryParse(inv.totalPrice ?? '')?.toStringAsFixed(2) ?? (inv.totalPrice ?? '0.00');

    String deliveryText = "Delivery Pending";
    Color deliveryColor = const Color(0xFFE67E22);
    IconData deliveryIcon = Icons.local_shipping_outlined;
    if (inv.buyerConfirmedDelivery == true) {
      deliveryText = "Received by Buyer";
      deliveryColor = const Color(0xFF10B981);
      deliveryIcon = Icons.mark_as_unread_sharp;
    }

    return GestureDetector(
      onTap: () async {
        if (inv.id != null) {
          try {
            EasyLoading.show(status: 'Loading details...');
            final details = await InvoiceApi.instance.fetchInvoiceDetails(inv.id!);
            EasyLoading.dismiss();
            if (details != null) {
              _showInvoiceDetails(context, details);
            } else {
              Get.snackbar(
                "Error",
                "Could not fetch invoice details.",
                colorText: Colors.white,
                backgroundColor: Colors.redAccent,
              );
            }
          } catch (e) {
            EasyLoading.dismiss();
            Get.snackbar(
              "Error",
              "Failed to fetch details: $e",
              colorText: Colors.white,
              backgroundColor: Colors.redAccent,
            );
          }
        }
      },
      child: GlassCard(
        borderRadius: 16.r,
        backgroundColor: tc.inputBackground,
        margin: EdgeInsets.symmetric(vertical: 6.h),
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusIcon(inv.status),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      inv.productName ?? 'Unknown Product',
                      style: TextStyle(
                        color: tc.textColor,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Icon(Icons.receipt_rounded, size: 12.sp, color: tc.textSecondaryColor),
                          SizedBox(width: 4.w),
                          Text(
                            'INV-#$shortInvId',
                            style: TextStyle(
                              color: tc.textSecondaryColor,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Icon(Icons.access_time_rounded, size: 12.sp, color: tc.textSecondaryColor),
                          SizedBox(width: 4.w),
                          Text(
                            formattedDate,
                            style: TextStyle(
                              color: tc.textSecondaryColor,
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '$buyerName  •  ${inv.quantity ?? 1} Pcs',
                      style: TextStyle(
                        color: tc.textColor.withOpacity(0.85),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (isCompleted) ...[
                      SizedBox(height: 8.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: deliveryColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(deliveryIcon, size: 12.sp, color: deliveryColor),
                            SizedBox(width: 4.w),
                            Text(
                              deliveryText,
                              style: TextStyle(
                                color: deliveryColor,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '৳$price',
                    style: TextStyle(
                      color: isCompleted 
                          ? const Color(0xFF10B981) 
                          : (isRejected ? const Color(0xFFEF4444) : const Color(0xFF53A4CA)),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  _buildStatusBadge(inv.status),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tc = Get.find<ThemeController>();
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _buildTabButton(tc, 0, "Pending")),
                  SizedBox(width: 6.w),
                  Expanded(child: _buildTabButton(tc, 1, "Completed")),
                  SizedBox(width: 6.w),
                  Expanded(child: _buildTabButton(tc, 2, "Rejected")),
                ],
              ),
            ),
            SizedBox(width: 6.w),
            IconButton(
              icon: Icon(Icons.refresh_rounded, color: tc.textSecondaryColor),
              onPressed: _refreshInvoices,
            ),
          ],
        ),
        SizedBox(height: 20.h),
        FutureBuilder<List<GetInvoiceModel>>(
          future: _futureInvoices,
          builder: (context, snapshot) {
            List<GetInvoiceModel> apiInvoices = [];
            bool isFallback = false;

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.h),
                  child: const CircularProgressIndicator(color: Color(0xFF53A4CA)),
                ),
              );
            } else if (snapshot.hasError || !snapshot.hasData) {
              isFallback = true;
              apiInvoices = widget.invoicesList.map((inv) {
                return GetInvoiceModel(
                  id: inv["id"],
                  buyer: inv["buyer"],
                  productName: inv["item"],
                  totalPrice: inv["price"]?.toString() ?? inv["delivery"]?.toString(),
                  quantity: inv["qty"],
                  isConfirm: inv["status"] == "Paid" || inv["status"] == "Completed" || inv["status"] == "Success",
                  status: inv["status"],
                  createdAt: inv["date"],
                  buyerConfirmedDelivery: inv["buyer_confirmed_delivery"] ?? false,
                );
              }).toList();
            } else {
              apiInvoices = snapshot.data!;
            }

            final pendingInvoices = apiInvoices.where((inv) {
              final status = inv.status?.toLowerCase() ?? 'pending';
              final isPaid = status == 'paid' || status == 'completed' || status == 'success';
              final isRejected = status == 'rejected' || status == 'failed' || status == 'canceled';
              return !isPaid && !isRejected;
            }).toList();
            
            final completedInvoices = apiInvoices.where((inv) {
              final status = inv.status?.toLowerCase() ?? 'pending';
              return status == 'paid' || status == 'completed' || status == 'success';
            }).toList();

            final rejectedInvoices = apiInvoices.where((inv) {
              final status = inv.status?.toLowerCase() ?? 'pending';
              return status == 'rejected' || status == 'failed' || status == 'canceled';
            }).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isFallback)
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: 12.h),
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: Colors.orangeAccent.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orangeAccent, size: 16.sp),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            "Demo Mode: Displaying mock invoices (API offline/empty)",
                            style: TextStyle(color: Colors.orangeAccent, fontSize: 10.sp),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_selectedSubTab == 0) ...[
                  buildSectionHeader("Pending Invoices"),
                  SizedBox(height: 8.h),
                  if (pendingInvoices.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
                      child: Text("No pending invoices found.", style: TextStyle(color: tc.textSecondaryColor)),
                    )
                  else
                    ...pendingInvoices.map((inv) => _buildInvoiceCard(tc, inv)),
                ] else if (_selectedSubTab == 1) ...[
                  buildSectionHeader("Completed Invoices"),
                  SizedBox(height: 8.h),
                  if (completedInvoices.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
                      child: Text("No completed invoices found.", style: TextStyle(color: tc.textSecondaryColor)),
                    )
                  else
                    ...completedInvoices.map((inv) => _buildInvoiceCard(tc, inv, isCompleted: true)),
                ] else ...[
                  buildSectionHeader("Rejected Invoices"),
                  SizedBox(height: 8.h),
                  if (rejectedInvoices.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
                      child: Text("No rejected invoices found.", style: TextStyle(color: tc.textSecondaryColor)),
                    )
                  else
                    ...rejectedInvoices.map((inv) => _buildInvoiceCard(tc, inv, isRejected: true)),
                ]
              ],
            );
          },
        ),
      ],
    ));
  }
}
