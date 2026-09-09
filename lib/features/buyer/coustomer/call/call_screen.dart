import 'package:bd_shope_combined/controllers/theme_controller.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:bd_shope_combined/controllers/connection_controller.dart';
import 'package:bd_shope_combined/common_wigdets/glass_background.dart';
import 'package:bd_shope_combined/common_wigdets/glass_card.dart';
import 'package:bd_shope_combined/services/agora_service.dart';
import 'package:bd_shope_combined/route/app_pages.dart';
import 'package:bd_shope_combined/networks/dio/dio.dart';
import 'package:bd_shope_combined/networks/endpoints.dart';
import 'package:bd_shope_combined/services/web_socket_service.dart';
import 'package:bd_shope_combined/helpers/di.dart';
import 'package:bd_shope_combined/constants/app_constants.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({Key? key}) : super(key: key);

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  bool _isCreatingInvoice = false;

  // Invoice form controllers
  final _prodNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _deliveryController = TextEditingController();
  final _priceController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _prodNameController.dispose();
    _quantityController.dispose();
    _deliveryController.dispose();
    _priceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String _generateDynamicUUID() {
    final rand = math.Random();
    final hexDigits = '0123456789abcdef';
    return List.generate(36, (index) {
      if (index == 8 || index == 13 || index == 18 || index == 23) {
        return '-';
      }
      if (index == 14) {
        return '4';
      }
      final randInt = rand.nextInt(16);
      if (index == 19) {
        return hexDigits[(randInt & 0x3) | 0x8];
      }
      return hexDigits[randInt];
    }).join();
  }

  Future<void> _submitInvoice() async {
    final controller = Get.find<ConnectionController>();
    final name = _prodNameController.text.trim();
    final qtyText = _quantityController.text.trim();
    final priceText = _priceController.text.trim();
    final note = _noteController.text.trim();

    if (name.isEmpty || qtyText.isEmpty || priceText.isEmpty) {
      Get.snackbar(
        "Validation Error",
        "Please fill in Product Name, Quantity and Price",
        colorText: Colors.white,
        backgroundColor: Colors.redAccent.withOpacity(0.8),
      );
      return;
    }

    final qty = int.tryParse(qtyText) ?? 1;
    final priceVal = double.tryParse(priceText) ?? 0.0;
    final deliveryText = _deliveryController.text.trim();
    final deliveryChargeVal = double.tryParse(deliveryText) ?? 0.0;

    final sessionId = controller.currentSessionId.value;
    final channelName =
        Get.find<AgoraService>().currentChannelId ?? "call_room_xyz123";
    final storedUserIdStr = appData.read(kKeyUserID)?.toString() ?? '';
    final storedUserId = int.tryParse(storedUserIdStr);
    final buyerId = storedUserId ?? (controller.activeBuyerId.value != 0 ? controller.activeBuyerId.value : 5);
    final uuid = _generateDynamicUUID();

    final payload = {
      "id": uuid,
      "session": sessionId.isNotEmpty
          ? sessionId
          : "98765432-abcd-efgh-ijkl-1234567890ab",
      "channel_name": channelName,
      "buyer": buyerId,
      "vendor": controller.activeVendorId.value,
      "tag": controller.activeTagId.value,
      "product_name": name,
      "price": priceVal.toStringAsFixed(2),
      "quantity": qty,
      "delivery_charge": deliveryChargeVal,
      "buyer_confirmed_delivery": true,
      "note": note.isNotEmpty ? note : "No extra notes.",
      "is_processed": false,
      "created_at": DateTime.now().toUtc().toIso8601String(),
      "updated_at": DateTime.now().toUtc().toIso8601String(),
    };

    try {
      final response = await postHttp("/invoice/short-notes/", payload);
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Send notification entry to server
        try {
          await postHttp(Endpoints.notifications(), {
            "title": "New Short Note Received",
            "body":
                "Invoice for '$name' (Qty: $qty, Price: ৳${priceVal.toStringAsFixed(2)}) received.",
            "type": "short_notes",
            "vendor": controller.activeVendorId.value,
            "vendor_id": controller.activeVendorId.value,
            "seller_id": controller.activeVendorId.value,
            "user": controller.activeVendorId.value,
            "user_id": controller.activeVendorId.value,
          });
        } catch (e) {
          debugPrint("Failed to trigger notification: $e");
        }

        // Also send real-time WebSocket notification directly to seller if they are connected
        try {
          final wsService = Get.find<WebSocketService>();
          if (wsService.isConnected) {
            final vendorIdStr = controller.activeVendorId.value.toString();
            final invoiceBody =
                "Invoice for '$name' (Qty: $qty, Price: ৳${priceVal.toStringAsFixed(2)}) received.";
            // Send a fake call_request with the [SHORT_NOTE] prefix so the backend routes it!
            wsService.sendCallRequest(
              product: '[SHORT_NOTE] $invoiceBody',
              sellerIds: [vendorIdStr],
            );
          }
        } catch (e) {
          debugPrint("WebSocket notification failed: $e");
        }

        setState(() {
          _isCreatingInvoice = false;
          _prodNameController.clear();
          _quantityController.clear();
          _priceController.clear();
          _deliveryController.clear();
          _noteController.clear();
        });

        Get.snackbar(
          "Invoice Created",
          "Invoice created and sent successfully!",
          colorText: Colors.white,
          backgroundColor: Colors.green.withOpacity(0.85),
        );
      } else {
        throw Exception("Server returned status: ${response.statusCode}");
      }
    } catch (e) {
      Get.snackbar(
        "API Error",
        "Failed to submit invoice to server.",
        colorText: Colors.white,
        backgroundColor: Colors.redAccent.withOpacity(0.85),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ConnectionController>();

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: GlassBackground(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.transparent,
          body: Obx(() {
            final state = controller.callState.value;

            if (state == 'broadcasting') {
              return _buildBroadcastingUI(controller);
            } else if (state == 'connected') {
              return _buildConnectedUI(controller);
            } else {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (Get.currentRoute == Routes.CALL) {
                  Get.back();
                  Future.delayed(const Duration(milliseconds: 100), () {
                    if (Get.currentRoute != Routes.HOME) {
                      Get.offNamed(Routes.HOME);
                    }
                  });
                }
              });
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF53A4CA)),
                ),
              );
            }
          }),
        ),
      ),
    );
  }

  Widget _buildBroadcastingUI(ConnectionController controller) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 40.h, left: 24.w, right: 24.w),
            child: Column(
              children: [
                Text(
                  'BROADCASTING CALL',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF53A4CA),
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  controller.callingTagOrProduct.value,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Pinging ${controller.matchingSellersCount.value} online specialists...',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1.2),
              duration: const Duration(seconds: 2),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return Container(
                  width: 180.r * value,
                  height: 180.r * value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(
                      0xFF7953CA,
                    ).withOpacity(0.15 * (2 - value)),
                    border: Border.all(
                      color: const Color(
                        0xFF7953CA,
                      ).withOpacity(0.3 * (2 - value)),
                      width: 2.r,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 120.r,
                      height: 120.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF53A4CA).withOpacity(0.2),
                        border: Border.all(
                          color: const Color(0xFF53A4CA).withOpacity(0.4),
                          width: 1.5.r,
                        ),
                      ),
                      child: Icon(
                        Icons.settings_input_antenna,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 50.h),
            child: Column(
              children: [
                Text(
                  'Waiting for sellers to accept...',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(height: 24.h),
                GestureDetector(
                  onTap: () => controller.cancelCall(),
                  child: Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.redAccent,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.redAccent,
                          blurRadius: 15,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(Icons.call_end, color: Colors.white, size: 28),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectedUI(ConnectionController controller) {
    final seller = controller.connectedSeller.value;
    final agoraService = Get.find<AgoraService>();

    return Obx(() {
      final isVideo = controller.activeCallType.value == 'video';
      final hasRemoteVideo = agoraService.remoteUid.value != null;
      final showLocalCamera = !controller.isCameraOff.value;

      if (!agoraService.isInitialized.value) {
        return Container(
          color: Get.isRegistered<ThemeController>()
              ? Get.find<ThemeController>().scaffoldBackgroundColor
              : const Color(0xFF141424),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF53A4CA)),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Initializing call engine...',
                  style: GoogleFonts.poppins(
                    color: Get.isRegistered<ThemeController>()
                        ? Get.find<ThemeController>().textSecondaryColor
                        : Colors.black54,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      if (!isVideo) {
        return _buildAudioConnectedUI(controller, seller);
      }

      return Stack(
        children: [
          Positioned.fill(
            child: hasRemoteVideo
                ? AgoraVideoView(
                    controller: VideoViewController.remote(
                      rtcEngine: agoraService.engine!,
                      canvas: VideoCanvas(uid: agoraService.remoteUid.value),
                      connection: RtcConnection(
                        channelId: agoraService.currentChannelId,
                      ),
                    ),
                  )
                : Container(
                    color: Get.isRegistered<ThemeController>()
                        ? Get.find<ThemeController>().scaffoldBackgroundColor
                        : const Color(0xFF0F0F1A),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF53A4CA),
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Waiting for video stream...',
                            style: GoogleFonts.poppins(
                              color: Get.isRegistered<ThemeController>()
                                  ? Get.find<ThemeController>()
                                        .textSecondaryColor
                                  : Colors.black54,
                              fontSize: 13.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: () => Get.back(),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              seller?.name ?? 'Seller',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                shadows: const [
                                  Shadow(blurRadius: 10, color: Colors.black87),
                                ],
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Obx(
                              () => Text(
                                controller.callTimerString.value,
                                style: GoogleFonts.poppins(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.normal,
                                  shadows: const [
                                    Shadow(
                                      blurRadius: 10,
                                      color: Colors.black87,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 48.w),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (showLocalCamera)
            Positioned(
              top: 100.h,
              right: 16.w,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  width: 100.w,
                  height: 150.h,
                  color: Colors.black45,
                  child: AgoraVideoView(
                    controller: VideoViewController(
                      rtcEngine: agoraService.engine!,
                      canvas: const VideoCanvas(uid: 0),
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 40.h,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!_isCreatingInvoice)
                    GlassCard(
                      borderRadius: 24.r,
                      color: const Color(0xFF53A4CA).withOpacity(0.18),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _isCreatingInvoice = true;
                          });
                        },
                        borderRadius: BorderRadius.circular(24.r),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 10.h,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.post_add_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                "Short Note",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildMessengerIconButton(
                        icon: controller.isCameraOff.value
                            ? Icons.videocam_off_rounded
                            : Icons.videocam_rounded,
                        isActive: !controller.isCameraOff.value,
                        onTap: () => controller.toggleCamera(),
                      ),
                      if (isVideo && !controller.isCameraOff.value)
                        _buildMessengerIconButton(
                          icon: Icons.flip_camera_ios_rounded,
                          isActive: false,
                          onTap: () => controller.switchCamera(),
                        ),
                      _buildMessengerIconButton(
                        icon: controller.isMuted.value
                            ? Icons.mic_off_rounded
                            : Icons.mic_rounded,
                        isActive: !controller.isMuted.value,
                        onTap: () => controller.toggleMute(),
                      ),
                      _buildMessengerIconButton(
                        icon: controller.isSpeakerOn.value
                            ? Icons.volume_up_rounded
                            : Icons.volume_down_rounded,
                        isActive: controller.isSpeakerOn.value,
                        onTap: () => controller.toggleSpeaker(),
                      ),
                      if (controller.currentRole.value == 'buyer')
                        GestureDetector(
                          onTap: () => controller.rejectCurrentVendor(),
                          child: Container(
                            width: 48.r,
                            height: 48.r,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.orangeAccent,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.skip_next_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      GestureDetector(
                        onTap: () => controller.endCall(),
                        child: Container(
                          width: 60.r,
                          height: 60.r,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.call_end_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_isCreatingInvoice) _buildInvoiceSheet(seller?.name ?? 'Seller'),
        ],
      );
    });
  }

  Widget _buildAudioConnectedUI(
    ConnectionController controller,
    SellerModel? seller,
  ) {
    return Container(
      color: Get.isRegistered<ThemeController>()
          ? Get.find<ThemeController>().scaffoldBackgroundColor
          : const Color(0xFF141424),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: Get.isRegistered<ThemeController>()
                          ? Get.find<ThemeController>().textSecondaryColor
                          : Colors.black54,
                      size: 30,
                    ),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  width: 120.r,
                  height: 120.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Get.isRegistered<ThemeController>()
                            ? Get.find<ThemeController>().cardBackground
                            : Colors.white.withOpacity(0.05),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 60.r,
                    backgroundImage: NetworkImage(seller?.photo ?? ''),
                    backgroundColor: Get.isRegistered<ThemeController>()
                        ? Get.find<ThemeController>().dividerColor
                        : Colors.black12,
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  seller?.name ?? 'Seller',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Obx(
                  () => Text(
                    controller.callTimerString.value,
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 16.sp,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 40.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!_isCreatingInvoice)
                    GlassCard(
                      borderRadius: 24.r,
                      color: const Color(0xFF53A4CA).withOpacity(0.18),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _isCreatingInvoice = true;
                          });
                        },
                        borderRadius: BorderRadius.circular(24.r),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 10.h,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.post_add_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                "Short Note",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildMessengerIconButton(
                        icon: controller.isCameraOff.value
                            ? Icons.videocam_off_rounded
                            : Icons.videocam_rounded,
                        isActive: !controller.isCameraOff.value,
                        onTap: () => controller.toggleCamera(),
                      ),
                      _buildMessengerIconButton(
                        icon: controller.isMuted.value
                            ? Icons.mic_off_rounded
                            : Icons.mic_rounded,
                        isActive: !controller.isMuted.value,
                        onTap: () => controller.toggleMute(),
                      ),
                      _buildMessengerIconButton(
                        icon: controller.isSpeakerOn.value
                            ? Icons.volume_up_rounded
                            : Icons.volume_down_rounded,
                        isActive: controller.isSpeakerOn.value,
                        onTap: () => controller.toggleSpeaker(),
                      ),
                      if (controller.currentRole.value == 'buyer')
                        GestureDetector(
                          onTap: () => controller.rejectCurrentVendor(),
                          child: Container(
                            width: 48.r,
                            height: 48.r,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.orangeAccent,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.skip_next_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      GestureDetector(
                        onTap: () => controller.endCall(),
                        child: Container(
                          width: 60.r,
                          height: 60.r,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.call_end_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceSheet(String sellerName) {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          color: Colors.black54,
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
            padding: EdgeInsets.only(
              left: 20.w,
              right: 20.w,
              top: 16.h,
              bottom: 20.h,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E38),
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      margin: EdgeInsets.only(bottom: 12.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Create Short Note",
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _isCreatingInvoice = false;
                          });
                        },
                      ),
                    ],
                  ),
                  Divider(color: Colors.white.withOpacity(0.12)),
                  SizedBox(height: 10.h),
                  _buildGlassInputField(
                    controller: _prodNameController,
                    label: "Product Name",
                    icon: Icons.shopping_bag_outlined,
                    hint: "e.g., MacBook Pro M3",
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildGlassInputField(
                          controller: _quantityController,
                          label: "Quantity",
                          icon: Icons.add_shopping_cart,
                          hint: "0",
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildGlassInputField(
                          controller: _priceController,
                          label: "Price (৳)",
                          icon: Icons.monetization_on_outlined,
                          hint: "150.00",
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child: _buildGlassInputField(
                  //         controller: _deliveryController,
                  //         label: "Delivery Charge (৳)",
                  //         icon: Icons.local_shipping_outlined,
                  //         hint: "60.00",
                  //         keyboardType: TextInputType.numberWithOptions(
                  //           decimal: true,
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  SizedBox(height: 12.h),
                  _buildGlassInputField(
                    controller: _noteController,
                    label: "Note",
                    icon: Icons.note_alt_outlined,
                    hint: "e.g., Please wrap securely.",
                  ),
                  SizedBox(height: 20.h),
                  Container(
                    width: double.infinity,
                    height: 48.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF53A4CA), Color(0xFF7953CA)],
                      ),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      onPressed: _submitInvoice,
                      child: Text(
                        "Send Short Note",
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 15.sp,
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
        ),
      ),
    );
  }

  Widget _buildMessengerIconButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? Colors.white : Colors.white.withOpacity(0.12),
          border: Border.all(
            color: isActive ? Colors.white : Colors.white.withOpacity(0.08),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.black87 : Colors.white,
          size: 24.r,
        ),
      ),
    );
  }

  Widget _buildGlassInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.9),
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 4.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.black12, width: 1),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: GoogleFonts.poppins(
              color: const Color(0xFF1E1E38),
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: const Color(0xFF7953CA),
                size: 18.sp,
              ),
              hintText: hint,
              hintStyle: GoogleFonts.poppins(
                color: Colors.black38,
                fontSize: 13.sp,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                vertical: 12.h,
                horizontal: 8.w,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
