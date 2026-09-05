import 'package:bd_shope_combined/controllers/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:bd_shope_combined/features/buyer/coustomer/serach/presentation/invoice_section/widget/build_invoice.dart';
import 'package:bd_shope_combined/networks/api_acess.dart';
import 'widget/model/build_invoice_model.dart';
import 'widget/model/notification_model.dart';

import 'package:bd_shope_combined/common_widgets/glass_card.dart';
import 'package:bd_shope_combined/route/app_pages.dart';


class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _activeTab = 1; // 0 for Notifications, 1 for Invoices
  bool _isNotifLoading = false;

  @override
  void initState() {
    super.initState();
    getInvoiceRx.fetchInvoices();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    if (mounted) {
      setState(() {
        _isNotifLoading = true;
      });
    }
    try {
      await getNotificationsRx.fetchNotifications();
    } catch (_) {}
    if (mounted) {
      setState(() {
        _isNotifLoading = false;
      });
    }
  }

  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'New Invoice Received',
      'body': 'Invoice #INV-98234 for Apple MacBook Pro M3 is ready for payment. Tap to pay via SSL Commerz or EPS.',
      'time': 'Just now',
      'icon': Icons.receipt_long,
      'color': Colors.amber,
      'type': 'invoice',
    },
    {
      'title': 'New Message',
      'body': 'Karim Electronics replied: "Yes, the iPhone 15 Pro is available. You can call me now."',
      'time': '5m ago',
      'icon': Icons.chat_bubble_outline,
      'color': const Color(0xFF53A4CA),
    },
    {
      'title': 'Price Drop Alert!',
      'body': 'Yamaha R15 V4 price dropped by \$100. Contact the seller immediately.',
      'time': '2h ago',
      'icon': Icons.trending_down,
      'color': const Color(0xFF7953CA),
    },
    {
      'title': 'New Seller Nearby',
      'body': 'Mac Studio BD has set up shop 2.5 km away from you.',
      'time': '1d ago',
      'icon': Icons.storefront,
      'color': const Color(0xFF5369CA),
    },
  ];

  final List<Map<String, dynamic>> _invoices = [
    {
      'id': 'INV-98234',
      'product': 'Apple MacBook Pro M3',
      'amount': '৳1,45,000',
      'status': 'Pending',
    },
    {
      'id': 'INV-98233',
      'product': 'iPhone 15 Pro Max',
      'amount': '৳1,20,000',
      'status': 'Completed',
    },
    {
      'id': 'INV-98232',
      'product': 'Sony WH-1000XM5',
      'amount': '৳35,000',
      'status': 'Completed',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(110.h),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12.withOpacity(0.1), width: 1),
            ),
          ),
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Text(
                  'Notification Center',
                  style: GoogleFonts.outfit(
                    color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 20.sp,
                  ),
                ),
              ),
              // Custom Tab bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                child: Row(
                  children: [
                    _buildTabItem(0, 'Notifications', Icons.notifications_none),
                    SizedBox(width: 12.w),
                    _buildTabItem(1, 'Invoices', Icons.receipt_outlined),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: _activeTab == 0
            ? _buildNotificationsList()
            : StreamBuilder<List<GetNotifiInvoiceModel>>(
                stream: getInvoiceRx.valueStreamData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final data = snapshot.data ?? [];
                  return BuildInvoicesList(invoices: data, onRefresh: () => getInvoiceRx.fetchInvoices());
                },
              ),
      ),
    );
  }

  Widget _buildTabItem(int index, String title, IconData icon) {
    final isSelected = _activeTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeTab = index;
        });
        if (index == 1) {
          getInvoiceRx.fetchInvoices();
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF53A4CA) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.white : Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textSecondaryColor : Colors.black54, size: 16.r),
            SizedBox(width: 6.w),
            Text(
              title,
              style: GoogleFonts.poppins(
                color: isSelected ? Colors.white : Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textSecondaryColor : Colors.black54,
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList() {
    if (_isNotifLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF53A4CA)),
        ),
      );
    }

    final notifications = getNotificationsRx.valueStreamData.valueOrNull ?? [];
    
    // Filter out any notification that has invoice type, just in case
    final filteredNotifications = notifications.where((n) => n.type != 'invoice').toList();

    // If empty, fallback to mock notifications so user can see example content
    final itemsToDisplay = filteredNotifications.isNotEmpty
        ? filteredNotifications
        : _notifications.map((m) => NotificationModel(
            title: m['title'],
            body: m['body'],
            createdAt: m['time'],
            type: m['type'],
          )).toList();

    if (itemsToDisplay.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().iconColor : Colors.black45, size: 64.r),
            SizedBox(height: 16.h),
            Text(
              'No new notifications',
              style: GoogleFonts.outfit(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.r),
      itemCount: itemsToDisplay.length,
      itemBuilder: (context, index) {
        final notif = itemsToDisplay[index];
        
        IconData icon = Icons.notifications_none;
        Color color = const Color(0xFF53A4CA);

        if (notif.type == 'invoice') {
          icon = Icons.receipt_long;
          color = Colors.amber;
        }

        return GestureDetector(
          onTap: () {
            if (notif.type == 'invoice') {
              setState(() {
                _activeTab = 1;
              });
              getInvoiceRx.fetchInvoices();
            }
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 12.h),
            child: GlassCard(
              borderRadius: 20.r,
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withOpacity(0.15),
                        border: Border.all(color: color.withOpacity(0.3)),
                      ),
                      child: Icon(icon, color: color, size: 20.r),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  notif.title ?? '',
                                  style: GoogleFonts.outfit(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, fontSize: 14.sp, fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                notif.createdAt ?? '',
                                style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.4), fontSize: 10.sp),
                              ),
                            ],
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            notif.body ?? '',
                            style: GoogleFonts.poppins(
                              color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.7),
                              fontSize: 12.sp,
                              height: 1.5,
                            ),
                          ),
                        ],
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
