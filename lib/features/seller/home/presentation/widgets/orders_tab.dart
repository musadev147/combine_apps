import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:bd_shope_combined/constants/app_colors.dart';
import 'package:bd_shope_combined/common_widgets/glass_card.dart';
import 'common_components.dart';
import 'package:bd_shope_combined/controllers/theme_controller.dart';

class OrdersTab extends StatefulWidget {
  final List<Map<String, dynamic>> ordersList;
  final Function(Map<String, dynamic>, String) onStatusUpdated;

  const OrdersTab({
    super.key,
    required this.ordersList,
    required this.onStatusUpdated,
  });

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
  Color _getOrderStatusColor(String status) {
    switch (status) {
      case "Pending":
        return Colors.redAccent;
      case "Processing":
        return Colors.orangeAccent;
      case "Shipped":
        return Colors.blueAccent;
      default:
        return Colors.greenAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tc = Get.find<ThemeController>();
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader("Order Pipeline & Deliveries"),
        SizedBox(height: 12.h),
        ...widget.ordersList.map((ord) => GlassCard(
              borderRadius: 14.r,
              backgroundColor: tc.inputBackground,
              margin: EdgeInsets.symmetric(vertical: 6.h),
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(ord["id"], style: TextStyle(color: tc.textColor, fontWeight: FontWeight.bold, fontSize: 14.sp)),
                        Text(ord["date"], style: TextStyle(color: tc.textSecondaryColor, fontSize: 11.sp)),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Text("Customer: ${ord["customer"]}", style: TextStyle(color: tc.textSecondaryColor, fontSize: 12.sp)),
                    Text("Items: ${ord["item"]}", style: TextStyle(color: tc.textColor, fontSize: 13.sp, fontWeight: FontWeight.bold)),
                    Text("Total: ৳${ord["amount"]}", style: TextStyle(color: AppColors.c053A4CA, fontSize: 13.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: _getOrderStatusColor(ord["status"]).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(ord["status"], style: TextStyle(color: _getOrderStatusColor(ord["status"]), fontSize: 11.sp, fontWeight: FontWeight.bold)),
                        ),
                        PopupMenuButton<String>(
                          color: tc.cardBackground,
                          icon: Icon(Icons.edit_road, color: tc.textColor),
                          onSelected: (newStatus) {
                            widget.onStatusUpdated(ord, newStatus);
                          },
                          itemBuilder: (context) => ["Pending", "Processing", "Shipped", "Delivered"]
                              .map((status) => PopupMenuItem(value: status, child: Text(status, style: TextStyle(color: tc.textColor))))
                              .toList(),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ))
      ],
    ));
  }
}
