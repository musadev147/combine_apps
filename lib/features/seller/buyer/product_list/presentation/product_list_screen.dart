import 'package:bd_shope_combined/controllers/theme_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:bd_shope_combined/common_widgets/glass_background_scaffold.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassBackgroundScaffold(
      body: Center(
        child: Text("Product List Screen", style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black)),
      ),
    );
  }
}
