import 'package:bd_shope_combined/controllers/theme_controller.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:bd_shope_combined/controllers/connection_controller.dart';

class CallOverlayWidget extends StatefulWidget {
  const CallOverlayWidget({Key? key}) : super(key: key);

  @override
  State<CallOverlayWidget> createState() => _CallOverlayWidgetState();
}

class _CallOverlayWidgetState extends State<CallOverlayWidget> with SingleTickerProviderStateMixin {
  final ConnectionController _controller = Get.find<ConnectionController>();
  late AnimationController _sonarController;

  @override
  void initState() {
    super.initState();
    _sonarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _sonarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final state = _controller.callState.value;
      if (state == 'idle') {
        return SizedBox.shrink();
      }

      return Positioned.fill(
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              color: Colors.black.withOpacity(0.65),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _buildCallUI(state),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildCallUI(String state) {
    switch (state) {
      case 'broadcasting':
        return _buildBroadcastingUI();
      case 'incoming':
        return _buildIncomingUI();
      case 'connected':
        return _buildConnectedUI();
      default:
        return SizedBox.shrink();
    }
  }

  // --- 1. BROADCASTING (BUYER SIDE) ---
  Widget _buildBroadcastingUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'CONNECTING LIVE',
          style: GoogleFonts.outfit(
            color: const Color(0xFF53A4CA),
            fontWeight: FontWeight.w800,
            fontSize: 14.sp,
            letterSpacing: 2,
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          'Broadcasting Request',
          style: GoogleFonts.outfit(
            color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24.sp,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Matching active specialists with tag',
          style: GoogleFonts.poppins(
            color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.6),
            fontSize: 13.sp,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: const Color(0xFF7953CA).withOpacity(0.15),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: const Color(0xFF7953CA).withOpacity(0.4)),
          ),
          child: Text(
            '#${_controller.callingTag.value}',
            style: GoogleFonts.poppins(
              color: const Color(0xFF7953CA),
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
          ),
        ),
        const Spacer(),
        
        // Pulsing Sonar Widget
        AnimatedBuilder(
          animation: _sonarController,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                ...List.generate(3, (index) {
                  final progress = (_sonarController.value + index / 3) % 1.0;
                  return Container(
                    width: 260.r * progress,
                    height: 260.r * progress,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF53A4CA).withOpacity(1.0 - progress),
                        width: 2.r,
                      ),
                    ),
                  );
                }),
                Container(
                  width: 100.r,
                  height: 100.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [const Color(0xFF53A4CA), const Color(0xFF7953CA)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF5369CA).withOpacity(0.5),
                        blurRadius: 20.r,
                        spreadRadius: 5.r,
                      ),
                    ],
                  ),
                  child: Icon(
                    _controller.activeCallType.value == 'video' ? Icons.videocam : Icons.mic,
                    color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                    size: 40.r,
                  ),
                ),
              ],
            );
          },
        ),
        
        const Spacer(),
        Obx(() => Text(
          'Pinging ${_controller.matchingSellersCount.value} online specialists...',
          style: GoogleFonts.poppins(
            color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.8),
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        )),
        SizedBox(height: 6.h),
        Text(
          'First specialist who accepts gets connected instantly.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.5),
            fontSize: 11.sp,
          ),
        ),
        SizedBox(height: 40.h),
        
        // Cancel Button
        GestureDetector(
          onTap: () => _controller.cancelCall(),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(26.r),
              border: Border.all(color: Colors.redAccent.withOpacity(0.5), width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.close, color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, size: 20.r),
                SizedBox(width: 8.w),
                Text(
                  'Cancel Call',
                  style: GoogleFonts.poppins(
                    color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 20.h),
      ],
    );
  }

  // --- 2. INCOMING CALL (SELLER SIDE) ---
  Widget _buildIncomingUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        // Shaking / Pulsing Phone Icon
        AnimatedBuilder(
          animation: _sonarController,
          builder: (context, child) {
            final double scale = 1.0 + (0.08 * (_sonarController.value < 0.5 ? _sonarController.value * 2 : (1.0 - _sonarController.value) * 2));
            return Transform.scale(
              scale: scale,
              child: Container(
                padding: EdgeInsets.all(32.r),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF7953CA).withOpacity(0.2),
                  border: Border.all(color: const Color(0xFF7953CA).withOpacity(0.6), width: 2),
                ),
                child: Icon(
                  Icons.phone_in_talk,
                  color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                  size: 64.r,
                ),
              ),
            );
          },
        ),
        SizedBox(height: 32.h),
        Text(
          'INCOMING LIVE CALL',
          style: GoogleFonts.outfit(
            color: const Color(0xFF53A4CA),
            fontWeight: FontWeight.w800,
            fontSize: 14.sp,
            letterSpacing: 2,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          'A Buyer Needs Expert Assist',
          style: GoogleFonts.outfit(
            color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22.sp,
          ),
        ),
        SizedBox(height: 16.h),
        
        // Needed Tag Badge
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().cardBackground : Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.tag, color: const Color(0xFF53A4CA), size: 16.r),
              SizedBox(width: 6.w),
              Text(
                _controller.callingTag.value,
                style: GoogleFonts.poppins(
                  color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 15.sp,
                ),
              ),
            ],
          ),
        ),
        
        const Spacer(),
        
        Text(
          'First seller to accept connects instantly.',
          style: GoogleFonts.poppins(
            color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.5),
            fontSize: 12.sp,
          ),
        ),
        SizedBox(height: 32.h),
        
        // Accept/Reject buttons row
        Row(
          children: [
            // Reject Button
            Expanded(
              child: GestureDetector(
                onTap: () => _controller.rejectIncomingCall(),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(color: Colors.redAccent.withOpacity(0.5), width: 1.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.call_end, color: Colors.redAccent, size: 22.r),
                      SizedBox(width: 8.w),
                      Text(
                        'Decline',
                        style: GoogleFonts.poppins(
                          color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            
            // Accept Button
            Expanded(
              child: GestureDetector(
                onTap: () => _controller.acceptIncomingCall(),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2E8B57), Color(0xFF3CB371)],
                    ),
                    borderRadius: BorderRadius.circular(24.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 10.r,
                        spreadRadius: 2.r,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.call, color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, size: 22.r),
                      SizedBox(width: 8.w),
                      Text(
                        'Accept',
                        style: GoogleFonts.poppins(
                          color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 20.h),
      ],
    );
  }

  // --- 3. CONNECTED (BOTH SIDES) ---
  Widget _buildConnectedUI() {
    final otherUser = _controller.connectedSeller.value;
    if (otherUser == null) return SizedBox.shrink();

    final isVideo = _controller.activeCallType.value == 'video';

    return Column(
      children: [
        // Top status info (Timer & Latency)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Network indicator
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().cardBackground : Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.signal_cellular_alt, color: Colors.greenAccent, size: 14.r),
                  SizedBox(width: 6.w),
                  Obx(() => Text(
                    '${_controller.networkStatus.value} (12ms)',
                    style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.8), fontSize: 11.sp),
                  )),
                ],
              ),
            ),
            
            // Timer Badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: const Color(0xFF7953CA).withOpacity(0.2),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFF7953CA).withOpacity(0.4)),
              ),
              child: Obx(() => Text(
                _controller.callTimerString.value,
                style: GoogleFonts.poppins(
                  color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 13.sp,
                ),
              )),
            ),
          ],
        ),
        
        const Spacer(),
        
        // Video Feed representation OR Audio Waveform
        if (isVideo)
          Obx(() {
            final camOff = _controller.isCameraOff.value;
            return Container(
              height: 280.h,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.r),
                border: Border.all(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12.withOpacity(0.2), width: 2),
                color: Colors.black.withOpacity(0.5),
              ),
              child: camOff
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.videocam_off, color: Colors.white30, size: 48.r),
                          SizedBox(height: 12.h),
                          Text('Your camera is muted', style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().iconColor : Colors.black45, fontSize: 12.sp)),
                        ],
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(28.r),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Buyer feed representation
                          Image.network(
                            otherUser.photo,
                            fit: BoxFit.cover,
                          ),
                          // Small corner self-view representation
                          Positioned(
                            bottom: 12.h,
                            right: 12.w,
                            child: Container(
                              height: 100.h,
                              width: 75.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12.withOpacity(0.6), width: 1.5),
                                color: Colors.grey[900],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14.r),
                                child: Image.network(
                                  _controller.currentRole.value == 'buyer'
                                      ? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=200' // Buyer mock pic
                                      : 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=200',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            );
          })
        else
          // Audio Call Waveform Simulation
          Column(
            children: [
              Container(
                width: 120.r,
                height: 120.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF53A4CA), width: 3),
                  image: DecorationImage(
                    image: NetworkImage(otherUser.photo),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                otherUser.name,
                style: GoogleFonts.outfit(
                  color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 22.sp,
                ),
              ),
              SizedBox(height: 6.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, color: const Color(0xFF53A4CA), size: 14.r),
                  SizedBox(width: 4.w),
                  Text(
                    otherUser.location,
                    style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.6), fontSize: 12.sp),
                  ),
                ],
              ),
              SizedBox(height: 40.h),
              
              // Pulsing wave lines
              SizedBox(
                height: 50.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(15, (index) {
                    return AnimatedBuilder(
                      animation: _sonarController,
                      builder: (context, child) {
                        final waveVal = (index - 7.5).abs();
                        final double factor = (10 - waveVal) / 10;
                        final double pulse = 5.0 + 35.0 * factor * (_sonarController.value);
                        return Container(
                          width: 4.w,
                          height: pulse.h,
                          margin: EdgeInsets.symmetric(horizontal: 2.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFF53A4CA).withOpacity(0.8),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ),
            ],
          ),
        
        const Spacer(),
        
        // Connected User glass info card
        if (isVideo) ...[
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12.withOpacity(0.08),
              border: Border.all(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12.withOpacity(0.15)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(otherUser.photo),
                  radius: 20.r,
                ),
                SizedBox(width: 10.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(otherUser.name, style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, fontWeight: FontWeight.bold)),
                    Text(otherUser.location, style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.6), fontSize: 11.sp)),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
        ],

        // Control Buttons Dock (Mute, Speaker, Camera, End)
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32.r),
            color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12.withOpacity(0.07),
            border: Border.all(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12.withOpacity(0.15)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Mute Button
              Obx(() {
                final muted = _controller.isMuted.value;
                return _buildCircleControlButton(
                  icon: muted ? Icons.mic_off : Icons.mic,
                  color: muted ? const Color(0xFF7953CA) : Colors.white.withOpacity(0.1),
                  iconColor: Colors.white,
                  onTap: () => _controller.toggleMute(),
                );
              }),
              
              // Speaker Button
              Obx(() {
                final speaker = _controller.isSpeakerOn.value;
                return _buildCircleControlButton(
                  icon: speaker ? Icons.volume_up : Icons.volume_down,
                  color: speaker ? const Color(0xFF53A4CA) : Colors.white.withOpacity(0.1),
                  iconColor: Colors.white,
                  onTap: () => _controller.toggleSpeaker(),
                );
              }),
              
              // Camera Toggle (Only for Video Calls)
              if (isVideo)
                Obx(() {
                  final camOff = _controller.isCameraOff.value;
                  return _buildCircleControlButton(
                    icon: camOff ? Icons.videocam_off : Icons.videocam,
                    color: camOff ? const Color(0xFF7953CA) : Colors.white.withOpacity(0.1),
                    iconColor: Colors.white,
                    onTap: () => _controller.toggleCamera(),
                  );
                }),
              
              // Skip/Reject Vendor Button (Only for Buyer role)
              if (_controller.currentRole.value == 'buyer')
                _buildCircleControlButton(
                  icon: Icons.skip_next_rounded,
                  color: Colors.orangeAccent,
                  iconColor: Colors.white,
                  onTap: () => _controller.rejectCurrentVendor(),
                ),
              
              // End Call Button (Red Accent)
              _buildCircleControlButton(
                icon: Icons.call_end,
                color: Colors.red,
                iconColor: Colors.white,
                onTap: () => _controller.endCall(),
              ),
            ],
          ),
        ),
        SizedBox(height: 20.h),
      ],
    );
  }

  Widget _buildCircleControlButton({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54.r,
        width: 54.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 24.r,
        ),
      ),
    );
  }
}
