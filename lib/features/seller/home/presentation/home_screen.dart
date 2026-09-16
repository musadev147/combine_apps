import 'dart:ui';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:bd_shope_combined/constants/app_colors.dart';
import 'package:bd_shope_combined/constants/text_font_style.dart';
import 'package:bd_shope_combined/common_widgets/glass_background_scaffold.dart';
import 'package:bd_shope_combined/common_widgets/glass_card.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:bd_shope_combined/services/web_socket_service.dart';
import 'package:bd_shope_combined/services/agora_service.dart';
import 'package:bd_shope_combined/features/seller/call/presentation/data/call_controller.dart';
import 'package:bd_shope_combined/features/seller/call/presentation/data/notification_service.dart';
import 'package:bd_shope_combined/features/seller/call/presentation/call_screen.dart';
import '../../../../services/agora_service.dart';
import '../../../../services/web_socket_service.dart';
import 'data/tag_api.dart';
import 'model/get_all_tag_model.dart';
import 'package:bd_shope_combined/controllers/connection_controller.dart';
import 'package:bd_shope_combined/networks/api_acess.dart';
import 'widgets/dashboard_tab.dart';
import 'widgets/invoices_tab.dart';
import 'widgets/short_notes_tab.dart';
import 'widgets/promise_notes_tab.dart';
import 'widgets/payments_tab.dart';
import 'widgets/reports_tab.dart';
import 'widgets/support_tab.dart';
import 'widgets/profile_tab.dart';
import 'widgets/payout_tab.dart';
import 'package:bd_shope_combined/controllers/theme_controller.dart';
import 'widgets/auth_flow_screen.dart';
import 'package:bd_shope_combined/route/app_routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  int _homeTabClickCount = 0;
  int _invoiceTabClickCount = 0;
  int _notesTabClickCount = 0;
  int _unpromiseTabClickCount = 0;
  int _paymentTabClickCount = 0;
  int _payoutTabClickCount = 0;
  int _supportTabClickCount = 0;
  int _profileTabClickCount = 0;

  // Messenger Call Notification State
  bool _showIncomingCallBanner = false;
  String _incomingCallerName = "Rahat Islam";
  String _incomingCallerId = "BYR-0981";

  // Simulator state: Authentication flow (Login, Register, Forgot, OTP)
  String _authScreenState =
      "LOGGED_IN"; // "LOGIN", "REGISTER", "FORGOT", "OTP", "LOGGED_IN"
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _regStoreNameController = TextEditingController();
  final _regEmailController = TextEditingController();
  final _regPhoneController = TextEditingController();
  final _otpController = TextEditingController();

  final List<Map<String, dynamic>> _invoicesList = [
    {
      "id": "INV-0981",
      "buyer": "Rahat Islam",
      "item": "iPhone 15 Pro",
      "qty": 1,
      "delivery": 120,
      "status": "Paid",
      "date": "10:30 AM",
    },
    {
      "id": "INV-0980",
      "buyer": "Maliha Chowdhury",
      "item": "Sony WH-1000XM5",
      "qty": 2,
      "delivery": 150,
      "status": "Pending",
      "date": "08:15 AM",
    },
  ];

  final List<Map<String, dynamic>> _callLogs = [
    {
      "buyer": "Rahat Islam",
      "buyerId": "BYR-0981",
      "duration": "02:14",
      "time": "Just now",
      "invoiceCreated": false,
    },
    {
      "buyer": "Maliha Chowdhury",
      "buyerId": "BYR-0980",
      "duration": "05:40",
      "time": "2 hours ago",
      "invoiceCreated": true,
    },
    {
      "buyer": "Sayed Ahmed",
      "buyerId": "BYR-8821",
      "duration": "01:15",
      "time": "Yesterday",
      "invoiceCreated": false,
    },
  ];

  // Store variables
  final _storeNameController = TextEditingController(text: "Damadami Live Hub");
  final _storePhoneController = TextEditingController(text: "+8801712345678");
  final _storeAddressController = TextEditingController(
    text: "Level 4, Jamuna Futura Park, Dhaka",
  );
  final _storeTinController = TextEditingController(text: "12893-9812-3921");

  // Support simulator variables
  final List<Map<String, dynamic>> _supportMessages = [
    {
      "sender": "admin",
      "text":
          "Hello! Welcome to Damadami live support chat. How can we assist you today?",
      "time": "03:10 PM",
    },
    {
      "sender": "seller",
      "text": "I wanted to check why my last withdrawal request is pending.",
      "time": "03:12 PM",
    },
    {
      "sender": "admin",
      "text":
          "Sure, let me check the transaction queue for you. One moment please.",
      "time": "03:13 PM",
    },
  ];
  final List<String> _trendingTags = [
    'fashion', 'electronics', 'wholesale', 'clothing', 'mobile', 'gaming',
    'apple', 'nike', 'luxury', 'organic',
  ];

  final Map<String, Set<String>> _selectedTagRegions = {};
  final _supportMsgController = TextEditingController();

  @override
  void initState() {
    super.initState();
    try {
      if (!Get.isRegistered<WebSocketService>()) {
        Get.put(WebSocketService(), permanent: true);
      }
      if (!Get.isRegistered<AgoraService>()) {
        Get.put(AgoraService(), permanent: true);
      }
      if (!Get.isRegistered<ConnectionController>()) {
        Get.put(ConnectionController(), permanent: true);
      }
      Get.find<ConnectionController>().setRole('seller');
      if (!Get.isRegistered<CallController>()) {
        Get.put(CallController(), permanent: true);
      }
      Get.find<CallController>().autoConnectIfLoggedIn();
      NotificationService.instance.registerToken();
      _loadVendorTagsFromApi();
      getCategoryRx.fetchCategories();
    } catch (e) {
      // ignore
    }
  }

  void _loadVendorTagsFromApi() async {
    try {
      final tags = await TagApi.instance.fetchVendorTags();
      final adminTags = await TagApi.instance.fetchAdminTags();
      final adminTagsMap = {
        for (var tag in adminTags)
          if (tag.id != null) tag.id!: tag.tagname ?? '',
      };

      if (Get.isRegistered<ConnectionController>()) {
        final connectionController = Get.find<ConnectionController>();
        connectionController.sellerTagIds.clear();

        final resolvedNames = tags
            .map<String>((t) {
              log("DEBUG VENDOR TAG: tagId=${t.id}, adminTag=${t.adminTag}, region=${t.region}");
              
              final tagId = t.adminTag?.toString();
              if (tagId != null && adminTagsMap.containsKey(tagId)) {
                String name = adminTagsMap[tagId]!;
                if (t.region != null && t.region!.trim().isNotEmpty) {
                  name = "$name (${t.region!.trim()})";
                }
                
                if (t.id != null) {
                  connectionController.sellerTagIds[name] = t.id!;
                }
                return name;
              }
              
              String name = t.tagName;
              if (t.id != null) {
                connectionController.sellerTagIds[name] = t.id!;
              }
              return name;
            })
            .where((name) => name.isNotEmpty)
            .toList();

        connectionController.sellerTags.assignAll(resolvedNames);
      }
    } catch (e) {
      log("Error loading vendor tags: $e");
    }
  }

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _regStoreNameController.dispose();
    _regEmailController.dispose();
    _regPhoneController.dispose();
    _otpController.dispose();

    _storeNameController.dispose();
    _storePhoneController.dispose();
    _storeAddressController.dispose();
    _storeTinController.dispose();
    _supportMsgController.dispose();

    super.dispose();
  }

  void _generateMockReport(String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          "Generating $title",
          style: TextStyle(
            color: Get.isRegistered<ThemeController>()
                ? Get.find<ThemeController>().textColor
                : Colors.black,
          ),
        ),
        content: Text(
          "Your detailed PDF/CSV report sheet is being compiled. It will download to your device directory.",
          style: TextStyle(
            color: Get.isRegistered<ThemeController>()
                ? Get.find<ThemeController>().textSecondaryColor
                : Colors.black54,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Get.snackbar(
                "Download Success",
                "Report successfully saved to your downloads.",
                colorText: Colors.white,
                backgroundColor: Colors.green,
              );
            },
            child: Text("Download"),
          ),
        ],
      ),
    );
  }

  Future<void> _answerSimulatedCall() async {
    setState(() {
      _showIncomingCallBanner = false;
    });
    final result = await Get.toNamed(
      '/call',
      arguments: {
        'buyerName': _incomingCallerName,
        'buyerId': _incomingCallerId,
      },
    );
    if (result != null && result is Map<String, dynamic>) {
      if (result.containsKey('callEnded') && result['callEnded'] == true) {
        setState(() {
          _callLogs.insert(0, {
            "buyer": _incomingCallerName,
            "buyerId": _incomingCallerId,
            "duration": result['duration'] ?? "00:00",
            "time": "Just now",
            "invoiceCreated": false,
          });
        });
      } else {
        setState(() {
          _invoicesList.insert(0, result);
          _callLogs.insert(0, {
            "buyer": _incomingCallerName,
            "buyerId": _incomingCallerId,
            "duration": "Call Ended",
            "time": "Just now",
            "invoiceCreated": true,
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_authScreenState != "LOGGED_IN") {
      return AuthFlowScreen(
        authScreenState: _authScreenState,
        loginEmailController: _loginEmailController,
        loginPasswordController: _loginPasswordController,
        regStoreNameController: _regStoreNameController,
        regEmailController: _regEmailController,
        regPhoneController: _regPhoneController,
        otpController: _otpController,
        onStateChanged: (state) => setState(() => _authScreenState = state),
        onLogin: () {
          setState(() => _authScreenState = "LOGGED_IN");
          Get.snackbar(
            "Welcome Back",
            "Successfully logged in as a seller!",
            colorText: Colors.white,
            backgroundColor: Colors.greenAccent.withOpacity(0.7),
          );
        },
        onRequestOtp: () {
          setState(() => _authScreenState = "OTP");
          Get.snackbar(
            "OTP Sent",
            "An OTP verification code was sent to your phone.",
            colorText: Colors.white,
            backgroundColor: AppColors.c5369CA,
          );
        },
        onVerifyOtp: () {
          setState(() => _authScreenState = "LOGGED_IN");
          Get.snackbar(
            "Verified",
            "Phone verification successfully processed!",
            colorText: Colors.white,
            backgroundColor: Colors.greenAccent.withOpacity(0.8),
          );
        },
      );
    }

    final tc = Get.find<ThemeController>();
    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
          return false;
        }
        final shouldExit = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Get.isRegistered<ThemeController>()
                  ? Get.find<ThemeController>().cardBackground
                  : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              title: Text(
                "Exit App",
                style: TextStyle(
                  color: Get.isRegistered<ThemeController>()
                      ? Get.find<ThemeController>().textColor
                      : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text(
                "Are you sure you want to exit the app?",
                style: TextStyle(
                  color: Get.isRegistered<ThemeController>()
                      ? Get.find<ThemeController>().textSecondaryColor
                      : Colors.black54,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    "No",
                    style: TextStyle(
                      color: Get.isRegistered<ThemeController>()
                          ? Get.find<ThemeController>().textSecondaryColor
                          : Colors.black54,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.c053A4CA,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text(
                    "Yes",
                    style: TextStyle(
                      color: Get.isRegistered<ThemeController>()
                          ? Get.find<ThemeController>().textColor
                          : Colors.black,
                    ),
                  ),
                ),
              ],
            );
          },
        );
        return shouldExit ?? false;
      },
      child: Stack(
        children: [
          GlassBackgroundScaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: tc.isDarkMode.value
                    ? Brightness.light
                    : Brightness.dark,
                statusBarBrightness: tc.isDarkMode.value
                    ? Brightness.dark
                    : Brightness.light,
              ),
              centerTitle: false,
              title: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: tc.inputBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: tc.inputBorderColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 32.w,
                          height: 32.h,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.c053A4CA,
                                AppColors.c5369CA,
                                AppColors.c7953CA,
                              ],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'S',
                              style: TextStyle(
                                color: Get.isRegistered<ThemeController>()
                                    ? Get.find<ThemeController>().textColor
                                    : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Seller Hub',
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: tc.textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.notifications_active_outlined,
                    color: tc.textColor,
                  ),
                  tooltip: "Notifications",
                  onPressed: () {
                    Get.toNamed(Routes.NOTIFICATIONS);
                  },
                ),
                SizedBox(width: 8.w),
              ],
            ),
            body: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeCard(),
                  SizedBox(height: 16.h),
                  _buildModernTabBar(),
                  SizedBox(height: 20.h),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          Offstage(
                            offstage: _selectedIndex != 0,
                            child: DashboardTab(
                              refreshTrigger: _homeTabClickCount,
                              onViewInvoices: () =>
                                  setState(() => _selectedIndex = 1),
                              onSupportCenter: () =>
                                  setState(() => _selectedIndex = 6),
                              pendingInvoicesCount: _invoicesList
                                  .where(
                                    (inv) =>
                                        inv["status"] != "Paid" &&
                                        inv["status"] != "Completed" &&
                                        inv["status"] != "Success",
                                  )
                                  .length,
                            ),
                          ),
                          Offstage(
                            offstage: _selectedIndex != 1,
                            child: InvoicesTab(
                              refreshTrigger: _invoiceTabClickCount,
                              callLogs: _callLogs,
                              invoicesList: _invoicesList,
                              onCreateInvoice: (newInvoice, log) {
                                setState(() {
                                  _invoicesList.insert(0, newInvoice);
                                  log["invoiceCreated"] = true;
                                });
                                Get.snackbar(
                                  "Invoice Created",
                                  "Successfully generated invoice for ${log['buyer']}",
                                  colorText: Colors.white,
                                  backgroundColor: Colors.greenAccent
                                      .withOpacity(0.8),
                                );
                              },
                            ),
                          ),
                          Offstage(
                            offstage: _selectedIndex != 2,
                            child: ShortNotesTab(
                              refreshTrigger: _notesTabClickCount,
                            ),
                          ),
                          Offstage(
                            offstage: _selectedIndex != 3,
                            child: PromiseNotesTab(
                              isPromise: false,
                              refreshTrigger: _unpromiseTabClickCount,
                            ),
                          ),
                          Offstage(
                            offstage: _selectedIndex != 4,
                            child: PaymentsTab(
                              refreshTrigger: _paymentTabClickCount,
                              onPayoutRequested: () {
                                Get.snackbar(
                                  "Withdraw Request",
                                  "Your withdrawal request has been submitted to admin.",
                                  colorText: Colors.white,
                                  backgroundColor: Colors.greenAccent
                                      .withOpacity(0.8),
                                );
                              },
                            ),
                          ),
                          Offstage(
                            offstage: _selectedIndex != 5,
                            child: PayoutTab(
                              refreshTrigger: _payoutTabClickCount,
                            ),
                          ),
                          Offstage(
                            offstage: _selectedIndex != 6,
                            child: const SupportTab(),
                          ),
                          Offstage(
                            offstage: _selectedIndex != 7,
                            child: ProfileTab(
                              storeNameController: _storeNameController,
                              storePhoneController: _storePhoneController,
                              storeAddressController: _storeAddressController,
                              storeTinController: _storeTinController,
                              loginEmail:
                                  _loginEmailController.text.trim().isEmpty
                                  ? "seller@damadami.com.bd"
                                  : _loginEmailController.text.trim(),
                              onSave: () {
                                setState(() {});
                                Get.snackbar(
                                  "Profile Updated",
                                  "Your profile information has been successfully updated.",
                                  colorText: Colors.white,
                                  backgroundColor: Colors.greenAccent
                                      .withOpacity(0.8),
                                );
                              },
                              onAddTag: _showCustomAddTagDialog,
                              onRemoveTag: (tagName, tagId) async {
                                try {
                                  EasyLoading.show(status: 'Removing tag...');
                                  bool success = await TagApi.instance
                                      .deleteVendorTag(tagId);
                                  EasyLoading.dismiss();
                                  if (success) {
                                    final connectionController =
                                        Get.find<ConnectionController>();
                                    connectionController.removeTag(tagName);
                                    connectionController.sellerTagIds.remove(
                                      tagName,
                                    );
                                    Get.snackbar(
                                      "Tag Removed",
                                      "Successfully removed tag: #$tagName",
                                      colorText: Colors.white,
                                      backgroundColor: Colors.greenAccent
                                          .withOpacity(0.8),
                                    );
                                  } else {
                                    Get.snackbar(
                                      "Error",
                                      "Failed to remove tag from server.",
                                      colorText: Colors.white,
                                      backgroundColor: Colors.redAccent
                                          .withOpacity(0.8),
                                    );
                                  }
                                } catch (e) {
                                  EasyLoading.dismiss();
                                  log("Error deleting vendor tag: $e");
                                }
                              },
                            ),
                          ),
                          SizedBox(height: 30.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_showIncomingCallBanner) _buildIncomingCallNotificationBanner(),

          // Active Call Floating Taskbar (Messenger Style)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8.h,
            left: 16.w,
            right: 16.w,
            child: Get.isRegistered<CallController>()
                ? Obx(() {
                    final callCtrl = Get.find<CallController>();
                    if (callCtrl.callState.value == CallState.connected &&
                        !callCtrl.isCallScreenVisible.value) {
                      return _buildActiveCallFloatingBar(callCtrl);
                    }
                    return SizedBox.shrink();
                  })
                : SizedBox.shrink(),
          ),
          if (_selectedIndex == 6)
            Positioned(
              bottom: 24.h,
              right: 24.w,
              child: GestureDetector(
                onTap: () async {
                  final Uri whatsappUrl = Uri.parse(
                    "https://wa.me/8801410189000",
                  );
                  try {
                    if (await canLaunchUrl(whatsappUrl)) {
                      await launchUrl(
                        whatsappUrl,
                        mode: LaunchMode.externalApplication,
                      );
                    } else {
                      await launchUrl(
                        whatsappUrl,
                        mode: LaunchMode.platformDefault,
                      );
                    }
                  } catch (e) {
                    Get.snackbar(
                      "Error",
                      "Could not open WhatsApp. Please save number manually.",
                      colorText: Colors.white,
                      backgroundColor: Colors.redAccent.withOpacity(0.8),
                    );
                  }
                },
                child: Container(
                  width: 54.w,
                  height: 54.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF25D366),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF25D366).withOpacity(0.4),
                        blurRadius: 12.r,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.chat_bubble_rounded,
                      color: Get.isRegistered<ThemeController>()
                          ? Get.find<ThemeController>().textColor
                          : Colors.black,
                      size: 26,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActiveCallFloatingBar(CallController callCtrl) {
    final tc = Get.find<ThemeController>();
    return GestureDetector(
      onTap: () => Get.to(() => const CallScreen(), routeName: 'CallScreen'),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF2E8B57).withOpacity(0.85),
                  const Color(0xFF3CB371).withOpacity(0.85),
                ],
              ),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: Get.isRegistered<ThemeController>()
                    ? Get.find<ThemeController>().dividerColor
                    : Colors.black12.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.r,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.phone_in_talk,
                  color: Get.isRegistered<ThemeController>()
                      ? Get.find<ThemeController>().textColor
                      : Colors.black,
                  size: 18.sp,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Active Call - Tap to return",
                        style: TextStyle(
                          color: Get.isRegistered<ThemeController>()
                              ? Get.find<ThemeController>().textColor
                              : Colors.black,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Connected with: ${callCtrl.currentCustomerId.value}",
                        style: TextStyle(
                          color: Get.isRegistered<ThemeController>()
                              ? Get.find<ThemeController>().textColor
                              : Colors.black.withOpacity(0.8),
                          fontSize: 11.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Get.isRegistered<ThemeController>()
                      ? Get.find<ThemeController>().textSecondaryColor
                      : Colors.black54,
                  size: 14.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    final tc = Get.find<ThemeController>();
    return GlassCard(
      borderRadius: 20.r,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome,',
                    style: TextStyle(
                      color: tc.textSecondaryColor,
                      fontSize: 13.sp,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    _storeNameController.text,
                    style: TextStyle(
                      color: tc.textColor,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: Colors.greenAccent.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      'Store Active & Verified',
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.verified_user_rounded,
              color: AppColors.c053A4CA,
              size: 36.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTabBar() {
    final tc = Get.find<ThemeController>();
    final tabs = [
      {'icon': Icons.space_dashboard_rounded, 'label': 'Home'},
      {'icon': Icons.receipt_long_rounded, 'label': 'Invoice'},
      {'icon': Icons.note_alt_rounded, 'label': 'Short Notes'},
      {'icon': Icons.broken_image_rounded, 'label': 'Unpromise'},
      {'icon': Icons.account_balance_wallet_rounded, 'label': 'Payment'},
      {'icon': Icons.credit_card_rounded, 'label': 'Payout'},
      {'icon': Icons.support_agent_rounded, 'label': 'Support'},
      {'icon': Icons.person_rounded, 'label': 'Profile'},
    ];

    return SizedBox(
      height: 48.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        physics: const BouncingScrollPhysics(),
        clipBehavior: Clip.none,
        itemBuilder: (context, index) {
          final isSelected = _selectedIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                if (index == 0) {
                  _homeTabClickCount++;
                } else if (index == 1) {
                  _invoiceTabClickCount++;
                } else if (index == 2) {
                  _notesTabClickCount++;
                } else if (index == 3) {
                  _unpromiseTabClickCount++;
                } else if (index == 4) {
                  _paymentTabClickCount++;
                } else if (index == 5) {
                  _payoutTabClickCount++;
                } else if (index == 6) {
                  _supportTabClickCount++;
                } else if (index == 7) {
                  _profileTabClickCount++;
                }
                _selectedIndex = index;
              });
              try {
                if (index == 0) {
                  getCategoryRx.fetchCategories();
                  getInvoiceRx.fetchInvoices();
                } else if (index == 1) {
                  getInvoiceRx.fetchInvoices();
                } else if (index == 2) {
                  getCategoryRx.fetchCategories();
                }
              } catch (e) {
                // ignore
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              margin: EdgeInsets.only(right: 12.w),
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              decoration: BoxDecoration(
                color: isSelected ? null : tc.inputBackground,
                border: isSelected ? null : Border.all(color: tc.inputBorderColor, width: 1.2),
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          AppColors.c053A4CA,
                          AppColors.c5369CA,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                borderRadius: BorderRadius.circular(24.r), // Pill shape
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.c5369CA.withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [],
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    tabs[index]['icon'] as IconData,
                    color: isSelected ? Colors.white : tc.textSecondaryColor,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    tabs[index]['label'] as String,
                    style: TextStyle(
                      color: isSelected ? Colors.white : tc.textSecondaryColor,
                      fontSize: 13.sp,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIncomingCallNotificationBanner() {
    return Positioned(
      top: 10.h,
      left: 16.w,
      right: 16.w,
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1B4B).withOpacity(0.95),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: AppColors.c053A4CA.withOpacity(0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _answerSimulatedCall,
                    child: Row(
                      children: [
                        Container(
                          width: 44.w,
                          height: 44.h,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.c053A4CA,
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22.r),
                            child: Image.network(
                              "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80",
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                    Icons.person,
                                    color: Get.isRegistered<ThemeController>()
                                        ? Get.find<ThemeController>().textColor
                                        : Colors.black,
                                  ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _incomingCallerName,
                                style: TextStyle(
                                  color: Get.isRegistered<ThemeController>()
                                      ? Get.find<ThemeController>().textColor
                                      : Colors.black,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Incoming Messenger Call...",
                                style: TextStyle(
                                  color: Get.isRegistered<ThemeController>()
                                      ? Get.find<ThemeController>()
                                            .textSecondaryColor
                                      : Colors.black54,
                                  fontSize: 11.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.call_end, color: Colors.redAccent),
                  onPressed: () =>
                      setState(() => _showIncomingCallBanner = false),
                ),
                IconButton(
                  icon: Icon(Icons.call, color: Colors.greenAccent),
                  onPressed: _answerSimulatedCall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showCustomAddTagDialog() async {
    final result = await Get.dialog<bool>(
      const _CustomAddTagDialog(),
      barrierDismissible: true,
    );
    if (result == true) {
      _loadVendorTagsFromApi();
    }
  }
}

class _CustomAddTagDialog extends StatefulWidget {
  const _CustomAddTagDialog({Key? key}) : super(key: key);

  @override
  State<_CustomAddTagDialog> createState() => _CustomAddTagDialogState();
}

class _CustomAddTagDialogState extends State<_CustomAddTagDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<Results> _allTags = [];
  List<Results> _filteredTags = [];
  bool _isLoading = true;
  
  // Maps Tag ID to a single selected region
  final Map<String, String> _selectedRegions = {};
  // The currently selected Tag ID (only 1 allowed at a time)
  String? _selectedTagId;

  @override
  void initState() {
    super.initState();
    _fetchTags();
  }

  void _fetchTags([String query = '']) async {
    setState(() => _isLoading = true);
    try {
      final tags = await TagApi.instance.fetchAdminTags(query: query);
      setState(() {
        _allTags = tags;
        _filteredTags = tags;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _filterTags(String query) {
    if (query.isEmpty) {
      setState(() => _filteredTags = _allTags);
      return;
    }
    setState(() {
      _filteredTags = _allTags.where((tag) => 
        (tag.tagName).toLowerCase().contains(query.toLowerCase())
      ).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 320,
        height: 500,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Tag",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              onChanged: _filterTags,
              decoration: InputDecoration(
                hintText: "Search tag...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    itemCount: _filteredTags.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = _filteredTags[index];
                      final tagId = item.id ?? '';
                      String mainTag = item.tagName;
                      String subTagsStr = "";
                      
                      if (mainTag.contains('(') && mainTag.endsWith(')')) {
                        int openParen = mainTag.indexOf('(');
                        subTagsStr = mainTag.substring(openParen + 1, mainTag.length - 1);
                        mainTag = mainTag.substring(0, openParen).trim();
                      }

                      final isTagSelected = _selectedTagId == tagId;
                      final selectedRegionForThisTag = _selectedRegions[tagId];

                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    mainTag,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (subTagsStr.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: subTagsStr.split(',').map((t) {
                                        final region = t.trim();
                                        final isRegionSelected = selectedRegionForThisTag == region;
                                        
                                        return FilterChip(
                                          label: Text(
                                            region,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: isRegionSelected ? Colors.white : AppColors.c053A4CA,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          selected: isRegionSelected,
                                          onSelected: (bool selected) {
                                            setState(() {
                                              if (selected) {
                                                _selectedRegions[tagId] = region;
                                                _selectedTagId = tagId; // Auto-select tag, replacing any previously selected tag
                                              } else {
                                                if (_selectedRegions[tagId] == region) {
                                                  _selectedRegions.remove(tagId);
                                                  if (_selectedTagId == tagId) {
                                                    _selectedTagId = null; // Auto-deselect if no regions
                                                  }
                                                }
                                              }
                                            });
                                          },
                                          selectedColor: AppColors.c053A4CA,
                                          backgroundColor: AppColors.c053A4CA.withOpacity(0.15),
                                          checkmarkColor: Colors.white,
                                          showCheckmark: false,
                                          padding: EdgeInsets.zero,
                                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(6),
                                            side: BorderSide(color: AppColors.c053A4CA.withOpacity(0.3)),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Checkbox(
                              value: isTagSelected,
                              activeColor: AppColors.c053A4CA,
                              shape: const CircleBorder(), // Makes it look like a radio button
                              onChanged: (val) {
                                setState(() {
                                  if (val == true) {
                                    _selectedTagId = tagId;
                                  } else {
                                    if (_selectedTagId == tagId) {
                                      _selectedTagId = null;
                                      _selectedRegions.remove(tagId);
                                    }
                                  }
                                });
                              },
                            )
                          ],
                        ),
                      );
                    },
                  ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (_selectedTagId == null) {
                    Get.back();
                    return;
                  }
                  
                  int addedCount = 0;
                  final connController = Get.isRegistered<ConnectionController>() 
                      ? Get.find<ConnectionController>() 
                      : null;
                      
                  final tagId = _selectedTagId!;
                  final tagData = _allTags.firstWhere((t) => t.id == tagId);
                  
                  if (connController == null || !connController.sellerTags.contains(tagData.tagName)) {
                    String? regionStr = _selectedRegions[tagId];
                    
                    bool success = await TagApi.instance.postVendorTag(tagId, region: regionStr);
                    if (success) addedCount++;
                  }
                  
                  // Instead of _loadVendorTagsFromApi() we could trigger a callback, 
                  // but we can just pop the dialog and tell HomeScreen to refresh.
                  Get.back(result: true); 
                  
                  if (addedCount > 0) {
                    Get.snackbar(
                      "Tags Added",
                      "Successfully added $addedCount tags.",
                      colorText: Colors.white,
                      backgroundColor: Colors.greenAccent.withOpacity(0.8),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.c053A4CA,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Add Selected Tags", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
