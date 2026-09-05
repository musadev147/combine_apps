import 'package:bd_shope_combined/controllers/theme_controller.dart';
import 'dart:async';
import 'dart:developer';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:bd_shope_combined/constants/app_colors.dart';
import 'package:bd_shope_combined/common_widgets/glass_background_scaffold.dart';
import 'package:bd_shope_combined/common_widgets/glass_card.dart';
import 'package:bd_shope_combined/networks/dio/dio.dart';

import 'data/call_controller.dart';
import 'data/agora_service.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  late String _buyerName;
  late String _buyerId;
  
  bool _isMuted = false;
  bool _isSpeakerOn = false;
  bool _isCameraOff = false;
  bool _isCreatingInvoice = false;

  // Invoice form controllers
  final _prodNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _deliveryController = TextEditingController();
  final _priceController = TextEditingController();

  final int _secondsElapsed = 0;

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  void initState() {
    super.initState();
    // Set screen visible after the first build frame to avoid build-phase exceptions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<CallController>()) {
        Get.find<CallController>().isCallScreenVisible.value = true;
      }
    });
    
    // Get arguments or fallback to controller or default
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      _buyerName = args['buyerName'] ?? 'Rahat Islam';
      _buyerId = args['buyerId'] ?? 'BYR-0981';
    } else if (Get.isRegistered<CallController>()) {
      final callCtrl = Get.find<CallController>();
      _buyerName = callCtrl.currentCustomerId.value.isNotEmpty ? callCtrl.currentCustomerId.value : 'Customer';
      _buyerId = callCtrl.currentCallId.value.isNotEmpty ? callCtrl.currentCallId.value : 'CALL-WS';
    } else {
      _buyerName = 'Rahat Islam';
      _buyerId = 'BYR-0981';
    }
  }

  @override
  void dispose() {
    if (Get.isRegistered<CallController>()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.find<CallController>().isCallScreenVisible.value = false;
      });
    }
    _prodNameController.dispose();
    _quantityController.dispose();
    _deliveryController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  String _generateDynamicUUID() {
    final rand = math.Random();
    final hexDigits = '0123456789abcdef';
    final uuid = List.generate(36, (index) {
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
    return uuid;
  }

  Future<void> _submitInvoice() async {
    final name = _prodNameController.text.trim();
    final qtyText = _quantityController.text.trim();
    final priceText = _priceController.text.trim();
    final note = "";

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

    final sessionId = Get.isRegistered<CallController>()
        ? Get.find<CallController>().currentCallId.value
        : "98765432-abcd-efgh-ijkl-1234567890ab";

    final channelName = AgoraService.instance.currentChannelId ?? "call_room_xyz123";
    final uuid = _generateDynamicUUID();

    final payload = {
      "id": uuid,
      "session": sessionId.isNotEmpty ? sessionId : "98765432-abcd-efgh-ijkl-1234567890ab",
      "channel_name": channelName,
      "buyer": 5,        // (buyer ID, automatically from session)
      "vendor": 2,       // (vendor ID, automatically from session)
      "tag": 10,         // (automatically from session)
      "product_name": name,
      "price": priceVal.toStringAsFixed(2),
      "quantity": qty,
      "note": note.isNotEmpty ? note : "No extra notes.",
      "is_processed": false,
      "created_at": DateTime.now().toUtc().toIso8601String(),
      "updated_at": DateTime.now().toUtc().toIso8601String(),
    };

    try {
      final response = await postHttp("/invoice/short-notes/", payload);
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.back(result: {
          "id": uuid,
          "buyer": _buyerName,
          "item": name,
          "qty": qty,
          "delivery": 0,
          "status": "Success",
          "date": "Just now"
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
      log("Error posting invoice: $e");
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
    final agoraService = AgoraService.instance;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.transparent,
      body: Obx(() {
        final remoteUidVal = agoraService.remoteUid.value;
        final showLocalCamera = !_isCameraOff;
        final hasRemoteVideo = remoteUidVal != null;

        return Stack(
          children: [
            // Remote Video (Full Screen Background)
            Positioned.fill(
              child: hasRemoteVideo
                  ? AgoraVideoView(
                      controller: VideoViewController.remote(
                        rtcEngine: agoraService.engine!,
                        canvas: VideoCanvas(uid: remoteUidVal),
                        connection: RtcConnection(channelId: agoraService.currentChannelId),
                      ),
                    )
                  : Container(
                      color: const Color(0xFF141424), // Dark Messenger style background
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Profile Avatar
                            Container(
                              width: 120.r,
                              height: 120.r,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().cardBackground : Colors.white.withOpacity(0.05),
                                    blurRadius: 30,
                                    spreadRadius: 10,
                                  )
                                ],
                              ),
                              child: Obx(() {
                                final imgUrl = Get.isRegistered<CallController>()
                                    ? Get.find<CallController>().currentCustomerImage.value
                                    : '';
                                if (imgUrl.isNotEmpty) {
                                  if (imgUrl.startsWith('http')) {
                                    return CircleAvatar(
                                      radius: 60.r,
                                      backgroundImage: NetworkImage(imgUrl),
                                      backgroundColor: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12,
                                    );
                                  } else {
                                    return CircleAvatar(
                                      radius: 60.r,
                                      backgroundImage: AssetImage(imgUrl),
                                      backgroundColor: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12,
                                    );
                                  }
                                }
                                return CircleAvatar(
                                  radius: 60.r,
                                  backgroundColor: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12,
                                  child: Icon(Icons.person, size: 60.sp, color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black),
                                );
                              }),
                            ),
                            SizedBox(height: 24.h),
                            Text(
                              _buyerName,
                              style: GoogleFonts.poppins(
                                color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                                fontSize: 22.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Obx(() => Text(
                              "Connected • ${Get.find<CallController>().callTimerString.value}",
                              style: GoogleFonts.poppins(
                                color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.6),
                                fontSize: 14.sp,
                              ),
                            )),
                          ],
                        ),
                      ),
                    ),
            ),

            // Top Info Bar & Minimization (Messenger Style)
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
                            icon: Icon(Icons.keyboard_arrow_down, color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, size: 30),
                            onPressed: () => Get.back(),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                _buyerName,
                                style: GoogleFonts.poppins(
                                  color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  shadows: const [Shadow(blurRadius: 10, color: Colors.black87)],
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Obx(() => Text(
                                Get.find<CallController>().callTimerString.value,
                                style: GoogleFonts.poppins(
                                  color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.8),
                                  fontSize: 13.sp,
                                  shadows: const [Shadow(blurRadius: 10, color: Colors.black87)],
                                ),
                              )),
                            ],
                          ),
                          SizedBox(width: 48.w), // Spacer to balance back button
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Local Camera Preview (Picture-in-picture overlay)
            if (showLocalCamera && agoraService.engine != null)
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

            // Floating Create Invoice Button & Controls Overlay
            Positioned(
              left: 0,
              right: 0,
              bottom: 40.h,
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                      // Controls Row (Messenger Style)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Camera toggle
                          _buildMessengerIconButton(
                            icon: _isCameraOff ? Icons.videocam_off_rounded : Icons.videocam_rounded,
                            isActive: !_isCameraOff,
                            onTap: () {
                              setState(() {
                                _isCameraOff = !_isCameraOff;
                              });
                              agoraService.toggleCamera(_isCameraOff);
                            },
                          ),
                          // Switch Camera Button
                          if (!_isCameraOff)
                            _buildMessengerIconButton(
                              icon: Icons.flip_camera_ios_rounded,
                              isActive: false,
                              onTap: () {
                                agoraService.switchCamera();
                              },
                            ),
                          // Mute audio
                          _buildMessengerIconButton(
                            icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                            isActive: !_isMuted,
                            onTap: () {
                              setState(() {
                                _isMuted = !_isMuted;
                              });
                              agoraService.toggleMute(_isMuted);
                            },
                          ),
                          // Speaker phone
                          _buildMessengerIconButton(
                            icon: _isSpeakerOn ? Icons.volume_up_rounded : Icons.volume_down_rounded,
                            isActive: _isSpeakerOn,
                            onTap: () {
                              setState(() {
                                _isSpeakerOn = !_isSpeakerOn;
                              });
                              agoraService.toggleSpeaker(_isSpeakerOn);
                            },
                          ),
                          // End Call
                          GestureDetector(
                            onTap: () {
                              if (Get.isRegistered<CallController>()) {
                                Get.find<CallController>().endCall();
                              } else {
                                Get.back(result: {
                                  'callEnded': true,
                                  'duration': _formatDuration(_secondsElapsed),
                                });
                              }
                            },
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
                                  )
                                ],
                              ),
                              child: Icon(
                                Icons.call_end_rounded,
                                color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
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
          ],
        );
      }),
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
          style: TextStyle(
            color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.8),
            fontSize: 11.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4.h),
        Container(
          decoration: BoxDecoration(
            color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().cardBackground : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12.withOpacity(0.15)),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, fontSize: 13.sp),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.6), size: 18.sp),
              hintText: hint,
              hintStyle: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.35), fontSize: 13.sp),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 10.h),
            ),
          ),
        ),
      ],
    );
  }
}
