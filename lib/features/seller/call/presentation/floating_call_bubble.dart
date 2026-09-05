import 'package:bd_shope_combined/controllers/theme_controller.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'data/call_controller.dart';

class FloatingCallBubble extends StatefulWidget {
  final VoidCallback onTap;
  
  const FloatingCallBubble({Key? key, required this.onTap}) : super(key: key);

  @override
  State<FloatingCallBubble> createState() => _FloatingCallBubbleState();
}

class _FloatingCallBubbleState extends State<FloatingCallBubble> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  
  double _xOffset = 200.w;
  double _yOffset = 100.h;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    // Set initial position to top-right corner of screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      setState(() {
        _xOffset = size.width - 90.w;
        _yOffset = 120.h;
      });
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final callCtrl = Get.find<CallController>();
    final mediaQuery = MediaQuery.of(context);
    
    return Positioned(
      left: _xOffset,
      top: _yOffset,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _xOffset += details.delta.dx;
            _yOffset += details.delta.dy;
            
            // Keep bubble within screen boundaries
            _xOffset = _xOffset.clamp(10.w, mediaQuery.size.width - 90.w);
            _yOffset = _yOffset.clamp(50.h, mediaQuery.size.height - 100.h);
          });
        },
        onTap: widget.onTap,
        child: Material(
          color: Colors.transparent,
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: 76.r,
                height: 76.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF53A4CA).withOpacity(0.25 * _pulseController.value),
                      blurRadius: 12.r + (6.r * _pulseController.value),
                      spreadRadius: 2.r + (2.r * _pulseController.value),
                    ),
                    BoxShadow(
                      color: const Color(0xFF7953CA).withOpacity(0.15 * (1 - _pulseController.value)),
                      blurRadius: 8.r,
                    )
                  ],
                ),
                child: ClipOval(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF0F0C20).withOpacity(0.75),
                        border: Border.all(
                          color: const Color(0xFF53A4CA).withOpacity(0.5 + (0.3 * _pulseController.value)),
                          width: 1.5.r,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.perm_phone_msg_rounded,
                            color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                            size: 24.sp,
                          ),
                          SizedBox(height: 4.h),
                          Obx(() => Text(
                            callCtrl.callTimerString.value,
                            style: GoogleFonts.poppins(
                              color: Colors.greenAccent,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
