import 'package:bd_shope_combined/controllers/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

import 'package:bd_shope_combined/common_widgets/glass_background_scaffold.dart';
import 'package:bd_shope_combined/common_widgets/glass_card.dart';
import 'package:bd_shope_combined/networks/api_acess.dart';
import 'model/model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    try {
      await getNotificationsRx.fetchNotifications();
    } catch (_) {}
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  final List<Map<String, dynamic>> _notifications = [
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

  @override
  Widget build(BuildContext context) {
    return GlassBackgroundScaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12.withOpacity(0.1), width: 1),
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black),
              onPressed: () => Get.back(),
            ),
            title: Text(
              'Notification Center',
              style: GoogleFonts.outfit(
                color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: 20.sp,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: _buildNotificationsList(),
      ),
    );
  }

  Widget _buildNotificationsList() {
    return StreamBuilder<List<NotificationModel>>(
      stream: getNotificationsRx.valueStreamData,
      builder: (context, snapshot) {
        if (_isLoading && !snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF53A4CA)),
            ),
          );
        }

        final notifications = snapshot.data ?? [];

        if (notifications.isEmpty) {
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
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notif = notifications[index];
            
            IconData icon = Icons.notifications_none;
            Color color = const Color(0xFF53A4CA);

            if (notif.type == 'invoice') {
               icon = Icons.receipt_long;
               color = const Color(0xFF7953CA);
            } else if (notif.type == 'short_notes') {
               icon = Icons.note_alt;
               color = const Color(0xFF53A4CA);
            }

            return Container(
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
            );
          },
        );
      },
    );
  }
}
