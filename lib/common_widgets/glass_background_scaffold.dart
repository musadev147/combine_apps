import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bd_shope_combined/controllers/theme_controller.dart';

class GlassBackgroundScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;

  const GlassBackgroundScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: appBar,
      body: Stack(
        children: [
            // Background Gradient and Glowing Blobs
            Positioned.fill(
              child: Obx(() {
                final isDark = Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().isDarkMode.value : true;
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? const [
                              Color(0xFF5369CA),
                              Color(0xFF53A4CA),
                              Color(0xFF7953CA),
                            ]
                          : const [
                              Color(0xFFE8F0FE), // Light Pastel Blue
                              Color(0xFFF4EBFF), // Light Pastel Purple
                              Color(0xFFE0F7FA), // Light Cyan
                            ],
                    ),
                  ),
                );
              }),
            ),
            // Glow Blob 1
            Positioned(
              top: -50,
              left: -50,
              child: Obx(() {
                final isDark = Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().isDarkMode.value : true;
                return Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF00FFFF).withOpacity(isDark ? 0.3 : 0.05),
                  ),
                );
              }),
            ),
            // Glow Blob 2
            Positioned(
              bottom: 100,
              right: -80,
              child: Obx(() {
                final isDark = Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().isDarkMode.value : true;
                return Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFF00FF).withOpacity(isDark ? 0.2 : 0.05),
                  ),
                );
              }),
            ),
            // Backdrop Blur Layer
            Positioned.fill(
              child: Obx(() {
                final isDark = Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().isDarkMode.value : true;
                return BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 30.0, sigmaY: 30.0),
                  child: Container(
                    color: isDark ? Colors.black.withOpacity(0.15) : Colors.white.withOpacity(0.35),
                  ),
                );
              }),
            ),
          // Screen Body Content
          Positioned.fill(
            child: SafeArea(
              child: body,
            ),
          ),
        ],
      ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}
