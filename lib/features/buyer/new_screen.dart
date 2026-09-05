import 'package:bd_shope_combined/controllers/theme_controller.dart';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Re‑use the common glass background widget if it exists, otherwise provide a simple gradient.
class NewScreen extends StatelessWidget {
  const NewScreen({Key? key}) : super(key: key);

  // Theme colors defined for the project.
  static const Color color1 = Color(0xFF53A4CA);
  static const Color color2 = Color(0xFF5369CA);
  static const Color color3 = Color(0xFF7953CA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Transparent scaffold to allow background visual effect.
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Gradient background with subtle blur for glass‑morphism effect.
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [color1, color2, color3],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Centered floating glass card.
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().cardBackground : Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12.withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Premium Glassmorphism Screen',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().cardBackground : Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black45,
                              offset: Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24),
                      Text(
                        'This screen uses the three theme colors defined for the app.\nFeel the smooth blur and floating card effect.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textSecondaryColor : Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24),
                      // Example button to navigate back.
                      ElevatedButton(
                        onPressed: Get.back,
                        style: const ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(Color(0xFF53A4CA)),
                          padding: MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
                        // child: Text('Go Back', style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black)),
                      ), child: const Placeholder(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
